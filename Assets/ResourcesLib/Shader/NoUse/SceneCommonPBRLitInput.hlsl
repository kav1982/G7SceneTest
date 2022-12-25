#ifndef BIOUM_COMMONLIT_INPUT_INCLUDE
#define BIOUM_COMMONLIT_INPUT_INCLUDE

#include "../ShaderLibrary/Common.hlsl"

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _PenumbraTintColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _SpecularColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _EmissiveColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _SSSColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _SSSParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _NormalMatelSmoothParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _IndirectParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _TransparentParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _RimColorFront)
UNITY_DEFINE_INSTANCED_PROP(half4, _RimColorBack)
UNITY_DEFINE_INSTANCED_PROP(half4, _RimParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _WindParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _SnowColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _SnowParam)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#define Prop_NormalScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalMatelSmoothParam).x
#define Prop_Metallic UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalMatelSmoothParam).y
#define Prop_Smoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalMatelSmoothParam).z
#define Prop_UseUV2 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalMatelSmoothParam).w

#define Prop_AOStrength UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _IndirectParam).x
#define Prop_FresnelStrength UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _IndirectParam).y
#define Prop_F0Tint UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _IndirectParam).z
#define Prop_F0Strength UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _IndirectParam).w

#define Prop_Transparent UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransparentParam).x
#define Prop_Cutoff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransparentParam).y

bool GetWindToggle()
{
    return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransparentParam).z;
}
#define Prop_WindToggle GetWindToggle()

#define Prop_WindParam UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _WindParam)
#define Prop_WindFalloff input.color.r

#define Prop_BaseColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor)
#define Prop_SpecularColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SpecularColor)
#define Prop_EmissiveColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _EmissiveColor)
#define Prop_PenumbraTintColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _PenumbraTintColor)
#define Prop_SSSColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SSSColor)
#define Prop_SSSParam UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SSSParam)

#define Prop_RimColorFront UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimColorFront)
#define Prop_RimColorBack UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimColorBack)
#define Prop_RimOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimParam).zw
#define Prop_RimSmooth UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimParam).x
#define Prop_RimPower UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimParam).y


#define Prop_SnowColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SnowColor).rgb
#define Prop_SnowSmoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SnowColor).a

#define Prop_SnowNormalTilling UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SnowParam).x
#define Prop_SnowNormalScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SnowParam).y
#define Prop_SnowMaskRange UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SnowParam).z
#define Prop_SnowMaskEdge UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SnowParam).w

TEXTURE2D(_BaseMap);
TEXTURE2D(_NormalMetalSmoothMap);
TEXTURE2D(_SnowNormalMap);
TEXTURE2D(_EmissiveAOMap);
SAMPLER(sampler_BaseMap);
SAMPLER(sampler_SnowNormalMap);

half4 sampleBaseMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    map.rgb *= Prop_BaseColor.rgb;
    return map;
}

half3 sampleNormalMetalSmoothMap(half2 uv, inout half2 metalSmooth)
{
    half4 map = SAMPLE_TEXTURE2D(_NormalMetalSmoothMap, sampler_BaseMap, uv);

    half2 data = 0;
    half3 normalTS = UnpackNormalAndData(map, Prop_NormalScale, data);

    metalSmooth *= data.yx;

    return normalTS;
}

half3 GetEmissiveColor()
{
    return Prop_EmissiveColor.rgb;
}
half GetEmissiveBoost()
{
    return Prop_EmissiveColor.a;
}

half4 sampleEmissiveAOMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_EmissiveAOMap, sampler_BaseMap, uv);
    map.rgb *= GetEmissiveColor();
    map.a = LerpWhiteTo(map.a, Prop_AOStrength);
    return map;
}

half3 sampleSnowNormalMap(half2 uv, inout half smoothness, out half snowMask)
{
    half4 map = SAMPLE_TEXTURE2D(_SnowNormalMap, sampler_SnowNormalMap, uv);

    half2 data = 0;
    half3 normalTS = UnpackNormalAndData(map, Prop_SnowNormalScale, data);

    smoothness *= data.x;
    snowMask = data.y;

    return normalTS;
}


half GetFresnel()
{
    return Prop_FresnelStrength;
}

half GetF0Tint()
{
    return Prop_F0Tint;
}

half GetF0Strength()
{
    return Prop_F0Strength;
}

half GetTransparent()
{
    return Prop_Transparent;
}

half GetCutoff()
{
    return Prop_Cutoff;
}

half4 GetSSSColor()
{
    return Prop_SSSColor;
}
half4 GetSSSParam()
{
    return Prop_SSSParam;
}

half3 GetPenumbraTintColor()
{
    return Prop_PenumbraTintColor.rgb;
}



#endif //BIOUProp_COMMON_INPUT_INCLUDE