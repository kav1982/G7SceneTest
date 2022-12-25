#ifndef BIOUM_CHARACTER_TONE_PASS_INCLUDE
#define BIOUM_CHARACTER_TONE_PASS_INCLUDE

#include "../ShaderLibrary/LightingCharacter.hlsl"
#include "../ShaderLibrary/Fog.hlsl"

struct Attributes
{
    float4 positionOS: POSITION;
    real3 normalOS: NORMAL;
    real4 tangentOS: TANGENT;
    real2 texcoord: TEXCOORD0;
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    real4 uv: TEXCOORD0;
    real4 vertexSH : TEXCOORD1;
    float4 positionWSAndFog: TEXCOORD2;
    
#if _NORMALMAP
    real4 tangentWS: TEXCOORD4;    // xyz: tangent, w: viewDir.x
    real4 bitangentWS: TEXCOORD5;    // xyz: binormal, w: viewDir.y
    real4 normalWS: TEXCOORD3;    // xyz: normal, w: viewDir.z
#else
    real3 normalWS: TEXCOORD3;
    real3 viewDirWS: TEXCOORD4;
#endif
    
    DECLARE_VERTEX_LIGHTING(vertexLighting, 6)
    DECLARE_SHADOWCOORD(shadowCoord, 7)

    real3 normalVS : TEXCOORD8;
    real4 viewDirVS : TEXCOORD9;
};

Varyings CommonLitVert(Attributes input)
{
    Varyings output = (Varyings)0;

    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionWSAndFog.xyz = positionWS;
    output.positionCS = TransformWorldToHClip(positionWS);
    
    half3 viewDirWS = normalize(_WorldSpaceCameraPos - positionWS);
#if _NORMALMAP
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.tangentWS = half4(normalInput.tangentWS, viewDirWS.x);
    output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.y);
    output.normalWS = half4(normalInput.normalWS, viewDirWS.z);
#else
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.viewDirWS = viewDirWS;
#endif
    
    output.uv.xy = input.texcoord;
    
    OUTPUT_GI_SH(output.normalWS.xyz, output.vertexSH.rgb);
    OUTPUT_SHADOWCOORD(positionWS, output.positionCS, output.shadowCoord);
    OUTPUT_VERTEX_LIGHTING(output.normalWS.xyz, positionWS, output.vertexLighting);
    
    output.positionWSAndFog.w = ComputeBioumFogFactor(output.positionCS.z, positionWS.y);

    UNITY_BRANCH
    if(Prop_RimToggle)
    {
        real3 lightDirVS = TransformWorldToViewDir(MainLightDirection(), false);
        output.viewDirVS.xyz = TransformWorldToViewDir(viewDirWS, false);
        output.viewDirVS.w = lightDirVS.x;
        output.normalVS = TransformWorldToViewDir(output.normalWS.xyz, false);
    }

    UNITY_BRANCH
    if(Prop_DissolveToggle)
    {
        positionWS.y += -Prop_DissolveAni * _Time.y;
        output.vertexSH.w = snoise3D(positionWS * Prop_DissolveScale) * 0.49 + 0.51;
        output.vertexSH.w = saturate(output.vertexSH.w) - Prop_DissolveFactor;
    }
    
    return output;
}

half4 CommonLitFrag(Varyings input): SV_TARGET
{
    ApplyDitherTransparent(input.positionCS.xy);
    
    Surface surface = (Surface)0;
    surface.albedo = sampleBaseMap(input.uv.xy);

    half3 emissive = GetEmissiveColor();
#if _EMISSIVE_MAP
    emissive = sampleEmissiveMap(input.uv).rgb;
#endif

    ApplyDissolve(surface.albedo.rgb, input.vertexSH.w);

    half2 smoothAO = half2(Prop_Smoothness, 1);
#if _NORMALMAP
    half3 normalTS = sampleNormalAOSmoothMap(input.uv.xy, smoothAO);
    half3x3 TBN = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    half3 normalWS = mul(normalTS, TBN);
    half3 viewDirWS = half3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
#else
    half3 normalWS = input.normalWS;
    half3 viewDirWS = input.viewDirWS;
#endif
    surface.normal = normalize(normalWS);
    surface.view = normalize(viewDirWS);
    
    surface.smoothness = smoothAO.x;
    surface.occlusion = smoothAO.y;
    surface.F0Strength = GetF0Strength();
    surface.position = input.positionWSAndFog.xyz;
    surface.fresnelStrength = GetFresnel();
    surface.penumbraTint = GetPenumbraTintColor();
    surface.specularColor = 1;
    surface.emissive = emissive;
    
    
    VertexData vertexData = (VertexData)0;
    vertexData.lighting = GET_VERTEX_LIGHTING(input.vertexLighting);
    vertexData.shadowCoord = GET_SHADOW_COORD(input.shadowCoord, surface.position);
    
    half alpha = 1;
    BRDF brdf = GetBRDF(surface, alpha);
    GI gi = GET_GI(0, input.vertexSH.rgb, surface, brdf.perceptualRoughness);

    LightingControl lightingControl = InitLightingControl(); 
    lightingControl.intensity = Prop_LightIntensity;
    lightingControl.smoothDiff = Prop_SmoothDiff;
    lightingControl.useCustomLighting = Prop_UseGlobalLightingControl;
    
    SubSurface sss;
    sss.color = GetSSSColor().rgb * surface.albedo.a;
    sss.normal = input.normalWS.xyz;
    sss.occlusionMode = 0;
    sss.doToneMapping = true;
    
    Light light = GetMainLight(surface.position, vertexData.shadowCoord, gi);
    half3 color = LightingPBR(surface, sss, brdf, vertexData.lighting, gi, light, lightingControl);
    
    UNITY_BRANCH
    if(Prop_RimToggle)
    {
        Rim rimParam;
        rimParam.ColorFront = _RimColorFront.rgb;
        rimParam.ColorBack = _RimColorBack.rgb;
        rimParam.Offset = Prop_RimOffset;
        rimParam.Smooth = Prop_RimSmooth;
        rimParam.Power = Prop_RimPower;
        color = ViewSpaceToneRim(rimParam, color, input.normalVS, input.viewDirVS, input.normalWS.xyz, surface.occlusion);
    }

    color += surface.emissive;

    color = MixBioumFogColor(color, input.positionWSAndFog.w);

    color = ApplyAttackFlash(color, surface.normal, surface.view);
    
    return half4(color, alpha);
}


#endif // BIOUM_CHARACTER_TONE_PASS_INCLUDE