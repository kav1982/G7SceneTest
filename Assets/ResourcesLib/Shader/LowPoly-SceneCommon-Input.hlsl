#ifndef LOWPOLY_SCENE_COMMON_INPUT_INCLUDE
#define LOWPOLY_SCENE_COMMON_INPUT_INCLUDE

#include "ShaderLibrary\Common.hlsl"

TEXTURE2D(_MainTex);    SAMPLER(sampler_MainTex);
TEXTURE2D(_AddtionTex); SAMPLER(sampler_AddtionTex);
TEXTURE2D(_MatCap);     SAMPLER(sampler_MatCap);
TEXTURE2D(_MaskMap);    SAMPLER(sampler_MaskMap);
TEXTURE2D(_NormalTex);  SAMPLER(sampler_NormalTex);
TEXTURE2D(_MAESTex);    SAMPLER(sampler_MAESTex);
TEXTURE2D(_LightMap);   SAMPLER(sampler_LightMap);
TEXTURE2D(_SkyTex);     SAMPLER(sampler_SkyTex);

//samplerCUBE _ReflectionMap;

half4 _MainColor;
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(half4, _MainTex_ST)
UNITY_DEFINE_INSTANCED_PROP(half4, _EmiColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _AddtionColor)
UNITY_DEFINE_INSTANCED_PROP(half, _AddtionStrength)
UNITY_DEFINE_INSTANCED_PROP(half, _ReflectionStrength)
UNITY_DEFINE_INSTANCED_PROP(half, _AOStrength)
UNITY_DEFINE_INSTANCED_PROP(half, _LightMapStrength)
UNITY_DEFINE_INSTANCED_PROP(half, _SmoothnessMin)
UNITY_DEFINE_INSTANCED_PROP(half, _SmoothnessMax)
UNITY_DEFINE_INSTANCED_PROP(half, _Metallic)
UNITY_DEFINE_INSTANCED_PROP(half, _NormalScale)
UNITY_DEFINE_INSTANCED_PROP(half, _Cutoff)
UNITY_DEFINE_INSTANCED_PROP(half, _Transparent)
UNITY_DEFINE_INSTANCED_PROP(half, _FresnelStrength)
UNITY_DEFINE_INSTANCED_PROP(half, _MixLerp)
UNITY_DEFINE_INSTANCED_PROP(half, _MatStrength)
UNITY_DEFINE_INSTANCED_PROP(half, _SkyTile)
UNITY_DEFINE_INSTANCED_PROP(half, _SkyStrength)
UNITY_DEFINE_INSTANCED_PROP(half, _SkyDistort)
UNITY_DEFINE_INSTANCED_PROP(half, _CloudSpeed)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// CBUFFER_START(UnityPerMaterial)
// half4 _MainTex_ST;
// half4 _EmiColor;
// half4 _LightMapColor;
// half _ReflectionStrength;
// half _AOStrength;
// half _SmoothnessMin;
// half _SmoothnessMax;	
// half _Metallic;
// half _NormalScale;
// half _Cutoff;
// half _Transparent;
// half _FresnelStrength;
// CBUFFER_END

half2 GetBaseUV(half2 texcoord)
{
    half4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MainTex_ST);
    return texcoord * baseST.xy + baseST.zw;
}


half4 sampleBaseMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);	
    map.a *= UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Transparent);

    #if defined(UNITY_COLORSPACE_GAMMA) && !defined(BIOUM_ADDPASS)
        map = SRGBToLinear(map);
    #endif
    
    return map;
}

half3 GetEmission()
{
    half4 emiColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _EmiColor);
    return emiColor.rgb;
}

half3 GetAddtionColor()
{
    half4 addtionColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _AddtionColor);
    //addtionColor.rgb *= UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _AddtionStrength);
    return addtionColor.rgb;
}


half4 GetMAES(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_MAESTex, sampler_MAESTex, uv);
    return map;
}

half4 GetSKY(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_SkyTex, sampler_SkyTex, uv);
    return map;
}

half4 GetAddtionTex(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_AddtionTex, sampler_AddtionTex, uv);
    return map;
}

half3 GetNormalMap(half2 uv)
{    
    half4 normalTex = SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, uv);
    half scale = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalScale);
    half3 normal = UnpackNormalScale(normalTex, scale);
    
	return normal;
}

half4 GetLightMap(half2 uv)
{    
    half4 map = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, uv);   
	map.rgb *= (_MainColor.rgb +0.11);
	//map.rgb = lerp(map.rgb, 0.4, _LightMapStrength);
    map.a = lerp(1, map.a, UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _AOStrength));

    #if defined(UNITY_COLORSPACE_GAMMA)
        map = SRGBToLinear(map);
    #endif
    return map;
}

half GetFresnelStrength()
{
    return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _FresnelStrength);
}

half GetCutoff()
{
    return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff);
}

#endif //SCENE_COMMON_INPUT_INCLUDE