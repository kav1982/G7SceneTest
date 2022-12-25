#ifndef COMMOM_META_PASS_INCLUDED
#define COMMOM_META_PASS_INCLUDED


#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/LightingCommon.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"
#include "../ShaderLibrary/GI.hlsl"

struct Attributes 
{
    float3 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;
    float2 lightMapUV : TEXCOORD1;
    half4 color: COLOR;
};

struct Varyings 
{
    float4 positionCS : SV_POSITION;
    half4 uv01: TEXCOORD0;
    half4 uv23: TEXCOORD1;
    half4 controlMask: TEXCOORD2;
};

Varyings MetaPassVertex (Attributes input) 
{
    Varyings output;    
    input.positionOS.xy = input.lightMapUV * unity_LightmapST.xy + unity_LightmapST.zw;
    input.positionOS.z = input.positionOS.z > 0.0 ? HALF_MIN : 0.0;
    output.positionCS = TransformWorldToHClip(input.positionOS);

    output.uv01 = input.positionOS.xyxy;
    output.uv23 = input.positionOS.xyxy;
    output.controlMask = input.color;

    return output;
}

bool4 unity_MetaFragmentControl;
float unity_OneOverOutputBoost;
float unity_MaxOutputValue;
float4 MetaPassFragment (Varyings input) : SV_TARGET 
{
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
    
    Surface surface = (Surface)0;
    surface.albedo = half4(albedo, 1);
    surface.metallic = 0;
    surface.smoothness = 0.5;
    
    half alpha = 1;
    BRDF brdf = GetBRDF(surface, alpha);
    
    float3 meta = 0;
    if (unity_MetaFragmentControl.x) 
    {
        meta.rgb = brdf.diffuse + brdf.specular * brdf.roughness * 0.5;
        meta.rgb = min(PositivePow(meta.rgb, unity_OneOverOutputBoost), unity_MaxOutputValue);
    }

    return half4(meta, alpha);
}

#endif