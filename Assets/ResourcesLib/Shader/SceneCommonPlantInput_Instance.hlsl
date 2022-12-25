//#ifndef BIOUM_SIMPLELIT_INPUT_INCLUDE
//#define BIOUM_SIMPLELIT_INPUT_INCLUDE

#include "ShaderLibrary/Common.hlsl"

//Constant Buffers

half4 _BaseColor;
half4 _PenumbraTintColor;
half4 _EmissiveColor;
half4 _NormalAOParam;
half4 _TransparentParam;
half4 _TerrainBlendParam;
//half4 _WindParam;
//half4 _EdgeParam;
//half4 _EdgeColor;
half4 _DarkParam;
half4 _DarkPartColor;
half4 _ButGradientParam;
half4 _ButGradientCol;
//half4 _SSSColor;

UNITY_INSTANCING_BUFFER_START(WindBuffer)
  UNITY_DEFINE_INSTANCED_PROP(half4,_WindParam)
UNITY_INSTANCING_BUFFER_END(WindBuffer)

#define Prop_NormalScale _NormalAOParam.x
#define Prop_AOStrength _NormalAOParam.y
#define Prop_UseUV2 _NormalAOParam.z

#define Prop_Transparent _TransparentParam.x
#define Prop_Cutoff _TransparentParam.y

//#define Prop_EdgeMaskScale _EdgeParam.x
//#define Prop_EdgeThred _EdgeParam.y
//#define Prop_EdgePow _EdgeParam.z
//#define Prop_EdgeAngle _EdgeParam.w
#define Prop_EdgeAngleScale _TerrainBlendParam.z
#define Prop_EdgeColor _EdgeColor

#define Prop_DarkPartColor _DarkPartColor
#define Prop_Contrast _DarkParam.x
#define Prop_DarkLigthIntensity _DarkParam.y
#define Prop_YClip _DarkParam.z
#define Prop_YAtten _DarkParam.w

#define Prop_ButGradientIntensity _ButGradientParam.x
#define Prop_YClipBut _ButGradientParam.y
#define Prop_YAttenBut _ButGradientParam.z
#define Prop_ButGradientCol _ButGradientCol


bool GetWindToggle()
{
    return _TransparentParam.z;
}
#define Prop_WindToggle GetWindToggle()

#define Prop_WindParam UNITY_ACCESS_INSTANCED_PROP(WindBuffer,_WindParam)
#define Prop_WindFalloff input.color.r

#define Prop_BaseColor _BaseColor
#define Prop_EmissiveColor _EmissiveColor
//#define Prop_SSSColor _SSSColor
#define Prop_PenumbraTintColor _PenumbraTintColor


#define Prop_TerrainBlendHeight _TerrainBlendParam.x
#define Prop_TerrainBlendFalloff _TerrainBlendParam.y

half _EdgeMask;

TEXTURE2D(_BaseMap);
//TEXTURE2D(_MaskMap);
//TEXTURE2D(_NormalMetalSmoothMap);
TEXTURE2D(_EmissiveAOMap);
SAMPLER(sampler_BaseMap);
//SAMPLER(sampler_MaskMap);

half4 sampleBaseMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    map.rgb *= Prop_BaseColor.rgb;
    return map;
}

/*void sampleMaskMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv);
    _EdgeMask = map.r;
}*/

/*half3 sampleNormalMetalSmoothMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_NormalMetalSmoothMap, sampler_BaseMap, uv);
    half2 data = 0;
    half3 normalTS = UnpackNormalAndData(map, Prop_NormalScale, data);
    return normalTS;
}*/

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

   /*half3 brightCol = 0;
   half3 addCol = lerp(brightCol,darkPartData.darkPartCol,darkPlace);
   addCol *= darkPartData.Intensity * YClip;
   sourceCol += addCol;*/
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


//#endif //BIOUM_COMMON_INPUT_INCLUDE