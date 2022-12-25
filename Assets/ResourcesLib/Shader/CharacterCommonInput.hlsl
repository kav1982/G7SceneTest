#ifndef BIOUM_COMMON_INPUT_INCLUDE
#define BIOUM_COMMON_INPUT_INCLUDE

#include "ShaderLibrary/Common.hlsl"

CBUFFER_START(UnityPerMaterial)
half4 _BaseColor;
half4 _SSSColor;
half4 _EmissiveColor;
half4 _PenumbraTintColor;
half4 _SpecularColor;
#if _OUT_LINE
float _OutLineMul;
float _OutLineAdd;
real3 _OutLineCol;
#endif
real _reflectionRat;
half _reflectionPow;
real _SmoothReflection;

half4 _IndirectParam;
half4 _TransparentParam;

half4 _LightControlParam;

float _DissolveAmount;
half4 _DissoloveParam1;
half4 _DissoloveParam2;
half4 _DissolveEdgeColor;
half4 _BattleParam;


CBUFFER_END

//#define Prop_NormalScale _IndirectParam.x
#define Prop_AOStrength _IndirectParam.y
#define Prop_UseUV2 _IndirectParam.z
//#define Prop_ColorRat _IndirectParam.w

#define Prop_Transparent _TransparentParam.x
#define Prop_Cutoff _TransparentParam.y

#define Prop_LightIntensity _LightControlParam.x
#define Prop_SmoothDiff _LightControlParam.y
#define Prop_LightOffset _LightControlParam.z

#define _NoiseTile _DissoloveParam1.x
#define _NoiseSpeed _DissoloveParam1.y
#define _ExpandWidth _DissoloveParam1.z
#define _ClipWidth _DissoloveParam1.w
#define _ClipPow _DissoloveParam2.x
#define _DissolveScale _DissoloveParam2.y
#define _DissolveEdgeColStrength _DissoloveParam2.z
#define _DissolveEdgePow _DissoloveParam2.w

#define Prop_DitherTransparent _BattleParam.x
#define Prop_AttackFlash _BattleParam.y


//#define Prop_UseGlobalLightingControl (_BaseColor.w != 0)

TEXTURE2D(_BaseMap); 
TEXTURE2D(_BrushTex);
TEXTURE2D(_EmissiveAOMap);
//TEXTURE2D(_NormalMap);
TEXTURE2D(_DissolveNoiseTex);
SAMPLER(sampler_BaseMap);
SAMPLER(sampler_BrushTex);
SAMPLER(sampler_DissolveNoiseTex);

half4 sampleBaseMap(float2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    map.rgb *= _BaseColor.rgb;
    return map;
}

half4 sampleBrushTex(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BrushTex, sampler_BrushTex, uv);
}

/*half3 sampleNormalMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_NormalMap, sampler_BaseMap, uv);
#if defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
    half3 normalTS = (map.xyz * 2.0 - 1.0);
#else
    half3 normalTS = half3(map.xy, 1);
    normalTS.xy = (normalTS * 2.0 - 1.0).xy;
#endif
    normalTS.xy *= Prop_NormalScale;

    return normalTS;
}*/

half3 GetEmissiveColor()
{
    return _EmissiveColor.rgb;
}
half4 sampleEmissiveAOMap(half2 uv)
{
    half4 map = SAMPLE_TEXTURE2D(_EmissiveAOMap, sampler_BaseMap, uv);
    map.rgb *= GetEmissiveColor();
    map.a = LerpWhiteTo(map.a, Prop_AOStrength);
    return map;
}
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

//特殊需要将计算拆解
half GetDissoloveArea(float3 positionOS)
{
    float realY = positionOS.y;
    half uparea = smoothstep(_DissolveAmount+_ClipWidth,_DissolveAmount,realY);
    half downarea = smoothstep(_DissolveAmount-_ClipWidth,_DissolveAmount,realY);
    return  uparea*downarea;
}


void ApplyDissolove(inout float3 color,half area,float3 positionOS,float3 normalOS)
{
    float realY = positionOS.y;
    half centerLine = step(realY - _DissolveAmount,0);
    float2 offset = float2(0,1);
    #if _DISSOLOVETURN
    centerLine = 1-centerLine;
    offset = -offset;
    #endif
    float3 normal = abs(normalOS);
    float3 posUV = positionOS * _NoiseTile;
    float noiseX = SAMPLE_TEXTURE2D(_DissolveNoiseTex,sampler_DissolveNoiseTex,posUV.zy + offset*_Time.x*_NoiseSpeed).r;
    float noiseY = SAMPLE_TEXTURE2D(_DissolveNoiseTex,sampler_DissolveNoiseTex,posUV.xz).r;
    float noiseZ = SAMPLE_TEXTURE2D(_DissolveNoiseTex,sampler_DissolveNoiseTex,posUV.xy + offset*_Time.x*_NoiseSpeed).r;
    float noise = 1-saturate(noiseX * normal.x + noiseY * normal.y + noiseZ * normal.z);
    float dis = abs(realY - _DissolveAmount);
    noise = pow(noise,_ClipPow);
    noise = area*noise + (1-area);
    float disapper = lerp(area,area-4*centerLine,dis);
    clip(noise*disapper-0.5*area);
    float edgeArea = saturate(1-Pow4(noise*_DissolveEdgePow));
    
    color = lerp(color,_DissolveEdgeColor.rgb* _DissolveEdgeColStrength,edgeArea);
}

half GetTransparent()
{
    return Prop_Transparent;
}

half GetCutoff()
{
    return Prop_Cutoff;
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