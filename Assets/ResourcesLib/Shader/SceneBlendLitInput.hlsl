#ifndef BIOUM_SIMPLELIT_INPUT_INCLUDE
#define BIOUM_SIMPLELIT_INPUT_INCLUDE

#include "ShaderLibrary/Common.hlsl"

//Constant Buffers


UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _PenumbraTintColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _EmissiveColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _SSSColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _NormalAOParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _TransparentParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _RimColorFront)
UNITY_DEFINE_INSTANCED_PROP(half4, _RimColorBack)
UNITY_DEFINE_INSTANCED_PROP(half4, _RimParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _TerrainBlendParam)
//UNITY_DEFINE_INSTANCED_PROP(half, _XOffset)
//UNITY_DEFINE_INSTANCED_PROP(half, _YOffset)
UNITY_DEFINE_INSTANCED_PROP(half4, _WindParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _DarkParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _DarkPartColor)
UNITY_DEFINE_INSTANCED_PROP(half4, _ButGradientParam)
UNITY_DEFINE_INSTANCED_PROP(half4, _ButGradientCol)
UNITY_DEFINE_INSTANCED_PROP(half4, _VertexAOCol)
UNITY_DEFINE_INSTANCED_PROP(half4, _VertexAOParam)
UNITY_DEFINE_INSTANCED_PROP(float, _TestValue)
UNITY_DEFINE_INSTANCED_PROP(float, _GroundInfluence)
UNITY_DEFINE_INSTANCED_PROP(float, _ColorFalloff)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#define Prop_NormalScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalAOParam).x
#define Prop_AOStrength UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalAOParam).y
#define Prop_UseUV2 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalAOParam).z

#define Prop_Transparent UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransparentParam).x
#define Prop_Cutoff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransparentParam).y

#define Prop_DarkPartColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _DarkPartColor)
#define Prop_Contrast UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _DarkParam).x
#define Prop_DarkLigthIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _DarkParam).y
#define Prop_YClip UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _DarkParam).z
#define Prop_YAtten UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _DarkParam).w

#define Prop_ButGradientIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ButGradientParam).x
#define Prop_YClipBut UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ButGradientParam).y
#define Prop_YAttenBut UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ButGradientParam).z
#define Prop_ButGradientCol UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ButGradientCol)
#define _VertexAOCol UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexAOCol)
#define _AOStrength UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexAOParam).x
#define _AOColStrength UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexAOParam).y

//#define Prop_GroundInfluence UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _GroundInfluence)
#define Prop_ColorFalloff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _ColorFalloff)



bool GetWindToggle()
{
    return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransparentParam).z;
}
#define Prop_WindToggle GetWindToggle()

#define Prop_WindParam UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _WindParam)
#define Prop_WindFalloff input.color.r

#define Prop_BaseColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor)
#define Prop_EmissiveColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _EmissiveColor)
#define Prop_SSSColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SSSColor)
#define Prop_PenumbraTintColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _PenumbraTintColor)

#define Prop_RimColorFront UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimColorFront)
#define Prop_RimColorBack UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimColorBack)
#define Prop_RimOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimParam).zw
#define Prop_RimSmooth UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimParam).x
#define Prop_RimPower UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _RimParam).y

#define Prop_TerrainBlendHeight UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TerrainBlendParam).x
#define Prop_TerrainBlendFalloff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TerrainBlendParam).y
//#define Prop_XOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TerrainBlendParam).z
//#define Prop_YOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TerrainBlendParam).w



float4 _PigmentTrans;
half _XOffset;
half _YOffset;

TEXTURE2D(_BaseMap);
TEXTURE2D(_PigmentMap);
TEXTURE2D(_NormalMetalSmoothMap);
TEXTURE2D(_EmissiveAOMap);
SAMPLER(sampler_BaseMap);
SAMPLER(sampler_PigmentMap);



half4 sampleBaseMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    map.rgb *= Prop_BaseColor.rgb;
    return map;
}

half4 samplePigmentMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_PigmentMap, sampler_PigmentMap, uv);
    return map;
}

half3 sampleNormalMetalSmoothMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_NormalMetalSmoothMap, sampler_BaseMap, uv);
    half2 data = 0;
    half3 normalTS = UnpackNormalAndData(map, Prop_NormalScale, data);
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

half3 GetPenumbraTintColor()
{
    return Prop_PenumbraTintColor.rgb;
}

struct DarkPartData
{
    half4 sourceAlbedo;
    half contrast;
	half3 darkPartCol;
	half Intensity;
	half3 positionOS;
	half YClip;
	half YAtten;
};

DarkPartData GetDarkPartData(half4 sourceAlbedo,half3 positionOS)
{
    DarkPartData darkPartData;
	darkPartData.sourceAlbedo = sourceAlbedo;
	darkPartData.contrast = Prop_Contrast;
	darkPartData.darkPartCol = Prop_DarkPartColor.rgb;
	darkPartData.Intensity = Prop_DarkLigthIntensity;
	darkPartData.positionOS = positionOS;
	darkPartData.YClip = Prop_YClip;
	darkPartData.YAtten = Prop_YAtten;
	return darkPartData;
}

// float GetGroundInfluence()
// {
//     return Prop_GroundInfluence;
// }

half GetColorFalloff()
{
    return Prop_ColorFalloff;
}

half pow4(half val)
{
   return val*val*val*val;
}

half3 AddDarkPartLight(half3 sourceCol,DarkPartData darkPartData)
{
   //darkPartData.darkPartCol = 1 - darkPartData.darkPartCol;
   half darkPlace = pow4(saturate(1-darkPartData.sourceAlbedo.r));
   darkPlace = saturate(darkPlace-darkPartData.contrast);
   half modelY = normalize(darkPartData.positionOS - half3(0,0,0)).y;
   modelY = pow(abs(modelY),darkPartData.YAtten);
   half YClip = smoothstep(darkPartData.YClip,1,modelY);
    
#if _ADDCOLOR
   half3 brightCol = 0;
   half3 addCol = lerp(brightCol,darkPartData.darkPartCol,darkPlace);
   addCol *= darkPartData.Intensity * YClip;
   sourceCol += addCol;
#else
   darkPlace = saturate(darkPlace * darkPartData.Intensity * YClip);
   sourceCol = lerp(sourceCol,darkPartData.darkPartCol,darkPlace);
#endif

   return sourceCol;
}

half3 AddButGradient(half3 sourceCol,half3 positionOS,half positionWSy)
{
   half modelY = normalize(positionOS - half3(0,0,0)).y;
   modelY = pow(abs(modelY),1/Prop_YAttenBut);
   half YClip = saturate(1-smoothstep(Prop_YClipBut,1,modelY));
   sourceCol = lerp(sourceCol,Prop_ButGradientCol.rgb * Prop_ButGradientIntensity,YClip);
   return sourceCol;
}


#endif //BIOUM_COMMON_INPUT_INCLUDE