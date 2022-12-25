#ifndef BIOUM_COMMON_INPUT_INCLUDE
#define BIOUM_COMMON_INPUT_INCLUDE

#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/SurfaceStruct.hlsl"

CBUFFER_START(UnityPerMaterial)
half4 _BaseColor;
half4 _SSSColor;
half4 _PenumbraTintColor;
half4 _SpecColor;

half4 _IndirectParam;

half4 _HairLightingParam0;
half4 _HairLightingParam1;

half4 _LightControlParam;

half4 _RimColorFront;
half4 _RimColorBack;
half4 _RimParam;

half4 _DissolveParam;
half4 _DissolveEdgeColor;

half4 _BattleParam;
half4 _OutlineColor;
CBUFFER_END

#define Prop_AOStrength _IndirectParam.x
#define Prop_FresnelStrength _IndirectParam.y
#define Prop_F0Tint _IndirectParam.z
#define Prop_F0Strength _IndirectParam.w

#define Prop_RimOffset _RimParam.zw
#define Prop_RimSmooth _RimParam.x
#define Prop_RimPower _RimParam.y
#define Prop_RimToggle _RimColorFront.w != 0

#define Prop_LightIntensity _LightControlParam.x
#define Prop_SmoothDiff _LightControlParam.y
#define Prop_NormalScale _LightControlParam.z
bool IsTransparentMode()
{
    return _LightControlParam.w != 0;
}

#define Prop_SpecIntensity _HairLightingParam0.x
#define Prop_Shift _HairLightingParam0.y
#define Prop_Smoothness _HairLightingParam0.z
#define Prop_SwitchTangent _HairLightingParam0.w

#define Prop_SubSpecIntensity _HairLightingParam1.x
#define Prop_SubShift _HairLightingParam1.y
#define Prop_SubSmoothness _HairLightingParam1.z
#define Prop_DoubleSpecular _HairLightingParam1.w

#define Prop_DissolveFactor _DissolveParam.x
#define Prop_DissolveEdge _DissolveParam.y
#define Prop_DissolveAni _DissolveParam.z
#define Prop_DissolveScale _DissolveParam.w
#define Prop_DissolveToggle Prop_DissolveFactor.x > 0.05

#define Prop_DitherTransparent _BattleParam.x
#define Prop_AttackFlash _BattleParam.y

#define Prop_UseGlobalLightingControl (_BaseColor.w != 0)

TEXTURE2D(_BaseMap); 
TEXTURE2D(_NormalAOSmoothMap); 
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
    return map * _BaseColor;
}

half2 GetSmoothness()
{
    return half2(Prop_Smoothness, Prop_SubSmoothness);
}
half3 sampleNormalAOSmoothMap(half2 uv, out half2 smoothness, out half ao)
{
    half4 map = SAMPLE_TEXTURE2D(_NormalAOSmoothMap, sampler_BaseMap, uv);

    half2 data = 0;
    half3 normalTS = UnpackNormalAndData(map, Prop_NormalScale, data);

    ao = LerpWhiteTo(data.y, Prop_AOStrength);
    smoothness = GetSmoothness() * data.x;

    return normalTS;
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

half4 GetSSSColor()
{
    return _SSSColor;
}

half3 GetPenumbraTintColor()
{
    return _PenumbraTintColor.rgb;
}

half2 GetShift()
{
    return half2(Prop_Shift, Prop_SubShift);
}
half2 GetSpecIntensity()
{
    return half2(Prop_SpecIntensity, Prop_SubSpecIntensity);
}

#endif //BIOUM_COMMON_INPUT_INCLUDE