#ifndef BIOUM_SHADOW_INCLUDED
#define BIOUM_SHADOW_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    #if _SCREEN_SPACE_SHADOW && !_TRANSPARENT_RECEIVE_SS_SHADOW
        #define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
        #define OUTPUT_SHADOWCOORD(positionWS, positionCS, outputName) outputName = ComputePositionNDC(positionCS)
        #define GET_SHADOW_COORD(vertexShadowCoord, positionWS) float4(CalculateScreenSpaceUV(vertexShadowCoord), 1, 1)
        #define DECLARE_SHADOWCOORD(shadowCoordName, index) float4 shadowCoordName : TEXCOORD##index;
    #else
        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) //在不开启cascade shadow的时候  在顶点计算阴影坐标
            #define OUTPUT_SHADOWCOORD(positionWS, positionCS, outputName) outputName = TransformWorldToShadowCoord(positionWS.xyz)
            #define GET_SHADOW_COORD(vertexShadowCoord, positionWS) vertexShadowCoord
            #define DECLARE_SHADOWCOORD(shadowCoordName, index) float4 shadowCoordName : TEXCOORD##index;
        #else
            #define OUTPUT_SHADOWCOORD(positionWS, positionCS, outputName)
            #define GET_SHADOW_COORD(vertexShadowCoord, positionWS) TransformWorldToShadowCoord(positionWS)
            #define DECLARE_SHADOWCOORD(shadowCoordName, index)
        #endif
    #endif
#else
    #define OUTPUT_SHADOWCOORD(positionWS, positionCS, outputName)
    #define GET_SHADOW_COORD(vertexShadowCoord, positionWS) 0
    #define DECLARE_SHADOWCOORD(shadowCoordName, index)
#endif

half2 GetScreenSpaceShadowAndAO(float4 shadowCoord)
{
    half2 shadowAO = SAMPLE_TEXTURE2D(_ScreenSpaceShadowmapTexture, sampler_ScreenSpaceShadowmapTexture, shadowCoord.xy).ra;
    return shadowAO;
}


half2 ScreenSpaceMainLightShadow(float4 shadowCoord, float3 positionWS, half4 shadowMask, half4 occlusionProbeChannels)
{
    half2 shadowAndAO = GetScreenSpaceShadowAndAO(shadowCoord);

    #ifdef CALCULATE_BAKED_SHADOWS
    half bakedShadow = BakedShadow(shadowMask, occlusionProbeChannels);
    #else
    half bakedShadow = 1.0h;
    #endif

    #ifdef MAIN_LIGHT_CALCULATE_SHADOWS
    half shadowFade = GetShadowFade(positionWS);
    #else
    half shadowFade = 1.0h;
    #endif

    #if defined(_MAIN_LIGHT_SHADOWS_CASCADE) && defined(CALCULATE_BAKED_SHADOWS)
    // shadowCoord.w represents shadow cascade index
    // in case we are out of shadow cascade we need to set shadow fade to 1.0 for correct blending
    // it is needed when realtime shadows gets cut to early during fade and causes disconnect between baked shadow
    shadowFade = shadowCoord.w == 4 ? 1.0h : shadowFade;
    #endif

    return half2(MixRealtimeAndBakedShadows(shadowAndAO.x, bakedShadow, shadowFade), shadowAndAO.y);
}


#endif  //BIOUM_LIGHT_INCLUDED