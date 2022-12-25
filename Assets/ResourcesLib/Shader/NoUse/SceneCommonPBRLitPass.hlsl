#ifndef BIOUM_SCENE_COMMON_PASS_INCLUDE
#define BIOUM_SCENE_COMMON_PASS_INCLUDE

#include "../ShaderLibrary/LightingCommon.hlsl"
#include "../ShaderLibrary/Fog.hlsl"

struct Attributes
{
    float3 positionOS: POSITION;
    real3 normalOS: NORMAL;
    real4 tangentOS: TANGENT;
    real2 texcoord: TEXCOORD0;
    real2 lightmapUV: TEXCOORD1;
    half4 color: COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    real4 uv: TEXCOORD0;
    DECLARE_GI_DATA(lightmapUV, vertexSH, 1);
    float4 positionWSAndFog: TEXCOORD2;
    
#if _NORMALMAP || _NORMALMAP_SNOW
    real4 tangentWS: TEXCOORD4;    // xyz: tangent, w: viewDir.x
    real4 bitangentWS: TEXCOORD5;    // xyz: binormal, w: viewDir.y
    real4 normalWS: TEXCOORD3;    // xyz: normal, w: viewDir.z
#else
    real3 normalWS: TEXCOORD3;
    real3 viewDirWS: TEXCOORD4;
#endif
    
    DECLARE_VERTEX_LIGHTING(vertexLighting, 6)
    DECLARE_SHADOWCOORD(shadowCoord, 7)

#if _RIM
    real3 normalVS : TEXCOORD8;
    real4 viewDirVS : TEXCOORD9;
#endif

#if _PLANAR_REFLECTION
    float4 positionNDC : TEXCOORD10;
#endif
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

Varyings CommonLitVert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

#if defined(_HIGH_QUALITY) || defined(_MEDIUM_QUALITY)
    UNITY_BRANCH
    if(Prop_WindToggle)
    {
        positionWS.xz += PlantsAnimationNoise(positionWS, Prop_WindParam, Prop_WindFalloff);
    }
#endif
    
    output.positionWSAndFog.xyz = positionWS;
    output.positionCS = TransformWorldToHClip(positionWS);
    
    half3 viewDirWS = _WorldSpaceCameraPos.xyz - positionWS;
#if _NORMALMAP || _NORMALMAP_SNOW
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.tangentWS = half4(normalInput.tangentWS, viewDirWS.x);
    output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.y);
    output.normalWS = half4(normalInput.normalWS, viewDirWS.z);
#else
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.viewDirWS = viewDirWS;
#endif
    
    output.uv.xy = input.texcoord;
    output.uv.zw = Prop_UseUV2 != 0 ? input.lightmapUV : input.texcoord;
    
    OUTPUT_GI_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_GI_SH(output.normalWS.xyz, output.vertexSH);
    OUTPUT_SHADOWCOORD(positionWS, output.positionCS, output.shadowCoord);
    OUTPUT_VERTEX_LIGHTING(output.normalWS.xyz, positionWS, output.vertexLighting);
    
    //output.positionWSAndFog.w = ComputeFogFactor(output.positionCS.z);
    output.positionWSAndFog.w = ComputeBioumFogFactor(output.positionCS.z, positionWS.y);
    
#if _RIM
    real3 lightDirVS = TransformWorldToViewDir(MainLightDirection(), false);
    output.viewDirVS.xyz = TransformWorldToViewDir(viewDirWS, false);
    output.viewDirVS.w = lightDirVS.x;
    output.normalVS = TransformWorldToViewDir(output.normalWS.xyz, false);
#endif

#if _PLANAR_REFLECTION
    output.positionNDC = ComputePositionNDC(output.positionCS);
#endif

    return output;
}

half4 CommonLitFrag(Varyings input): SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    
    Surface surface = (Surface)0;
    surface.albedo = sampleBaseMap(input.uv.xy);
#if _ALPHATEST_ON
    clip(surface.albedo.a - GetCutoff());
#endif

#if _SNOW
    half3 snowColor = Prop_SnowColor;
    half2 snowUV = input.positionWSAndFog.xz * Prop_SnowNormalTilling;
    half snowSmoothness = Prop_SnowSmoothness;
    half snowMaskTex = 1;
    half3 snowNormalTS = half3(0,0,1);
    #if _NORMALMAP_SNOW
        snowNormalTS = sampleSnowNormalMap(snowUV, snowSmoothness, snowMaskTex);
    #endif
    half snowMask = smoothstep(Prop_SnowMaskEdge, 1 - Prop_SnowMaskEdge, saturate(input.normalWS.y - Prop_SnowMaskRange));
    snowMask *= snowMaskTex;
    surface.albedo.rgb = lerp(surface.albedo.rgb, snowColor, snowMask);
#endif
    
    half3 normalTS = half3(0,0,1);
    half2 metalSmooth = half2(Prop_Metallic, Prop_Smoothness);
#if _NORMALMAP
    normalTS = sampleNormalMetalSmoothMap(input.uv.xy, metalSmooth);
#endif

#if _NORMALMAP || _NORMALMAP_SNOW
    #if _SNOW
        normalTS = lerp(normalTS, snowNormalTS, snowMask);
    #endif
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    half3 normalWS = mul(normalTS, tangentToWorld);
    half3 viewDirWS = half3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
#else
    half3 normalWS = input.normalWS.xyz;
    half3 viewDirWS = input.viewDirWS;
#endif
    surface.normal = normalize(normalWS);
    surface.view = normalize(viewDirWS);
    surface.metallic = metalSmooth.x;
    surface.smoothness = metalSmooth.y;
    
#if _SNOW
    surface.metallic = lerp(surface.metallic, 0, snowMask);
    surface.smoothness = lerp(surface.smoothness, Prop_SnowSmoothness, snowMask);
#endif

    half4 emissiveAO = half4(GetEmissiveColor(), 1);
#if _EMISSIVE_AO_MAP
    emissiveAO = sampleEmissiveAOMap(input.uv.zw);
#endif
    surface.occlusion = emissiveAO.a;
    surface.emissive = emissiveAO.rgb;
    
    surface.F0Tint = GetF0Tint();
    surface.F0Strength = GetF0Strength();
    surface.position = input.positionWSAndFog.xyz;
    surface.fresnelStrength = GetFresnel();
    surface.penumbraTint = GetPenumbraTintColor().rgb;
    surface.specularColor = Prop_SpecularColor.rgb;


    SubSurface sss = (SubSurface)0;
    sss.color = GetSSSColor().rgb;
    half4 sssParam = GetSSSParam();
    sss.doToneMapping = true;
    sss.occlusionMode = sssParam.y;
    sss.normal = input.normalWS.xyz;

    VertexData vertexData = (VertexData)0;
    vertexData.lighting = GET_VERTEX_LIGHTING(input.vertexLighting);
    vertexData.shadowCoord = GET_SHADOW_COORD(input.shadowCoord, surface.position);
   
    half alpha = GetTransparent() * surface.albedo.a;
    BRDF brdf = GetBRDF(surface, alpha);
    GI gi = GET_GI(input.lightmapUV, input.vertexSH, surface, brdf.perceptualRoughness);

#if _PLANAR_REFLECTION
    float2 ssuv = input.positionNDC.xy / input.positionNDC.w;
    gi.specular = ApplyPlanarReflection(gi.specular, ssuv, brdf.perceptualRoughness);
#endif

    Light mainLight = GetMainLight(surface.position, vertexData.shadowCoord, gi);
    half3 color = LightingPBR(surface, sss, brdf, vertexData, gi, mainLight);

#if _RIM
    Rim rimParam;
    rimParam.ColorFront = Prop_RimColorFront.rgb;
    rimParam.ColorBack = Prop_RimColorBack.rgb;
    rimParam.Offset = Prop_RimOffset;
    rimParam.Smooth = Prop_RimSmooth;
    rimParam.Power = Prop_RimPower;
    color = ViewSpaceToneRim(rimParam, color, input.normalVS, input.viewDirVS, input.normalWS.xyz, surface.occlusion);
#endif

    color += surface.emissive;

    //color = MixFog(color, input.positionWSAndFog.w);
    color = MixBioumFogColor(color, input.positionWSAndFog.w);

    color = ApplySceneDarkness(color);
    
    return half4(color, alpha);
}

#endif // BIOUM_SCENE_COMMON_PASS