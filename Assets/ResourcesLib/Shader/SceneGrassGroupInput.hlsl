#ifndef BIOUM_COMMON_INPUT_INCLUDE
#define BIOUM_COMMON_INPUT_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShaderLibrary/Color.hlsl"

half4 _PenumbraTintColor;

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(half4, _Color)
//UNITY_DEFINE_INSTANCED_PROP(float, _XOffset)
//UNITY_DEFINE_INSTANCED_PROP(float, _YOffset)
UNITY_DEFINE_INSTANCED_PROP(half4, _BaseMap_ST)
UNITY_DEFINE_INSTANCED_PROP(float, _GroundInfluence)
UNITY_DEFINE_INSTANCED_PROP(half4, _SpecularColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _LightingParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _LightColorControl)
UNITY_DEFINE_INSTANCED_PROP(half4, _WindParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _FalloffParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _EmissiveColor)
UNITY_DEFINE_INSTANCED_PROP(float, _SmoothDiff)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#define Prop_Color UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color)
#define Prop_SpecularColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SpecularColor)
#define Prop_EmissiveColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _EmissiveColor)

//#define Prop_XOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _XOffset)
//#define Prop_YOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _YOffset)
#define Prop_MapSTXY UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST).xy
#define Prop_MapSTZW UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST).zw

#define Prop_GroundInfluence UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _GroundInfluence)

#define Prop_NormalWarp UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _LightingParam).x
#define Prop_Smoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _LightingParam).y

#define Prop_WindDirection UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _WindParam).xy
#define Prop_WindSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _WindParam).z
#define Prop_WindScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _WindParam).w

#define Prop_ColorFalloff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _FalloffParam).x
#define Prop_WindFalloff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _FalloffParam).y


TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);
TEXTURE2D(_PigmentMap);     SAMPLER(sampler_PigmentMap);

#define _BASEMAP_ST half4(1,1,0,0)

float4 _PigmentTrans, _MainColor;//downleft + size
half _XOffset;
half _YOffset;


half GetCustomShadowBias()
{
    return 1;
}

half4 sampleBaseMap(float2 uv, bool needConvert = true)
{
    half4 map = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
    map.rgb *= Prop_Color.rgb;
    //map.a += Prop_Color.a;
    // if(needConvert)
    //     map.rgb = ColorSpaceConvertInput(map.rgb);

    return map;
}

half4 samplePigmentMap(float2 uv)
{
    #if _GAME_POS
        half4 map = SAMPLE_TEXTURE2D(_PigmentMap, sampler_PigmentMap, uv*6);
    #else
        half4 map = SAMPLE_TEXTURE2D(_PigmentMap, sampler_PigmentMap, uv);
    #endif
        
    return map;
}

half GetCutoff()
{
    return Prop_Color.a;
}

// float2 GetWorldOffset()
// {
//     return float2(Prop_XOffset, Prop_YOffset);
// }

float GetGroundInfluence()
{
    return Prop_GroundInfluence;
}

half GetSmoothness()
{
    return Prop_Smoothness;
}
half GetNormalWarp()
{
    return Prop_NormalWarp;
}
half GetColorFalloff()
{
    return Prop_ColorFalloff;
}

half2 GetWindDirection()
{
    return Prop_WindDirection;
}
half GetWindSpeed()
{
    return Prop_WindSpeed;
}
half GetWindScale()
{
    return Prop_WindScale;
}
half GetWindFalloff()
{
    return Prop_WindFalloff;
}
half3 GetPenumbraTintColor()
{
    return _PenumbraTintColor.rgb;
}


half GetMetaPassEmissiveMask(half2 uv)
{
    return 1;
}
half3 GetEmissiveColor()
{
    return Prop_EmissiveColor.rgb;
}
half GetEmissiveBoost()
{
    return Prop_EmissiveColor.a;
}

half2 GetBaseUV(half2 uv)
{
    return uv * Prop_MapSTXY + Prop_MapSTZW;
}

half3 sampleEmissive(half3 baseColor, half mask)
{
    return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _EmissiveColor.rgb) * baseColor * mask;
}


#endif //BIOUM_COMMON_INPUT_INCLUDE