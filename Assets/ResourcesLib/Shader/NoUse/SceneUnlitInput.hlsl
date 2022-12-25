#ifndef BIOUM_UNLIT_INPUT_INCLUDE
#define BIOUM_UNLIT_INPUT_INCLUDE

#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/SurfaceStruct.hlsl"
#include "../ShaderLibrary/Noise.hlsl"

//Constant Buffers 


CBUFFER_START(UnityPerMaterial)
half4 _BaseColor;
half4 _EmissiveColor;
half4 _UnlitShaderParam;
CBUFFER_END

#define Prop_Transparent _UnlitShaderParam.x
#define Prop_Cutoff _UnlitShaderParam.y
#define Prop_UseUV2 _UnlitShaderParam.z
#define Prop_FogIntensity _UnlitShaderParam.w

TEXTURE2D(_BaseMap);
TEXTURE2D(_EmissiveMap);
SAMPLER(sampler_BaseMap);

half4 sampleBaseMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    map.rgb *= _BaseColor.rgb;
    return map;
}

half3 GetEmissiveColor()
{
    return _EmissiveColor.rgb;
}
half4 sampleEmissiveMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_EmissiveMap, sampler_BaseMap, uv);
    map.rgb *= GetEmissiveColor();
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

#endif //BIOUM_COMMON_INPUT_INCLUDE