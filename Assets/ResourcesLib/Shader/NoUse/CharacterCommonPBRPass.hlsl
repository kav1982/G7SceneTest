#ifndef BIOUM_CHARACTER_COMMON_PASS_INCLUDE
#define BIOUM_CHARACTER_COMMON_PASS_INCLUDE

#include "../ShaderLibrary/LightingCharacter.hlsl"
#include "../ShaderLibrary/Fog.hlsl"

struct Attributes
{
    float4 positionOS: POSITION;
    real3 normalOS: NORMAL;
    real4 tangentOS: TANGENT;
    real2 texcoord: TEXCOORD0;
    real2 texcoord1: TEXCOORD1;
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

#if defined(_HIGH_QUALITY) || defined(_MEDIUM_QUALITY)
    real3 normalVS : TEXCOORD8;
    real4 viewDirVS : TEXCOORD9;
#endif
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
    output.uv.zw = Prop_UseUV2 != 0 ? input.texcoord1 : input.texcoord;
    
    OUTPUT_GI_SH(output.normalWS.xyz, output.vertexSH.xyz);
    OUTPUT_SHADOWCOORD(positionWS, output.positionCS, output.shadowCoord);
    OUTPUT_VERTEX_LIGHTING(output.normalWS.xyz, positionWS, output.vertexLighting);
    
    output.positionWSAndFog.w = ComputeBioumFogFactor(output.positionCS.z, positionWS.y);

#if defined(_HIGH_QUALITY) || defined(_MEDIUM_QUALITY)
    UNITY_BRANCH
    if(Prop_RimToggle)
    {
        real3 lightDirVS = TransformWorldToViewDir(MainLightDirection(), false);
        output.viewDirVS.xyz = TransformWorldToViewDir(viewDirWS, false);
        output.viewDirVS.w = lightDirVS.x;
        output.normalVS = TransformWorldToViewDir(output.normalWS.xyz, false);
    }
#endif

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
    Surface surface = (Surface)0;
    surface.albedo = sampleBaseMap(input.uv.xy);
    
    ApplyDitherTransparent(input.positionCS.xy);
    ApplyDissolve(surface.albedo.rgb, input.vertexSH.w);

#if _ALPHATEST_ON
    clip(surface.albedo.a - GetCutoff());
#endif
    

    half2 smoothMetallic = half2(Prop_Smoothness, Prop_Metallic);
#if _NORMALMAP
    half3 normalTS = sampleNormalMetalSmoothMap(input.uv.xy, smoothMetallic);
    half3x3 TBN = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    half3 normalWS = mul(normalTS, TBN);
    half3 viewDirWS = half3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
#else
    half3 normalWS = input.normalWS;
    half3 viewDirWS = input.viewDirWS;
#endif
    surface.normal = normalize(normalWS);
    surface.view = normalize(viewDirWS);
    
    surface.metallic = smoothMetallic.y;
    surface.smoothness = smoothMetallic.x;
    surface.F0Tint = GetF0Tint();
    surface.F0Strength = GetF0Strength();
    surface.position = input.positionWSAndFog.xyz;
    surface.fresnelStrength = GetFresnel();
    surface.penumbraTint = GetPenumbraTintColor();
    surface.specularColor = _SpecularColor.rgb;

    half4 emissiveAO = half4(GetEmissiveColor(), 1);
#if _EMISSIVE_AO_MAP
    emissiveAO = sampleEmissiveAOMap(input.uv.zw);
#endif
    surface.occlusion = emissiveAO.a;
    surface.emissive = emissiveAO.rgb;
    
    VertexData vertexData = (VertexData)0;
    vertexData.lighting = GET_VERTEX_LIGHTING(input.vertexLighting);
    vertexData.shadowCoord = GET_SHADOW_COORD(input.shadowCoord, surface.position);
    
    half alpha = GetTransparent() * surface.albedo.a;
    BRDF brdf = GetBRDF(surface, alpha);
    GI gi = GET_GI(0, input.vertexSH.rgb, surface, brdf.perceptualRoughness);

    LightingControl lightingControl = InitLightingControl(); 
    lightingControl.intensity = Prop_LightIntensity;
    lightingControl.smoothDiff = Prop_SmoothDiff;
    lightingControl.useCustomLighting = Prop_UseGlobalLightingControl;
    
    SubSurface sss;
    sss.color = GetSSSColor().rgb;
    sss.occlusionMode = 0;
    sss.doToneMapping = true;
    sss.normal = input.normalWS.xyz;

    Light light = GetMainLight(surface.position, vertexData.shadowCoord, gi);
    half3 color = LightingPBR(surface, sss, brdf, vertexData.lighting, gi, light, lightingControl);

#if defined(_HIGH_QUALITY) || defined(_MEDIUM_QUALITY)
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
#endif

    color += surface.emissive;

    color = MixBioumFogColor(color, input.positionWSAndFog.w);

    color = ApplyAttackFlash(color, surface.normal, surface.view);
    
    return half4(color, alpha);
}


#endif // BIOUM_CHARACTER_COMMON_PASS_INCLUDE