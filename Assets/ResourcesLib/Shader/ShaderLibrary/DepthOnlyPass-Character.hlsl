#ifndef BIOUM_DEPTH_ONLY_PASS_INCLUDED
#define BIOUM_DEPTH_ONLY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

#if _ALPHATEST_ON || _DITHER_CLIP
#define SHOULD_SAMPLE_TEXTURE
#endif


#ifndef Prop_DissolveToggle
#define Prop_DissolveToggle false
#define Prop_DissolveAni 0
#define Prop_DissolveScale 1
#define Prop_DissolveFactor 0
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
    float4 uvAndDissolve : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

void ApplyDissolve(half noise)
{
    UNITY_BRANCH
    if(Prop_DissolveToggle)
    {
        clip(step(0, noise) - 0.5);
    }
}


Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float4 positionCS = TransformWorldToHClip(positionWS);

    #if UNITY_REVERSED_Z
        positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
        positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    output.positionCS = positionCS;

    #ifdef SHOULD_SAMPLE_TEXTURE
        output.uvAndDissolve.xy = input.texcoord * _BASEMAP_ST.xy + _BASEMAP_ST.zw;
    #endif

    UNITY_BRANCH
    if(Prop_DissolveToggle)
    {
        positionWS.y += -Prop_DissolveAni * _Time.y;
        output.uvAndDissolve.w = snoise3D(positionWS * Prop_DissolveScale) * 0.49 + 0.51;
        output.uvAndDissolve.w = saturate(output.uvAndDissolve.w) - Prop_DissolveFactor;
    }
    
    return output;
}
half4 DepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    ApplyDitherTransparent(input.positionCS.xy);
    ApplyDissolve(input.uvAndDissolve.w);
    
    #ifdef SHOULD_SAMPLE_TEXTURE
        half alpha = sampleBaseMap(input.uvAndDissolve.xy).a;
    #endif

    #if _ALPHATEST_ON
        clip(alpha - GetCutoff());
    #elif _DITHER_CLIP
        alpha *= GetTransparent();
        half dither = GetCheckerBoardDither(input.positionCS.xy);
        clip(alpha - dither);
    #endif
    
    return 0;
}

#endif
