#ifndef UPGRADE_COLOR
#define UPGRADE_COLOR

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

half3 ColorSpaceConvertInput(half3 color)
{
    #ifdef UNITY_COLORSPACE_GAMMA
    color = SRGBToLinear(color);
    #endif
    return color;
}

half4 ColorSpaceConvertInput(half4 color)
{
    #ifdef UNITY_COLORSPACE_GAMMA
    color = SRGBToLinear(color);
    #endif
    return color;
}

half3 ColorSpaceConvertOutput(half3 color)
{
    #ifdef UNITY_COLORSPACE_GAMMA
    color = LinearToSRGB(color);
    #endif
    return color;
}

half4 ColorSpaceConvertOutput(half4 color)
{
    #ifdef UNITY_COLORSPACE_GAMMA
    color = LinearToSRGB(color);
    #endif
    return color;
}

half3 DecodeHDR (half4 data, half4 decodeInstructions)
{
    // Take into account texture alpha if decodeInstructions.w is true(the alpha value affects the RGB channels)
    half alpha = decodeInstructions.w * (data.a - 1.0) + 1.0;

    // If Linear mode is not supported we can skip exponent part
    #if defined(UNITY_COLORSPACE_GAMMA)
        return (decodeInstructions.x * alpha) * data.rgb;
    #else
    #   if defined(UNITY_USE_NATIVE_HDR)
            return decodeInstructions.x * data.rgb; // Multiplier for future HDRI relative to absolute conversion.
    #   else
            return (decodeInstructions.x * pow(alpha, decodeInstructions.y)) * data.rgb;
    #   endif
    #endif
}

float3 RGB2HSV(float3 c)
{
    float4 k = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, k.wz), float4(c.gb, k.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 HSV2RGB(float3 c)
{
    float3 rgb = saturate(abs(fmod(c.x * 6.0 + float3(0.0, 4.0, 2.0), 6) - 3.0) - 1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return saturate(c.z * lerp(float3(1, 1, 1), rgb, c.y));
}

#endif