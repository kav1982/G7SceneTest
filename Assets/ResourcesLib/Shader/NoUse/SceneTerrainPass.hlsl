#ifndef BIOUM_TERRAIN_PASS_INCLUDE
#define BIOUM_TERRAIN_PASS_INCLUDE

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
    half4 uv01: TEXCOORD0;
    half4 uv23: TEXCOORD1;
    DECLARE_GI_DATA(lightmapUV, vertexSH, 2);
    float4 positionWSAndFog: TEXCOORD3;
    
#if _NORMALMAP
    half4 tangentWS: TEXCOORD4;    // xyz: tangent, w: viewDir.x
    half4 bitangentWS: TEXCOORD5;    // xyz: binormal, w: viewDir.y
    half4 normalWS: TEXCOORD6;    // xyz: normal, w: viewDir.z
#else
    half3 normalWS: TEXCOORD4;
    half3 viewDirWS: TEXCOORD5;
#endif
    
    DECLARE_VERTEX_LIGHTING(vertexLighting, 7)
    DECLARE_SHADOWCOORD(shadowCoord, 8)

    half4 controlMask: TEXCOORD9;

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
    output.positionWSAndFog.xyz = positionWS;
    output.positionCS = TransformWorldToHClip(positionWS);
    
    half3 viewDirWS = _WorldSpaceCameraPos.xyz - positionWS;
#if _NORMALMAP
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.tangentWS = half4(normalInput.tangentWS, viewDirWS.x);
    output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.y);
    output.normalWS = half4(normalInput.normalWS, viewDirWS.z);
#else
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.viewDirWS = viewDirWS;
#endif

    output.uv01 = positionWS.xzxz * Prop_Tilling.xxyy;
    output.uv23 = positionWS.xzxz * Prop_Tilling.zzww;
    output.controlMask = input.color;
    
    OUTPUT_GI_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_GI_SH(output.normalWS.xyz, output.vertexSH);
    OUTPUT_SHADOWCOORD(positionWS, output.positionCS, output.shadowCoord);
    OUTPUT_VERTEX_LIGHTING(output.normalWS.xyz, positionWS, output.vertexLighting);
    
    //output.positionWSAndFog.w = ComputeBioumFogFactor(output.positionCS.z, positionWS.y);
	output.positionWSAndFog.w = ComputeXYJFogFactor(ComputeScreenPos(output.positionCS / output.positionCS.w).xy, positionWS.y);

#if _PLANAR_REFLECTION
    output.positionNDC = ComputePositionNDC(output.positionCS);
#endif
    
    return output;
}

half4 CommonLitFrag(Varyings input): SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);

    half4 heightMap = 1;
#if _TERRAIN_2TEX
    half4 splat0 = sampleBaseMap(TEXTURE2D_ARGS(_Splat0, sampler_Splat0), input.uv01.xy, Prop_Color0.rgb);
    half4 splat1 = sampleBaseMap(TEXTURE2D_ARGS(_Splat1, sampler_Splat0), input.uv01.zw, Prop_Color1.rgb);
    heightMap.x = splat0.a; heightMap.y = splat1.a;
#elif _TERRAIN_3TEX
    half4 splat0 = sampleBaseMap(TEXTURE2D_ARGS(_Splat0, sampler_Splat0), input.uv01.xy, Prop_Color0.rgb);
    half4 splat1 = sampleBaseMap(TEXTURE2D_ARGS(_Splat1, sampler_Splat0), input.uv01.zw, Prop_Color1.rgb);
    half4 splat2 = sampleBaseMap(TEXTURE2D_ARGS(_Splat2, sampler_Splat0), input.uv23.xy, Prop_Color2.rgb);
    heightMap.x = splat0.a; heightMap.y = splat1.a; heightMap.z = splat2.a;
#elif _TERRAIN_4TEX
    half4 splat0 = sampleBaseMap(TEXTURE2D_ARGS(_Splat0, sampler_Splat0), input.uv01.xy, Prop_Color0.rgb);
    half4 splat1 = sampleBaseMap(TEXTURE2D_ARGS(_Splat1, sampler_Splat0), input.uv01.zw, Prop_Color1.rgb);
    half4 splat2 = sampleBaseMap(TEXTURE2D_ARGS(_Splat2, sampler_Splat0), input.uv23.xy, Prop_Color2.rgb);
    half4 splat3 = sampleBaseMap(TEXTURE2D_ARGS(_Splat3, sampler_Splat0), input.uv23.zw, Prop_Color3.rgb);
    heightMap.x = splat0.a; heightMap.y = splat1.a; heightMap.z = splat2.a; heightMap.w = splat3.a;
#endif
    
    half4 controlMask = ApplyHeightMap(input.controlMask, heightMap);
    
    half3 albedo = 0;
#if _TERRAIN_2TEX
    albedo += splat0.rgb * controlMask.r;
    albedo += splat1.rgb * controlMask.g;
#elif _TERRAIN_3TEX
    albedo += splat0.rgb * controlMask.r;
    albedo += splat1.rgb * controlMask.g;
    albedo += splat2.rgb * controlMask.b;
#elif _TERRAIN_4TEX
    albedo += splat0.rgb * controlMask.r;
    albedo += splat1.rgb * controlMask.g;
    albedo += splat2.rgb * controlMask.b;
    albedo += splat3.rgb * controlMask.a;
#endif
#ifdef _TERRAIN_BLEND
    //return half4(albedo, 1);
#endif
    
    half4 smoothness = Prop_Smoothness;
    half4 AO = 1;
#if _NORMALMAP
    half3 normalTS = 0;
    #if _TERRAIN_2TEX
        half3 mask0 = sampleMaskMap(TEXTURE2D_ARGS(_SplatMask0, sampler_Splat0), input.uv01.xy, 0, smoothness.x, AO.x);
        half3 mask1 = sampleMaskMap(TEXTURE2D_ARGS(_SplatMask1, sampler_Splat0), input.uv01.zw, 1, smoothness.y, AO.y);
        normalTS += mask0 * controlMask.r;
        normalTS += mask1 * controlMask.g;
    #elif _TERRAIN_3TEX
        half3 mask0 = sampleMaskMap(TEXTURE2D_ARGS(_SplatMask0, sampler_Splat0), input.uv01.xy, 0, smoothness.x, AO.x);
        half3 mask1 = sampleMaskMap(TEXTURE2D_ARGS(_SplatMask1, sampler_Splat0), input.uv01.zw, 1, smoothness.y, AO.y);
        half3 mask2 = sampleMaskMap(TEXTURE2D_ARGS(_SplatMask2, sampler_Splat0), input.uv23.xy, 2, smoothness.z, AO.z);
        normalTS += mask0 * controlMask.r;
        normalTS += mask1 * controlMask.g;
        normalTS += mask2 * controlMask.b;
    #elif _TERRAIN_4TEX
        half3 mask0 = sampleMaskMap(TEXTURE2D_ARGS(_SplatMask0, sampler_Splat0), input.uv01.xy, 0, smoothness.x, AO.x);
        half3 mask1 = sampleMaskMap(TEXTURE2D_ARGS(_SplatMask1, sampler_Splat0), input.uv01.zw, 1, smoothness.y, AO.y);
        half3 mask2 = sampleMaskMap(TEXTURE2D_ARGS(_SplatMask2, sampler_Splat0), input.uv23.xy, 2, smoothness.z, AO.z);
        half3 mask3 = sampleMaskMap(TEXTURE2D_ARGS(_SplatMask3, sampler_Splat0), input.uv23.zw, 3, smoothness.w, AO.w);
        normalTS += mask0 * controlMask.r;
        normalTS += mask1 * controlMask.g;
        normalTS += mask2 * controlMask.b;
        normalTS += mask3 * controlMask.a;
    #endif

    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    half3 normalWS = mul(normalTS, tangentToWorld);
    half3 viewDirWS = half3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
#else
    half3 normalWS = input.normalWS.xyz;
    half3 viewDirWS = input.viewDirWS.xyz;
#endif


    Surface surface = (Surface)0;
    surface.albedo = half4(albedo, 1);
    surface.normal = normalize(normalWS);
    surface.view = normalize(viewDirWS);
    surface.smoothness = dot(controlMask, smoothness);
    
    surface.occlusion = dot(controlMask, AO);
    surface.F0Tint = dot(controlMask, Prop_F0Tint);
    surface.F0Strength = dot(controlMask, Prop_F0Strength);
    surface.position = input.positionWSAndFog.xyz;
    surface.fresnelStrength = dot(controlMask, Prop_FresnelStrength);
    surface.penumbraTint = Prop_PenumbraTintColor;

    
    VertexData vertexData = (VertexData)0;
    vertexData.lighting = GET_VERTEX_LIGHTING(input.vertexLighting);
    vertexData.shadowCoord = GET_SHADOW_COORD(input.shadowCoord, surface.position);
   
    half alpha = 1;
    BRDF brdf = GetBRDF(surface, alpha);
    GI gi = GET_GI(input.lightmapUV, input.vertexSH, surface, brdf.perceptualRoughness);

#if _PLANAR_REFLECTION
    float2 ssuv = input.positionNDC.xy / input.positionNDC.w;
    gi.specular = ApplyPlanarReflection(gi.specular, ssuv, brdf.perceptualRoughness);
#endif

    SubSurface sss = (SubSurface)0;

    Light mainLight = GetMainLight(surface.position, vertexData.shadowCoord, gi);
    half3 color = LightingLambert(surface, sss, vertexData, gi, mainLight);

    //color = MixBioumFogColor(color, input.positionWSAndFog.w);
	color = MixXYJFogColor(color, input.positionWSAndFog.w);

    color = ApplySceneDarkness(color);
    
    return half4(color, alpha);
}


#endif // BIOUM_SCENE_COMMON_PASS