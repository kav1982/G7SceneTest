#ifndef BIOUM_COMMON_INPUT_INCLUDE
#define BIOUM_COMMON_INPUT_INCLUDE

#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/SurfaceStruct.hlsl"

CBUFFER_START(UnityPerMaterial)
half4 _BaseColor;
half4 _SSSColor;
half4 _EmissiveColor;
half4 _PenumbraTintColor;

half4 _IndirectParam;

half4 _RimColorFront;
half4 _RimColorBack;
half4 _RimParam;

half4 _LightControlParam;

half4 _DissolveParam;
half4 _DissolveEdgeColor;

half4 _BattleParam;
half4 _OutlineColor;
CBUFFER_END

#define Prop_AOStrength _IndirectParam.x
#define Prop_FresnelStrength _IndirectParam.y
#define Prop_F0Strength _IndirectParam.z

#define Prop_RimOffset _RimParam.zw
#define Prop_RimSmooth _RimParam.x
#define Prop_RimPower _RimParam.y
#define Prop_RimToggle _RimColorFront.w != 0

#define Prop_LightIntensity _LightControlParam.x
#define Prop_SmoothDiff _LightControlParam.y
#define Prop_NormalScale _LightControlParam.z
#define Prop_Smoothness _LightControlParam.w

#define Prop_DissolveFactor _DissolveParam.x
#define Prop_DissolveEdge _DissolveParam.y
#define Prop_DissolveAni _DissolveParam.z
#define Prop_DissolveScale _DissolveParam.w
#define Prop_DissolveToggle Prop_DissolveFactor.x > 0.05

#define Prop_DitherTransparent _BattleParam.x
#define Prop_AttackFlash _BattleParam.y

#define Prop_UseGlobalLightingControl (_BaseColor.w != 0)

#define Prop_EmissiveColor _EmissiveColor.rgb


TEXTURE2D(_BaseMap); 
TEXTURE2D(_NormalAOSmoothMap); 
TEXTURE2D(_EmissiveMap); 
SAMPLER(sampler_BaseMap);

void ApplyDitherTransparent(float2 positionCS)
{
    UNITY_BRANCH
    if(Prop_DitherTransparent > 0.05)
    {
        half dither = GetCheckerBoardDither(positionCS);
        clip(dither - Prop_DitherTransparent);
    }
}
half3 ApplyAttackFlash(half3 color, half3 normalWS, half3 viewWS)
{
    UNITY_BRANCH
    if(Prop_AttackFlash > 0.05)
    {
        half rim = 1 - saturate(dot(normalWS, viewWS));
        rim = rim * rim * rim * Prop_AttackFlash;
        color += rim * 5;
    }
    return color;
}

half4 sampleBaseMap(float2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    map.rgb *= _BaseColor.rgb;
    return map;
}

half3 sampleNormalAOSmoothMap(half2 uv, out half2 smoothAO)
{
    half4 map = SAMPLE_TEXTURE2D(_NormalAOSmoothMap, sampler_BaseMap, uv);

    half2 data = 0;
    half3 normalTS = UnpackNormalAndData(map, Prop_NormalScale, data);

    half ao = LerpWhiteTo(data.y, Prop_AOStrength);
    half smooth = Prop_Smoothness * data.x;
    smoothAO = half2(smooth, ao);

    return normalTS;
}

half3 GetEmissiveColor()
{
    return Prop_EmissiveColor;
}
half4 sampleEmissiveMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_EmissiveMap, sampler_BaseMap, uv);
    map.rgb *= GetEmissiveColor();
    return map;
}

void ApplyDissolve(inout half3 albedo, half noise)
{
    UNITY_BRANCH
    if(Prop_DissolveToggle)
    {
        half edge = lerp(0, Prop_DissolveEdge, min(1, Prop_DissolveFactor * 5));
        half2 ClipAreaAndEdge = step(0, half2(noise, noise - edge));
			
        albedo = lerp(_DissolveEdgeColor.rgb, albedo, ClipAreaAndEdge.y);

        clip(ClipAreaAndEdge.x - 0.5);
    }
}

half GetFresnel()
{
    return Prop_FresnelStrength;
}

half GetF0Strength()
{
    return Prop_F0Strength;
}

half3 GetSSSColor()
{
    return _SSSColor.rgb;
}

half3 GetPenumbraTintColor()
{
    return _PenumbraTintColor.rgb;
}


#endif //BIOUM_COMMON_INPUT_INCLUDE