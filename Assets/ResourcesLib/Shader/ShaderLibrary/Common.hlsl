#ifndef BIOUM_COMMON_INCLUDE
#define BIOUM_COMMON_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

#include "SurfaceStruct.hlsl"
#include "Noise.hlsl"

SAMPLER(Sampler_LinearClamp);
SAMPLER(Sampler_LinearRepeat);
SAMPLER(Sampler_PointClamp);
SAMPLER(Sampler_PointRepeat);

#ifndef _BASEMAP_ST
#define _BASEMAP_ST half4(1,1,0,0)
#endif

real Square(real v)
{
	return v * v;
}
real2 Square(real2 v)
{
	return v * v;
}
real3 Square(real3 v)
{
	return v * v;
}

real2 Pow4(real2 x)
{
	return (x * x) * (x * x);
}
real3 Pow4(real3 x)
{
	return (x * x) * (x * x);
}
real4 Pow4(real4 x)
{
	return (x * x) * (x * x);
}

real DistanceSquared(float3 pA, float3 pB) 
{
	return dot(pA - pB, pA - pB);
}

real positiveSin(real x)
{
    x = fmod(x, TWO_PI);
    return sin(x) * 0.5 + 0.5;
}

real4 LerpWhiteTo(real4 b, real t)
{
    real oneMinusT = 1.0 - t;
    return real4(oneMinusT, oneMinusT, oneMinusT, oneMinusT) + b * t;
}

real SoftEdge(real near, real far, real4 positionNDC)
{
    positionNDC.xyz *= rcp(positionNDC.w);
    float depth = SampleSceneDepth(positionNDC.xy);
    real sceneZ = LinearEyeDepth(depth, _ZBufferParams);
    real thisZ = LinearEyeDepth(positionNDC.z, _ZBufferParams);
    real fade = saturate (far * ((sceneZ - near) - thisZ));
    return fade;
}




half GetCheckerBoardDither(float2 positionCS)
{
	const float DITHER_THRESHOLDS[16] =
	{
		1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0, 7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0
    };
	float2 uv = positionCS.xy;
	uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
	return DITHER_THRESHOLDS[index];
}

void DitherLOD (float fade, float dither) 
{
	#if defined(LOD_FADE_CROSSFADE)
		clip(fade + (fade < 0.0 ? dither : -dither));
	#endif
}

void DitherLOD (float fade, float2 positionCS) 
{
	#if defined(LOD_FADE_CROSSFADE)
        float dither = InterleavedGradientNoise(positionCS, 0);
		clip(fade + (fade < 0.0 ? dither : -dither));
	#endif
}

void DitherClip(real alpha, real dither, real cutoff, real ditherCutoff)
{
    clip((alpha - cutoff) - (dither * ditherCutoff));
}

half _SceneDarkness;
half3 ApplySceneDarkness(half3 color)
{
	return _SceneDarkness > 0.05 ? color * (1 - _SceneDarkness) : color;
}

// AG通道在贴图压缩后可以保留更高的精度
// 法线的X轴视觉上更为重要一些, 因此X放入精度最高的Alpha通道中
// https://blog.csdn.net/leonwei/article/details/79893445
half3 UnpackNormalAndData(half4 packedNormal, half normalScale, out half2 data)
{
	data = packedNormal.xz;
	
	half3 normalTS = half3(packedNormal.wy, 1);
	normalTS = normalTS * 2.0 - 1.0;
	normalTS.xy *= normalScale;
	//这里不用做normallize 在TBN矩阵计算后做
	return normalTS;
}


// https://tsherif.github.io/webgl2examples/oit.html
float WBOIT_Blend(float z, float a)
{
    return clamp(pow(min(1.0, a * 10.0) + 0.01, 3.0) * 1e8 * pow(1.0 - z * 0.9, 3.0), 1e-2, 3e3);
}

half3 BlendNormalUDN(half3 baseN, half3 detailN)
{
	half3 n = normalize(half3(baseN.xy + detailN.xy, baseN.z));
	return n;
}

float4 ComputePositionNDC(float4 positionCS)
{
	float4 ndc = positionCS * 0.5f;
	ndc.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
	ndc.zw = positionCS.zw;
	return ndc;
}

float2 CalculateScreenSpaceUV(float4 positionNDC)
{
	return positionNDC.xy * rcp(positionNDC.w);
}


#if (_SCREEN_SPACE_SHADOW && !_TRANSPARENT_RECEIVE_SS_SHADOW) || _PLANAR_REFLECTION
#define _SCREEN_SPACE_UV
#endif

#endif

























