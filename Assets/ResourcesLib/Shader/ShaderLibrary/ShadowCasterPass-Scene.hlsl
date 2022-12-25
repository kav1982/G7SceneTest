#ifndef BIOUM_SHADOW_CASTER_PASS_INCLUDED
#define BIOUM_SHADOW_CASTER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

#if _DITHER_CLIP//#if _ALPHATEST_ON || _DITHER_CLIP
#define SHOULD_SAMPLE_TEXTURE
#endif


#ifndef Prop_WindToggle
#define Prop_WindToggle false
#endif

#ifndef Prop_WindParam
#define Prop_WindParam half4(0,0,0,0)
#endif

#ifndef Prop_WindFalloff
#define Prop_WindFalloff 0
#endif



float3 _LightDirection;

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
#ifdef SHOULD_SAMPLE_TEXTURE
    float2 texcoord     : TEXCOORD0;
#endif
    
    half4 color : COLOR;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
#ifdef SHOULD_SAMPLE_TEXTURE
    float2 uv           : TEXCOORD0;
#endif
    float4 positionCS   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};



float4 GetSceneShadowPositionHClip(Attributes input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

#if defined(_HIGH_QUALITY) || defined(_MEDIUM_QUALITY)
    UNITY_BRANCH
    if(Prop_WindToggle)
    {
        positionWS.xz += PlantsAnimationNoise(positionWS, Prop_WindParam, input.positionOS.y);
    }
#endif
    
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    positionWS = ApplyShadowBias(positionWS, normalWS, _LightDirection);

    float4 positionCS = TransformWorldToHClip(positionWS);

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif

    return positionCS;
}

Varyings SceneShadowPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

#ifdef SHOULD_SAMPLE_TEXTURE
    output.uv = input.texcoord * _BASEMAP_ST.xy + _BASEMAP_ST.zw;
#endif

    output.positionCS = GetSceneShadowPositionHClip(input);
    return output;
}

half4 SceneShadowPassFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    DitherLOD(unity_LODFade.x, input.positionCS.xy);
#ifdef SHOULD_SAMPLE_TEXTURE
    half alpha = sampleBaseMap(input.uv).a;
#endif

#if _ALPHATEST_ON
    //clip(alpha - GetCutoff());
#elif _DITHER_CLIP
    alpha *= GetTransparent();
    half dither = GetCheckerBoardDither(input.positionCS.xy);
    clip(alpha - dither);
#endif
    
    return 0;
}

#endif
