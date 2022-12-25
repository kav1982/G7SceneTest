#ifndef UNIVERSAL_POSTPROCESSING_FOWOFWAR_INCLUDED
#define UNIVERSAL_POSTPROCESSING_FOWOFWAR_INCLUDED

#if FOGOFWAR
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
TEXTURE2D(_FOWWorldMask);
SAMPLER(sampler_FOWWorldMask);
TEXTURE2D(_FOWUVTex);
SAMPLER(sampler_FOWUVTex);
TEXTURE2D(_FOWEdgeNoiseTex);
SAMPLER(sampler_FOWEdgeNoiseTex);
half4 _FOWMask_TexelSize;
half3 _FOWColor;
half4 _FOWWindColor;
half4 _FOWSelectColor;
half3 _FOWExploreColor;
half2 _DistortUVAni;

half4 _FOWDepthFogColor;
half4 _FogOfWarEdgeColor;
half4 _FOWWorldMaskParams;	// x: start pos x, y: start pos y, z: fog width, w: fog height
half4 _FOWBaseParams;	// x: 整体高度, y: 底色亮度(相乘), z: 底色亮度(相加), w: 暗部增亮
half4 _FOWEdgeParams;	// x: 边缘Tiling, y: 边缘速度, z: 边缘扰动强度
half4 _FOWWindParams;	// x: 风Tiling, y: 风速度, z: 深度雾Tiling, w: 深度雾速度
half4 _FOWDepthParams;  // x: 深度雾开始高度, y: 深度雾结束高度, z: 深度雾噪音强度  

float4 GetWorldPosFromEyeDepth(float2 uv, float LinearEyeDepth)
{
	//float camPosZ = _ProjectionParams.y + (_ProjectionParams.z - _ProjectionParams.y) * LinearEyeDepth;
	float camPosZ = LinearEyeDepth;
	float height = 2 * camPosZ / unity_CameraProjection._m11;
	float width = _ScreenParams.x / _ScreenParams.y * height;
	float camPosX = width * uv.x - width * 0.5;
	float camPosY = height * uv.y - height * 0.5;
	float4 camPos = float4(camPosX, camPosY, camPosZ, 1.0);
	return mul(unity_CameraToWorld, camPos);
}

half4 SampleWorldMask(float2 uv) {
	// r通道1代表有迷雾，0代表没有迷雾
	// g通道是r的反向
	// b通道>0代表被选中
	// a通道<1代表探索中
	half4 mask = SAMPLE_TEXTURE2D(_FOWWorldMask, sampler_FOWWorldMask, uv);
	mask.r = max(0, mask.r - mask.g);
	return mask;
}

half4 RenderFogOfWar(float2 screenUV) {
	half4 _FOWMaskParams = _FOWWorldMaskParams;
	half xStart = _FOWMaskParams.x;
	half yStart = _FOWMaskParams.y;
	half maskWidth = _FOWMaskParams.z;
	half maskHeight = _FOWMaskParams.w;

	half overallHeight = _FOWBaseParams.x * 0.01;
	half heightScale = _FOWBaseParams.y;
	half heightOffset = _FOWBaseParams.z;
	half darkAdjust = _FOWBaseParams.w;

	half edgeDistortUVTiling = _FOWEdgeParams.x;
	half edgeDistortUVSpeed = _FOWEdgeParams.y;
	half edgeDistortStrength = _FOWEdgeParams.z;
	half edgeColorScale = _FOWWindParams.x;

	half depthFogUVTiling = _FOWWindParams.z;
	half depthFogUVSpeed = _FOWWindParams.w;

	half depthFogStart = _FOWDepthParams.x * 0.01;
	half depthFogEnd = _FOWDepthParams.y * 0.01;
	half depthFogNoiseAmount = _FOWDepthParams.z;

	// 转换世界坐标，获取高度
	float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV);
	float eyeDepth = LinearEyeDepth(depth, _ZBufferParams);
	half4 positionWS = GetWorldPosFromEyeDepth(screenUV, eyeDepth);
	half3 height = positionWS.y * heightScale + heightOffset;

	// 调整高度在_FOWParams.y以下的部分的颜色，用来调节一些很暗的地方的亮度
	half3 adjust = min(heightOffset, height);
	height += (lerp(0.2, 0, adjust * (1 / (heightOffset + 0.01))) * darkAdjust);

	// 雾底色
	half3 fogColor = height.rgb * _FOWColor.rgb;

#if defined(FOGOFWAR_DEPTH)
	// 深度雾相关计算

	// half tiling = lerp(lowTiling, highTiling, (_WorldSpaceCameraPos.y - lowCamera) / cameraRange);
	half2 depthFogSpeed = frac(positionWS.xz * depthFogUVTiling * 0.1 + _Time.y * 0.01 * depthFogUVSpeed);
	half depthFogNoise = (SAMPLE_TEXTURE2D(_FOWUVTex, sampler_FOWUVTex, depthFogSpeed).r - 0.1) * depthFogNoiseAmount * 0.5;

	// 避免当地面没有加载出来时，深度太大，导致迷雾呈黑色斑点状
	// 如果此时计算出来的深度大于摄像机远裁面的75%，depthFogNoise就为0
	depthFogNoise *= saturate((_ProjectionParams.z * 0.75 - eyeDepth) * 10000);

	// 深度雾颜色
	half depthFogAmount = 1 - saturate((positionWS.y - depthFogStart) / (depthFogEnd - depthFogStart));
	fogColor.rgb = lerp(fogColor.rgb, _FOWDepthFogColor.rgb, saturate(depthFogAmount * (1 + depthFogNoise)));
#endif

	// 迷雾遮罩
	half2 uvFOW = half2((positionWS.x - xStart) / maskWidth, (positionWS.z - yStart) / maskHeight);

	half4 fogMaskColor = SampleWorldMask(uvFOW);
	half fogMask = fogMaskColor.r;
	//half fogSelect = fogMaskColor.b;
	//half fogExplore = fogMaskColor.a;


	// 边缘
	float2 distortSampleUV = frac(positionWS.xz * edgeDistortUVTiling + float2(_Time.y * edgeDistortUVSpeed * 0.015, _Time.y * edgeDistortUVSpeed * 0.035));
	half edgeNoise = SAMPLE_TEXTURE2D(_FOWEdgeNoiseTex, sampler_FOWEdgeNoiseTex, distortSampleUV).r;

	half edge = 1 - clamp(fogMask - pow(1.0f - fogMask, 0.3f) * edgeNoise, 0, 1);
	edge = saturate(edge - 0.5f) * 2.0f;
	fogMask = lerp(1 - fogMask, edge, edgeDistortStrength);
	fogColor.rgb = lerp(fogColor.rgb, fogColor.rgb * _FogOfWarEdgeColor * edgeColorScale, fogMask);

	// 顶端露出一点点
	fogMask = lerp(fogMask, 1, smoothstep(0, overallHeight, positionWS.y - overallHeight));

//#if FOGOFWAR_WORLD
//	if (fogSelect > 0) {
//		fogColor.rgb = (fogColor.rgb + _FOWSelectColor) / 2.0f;
//	}
//
//	if (fogExplore < 1) {
//		fogColor.rgb = (fogColor.rgb + _FOWExploreColor) / 2.0f;
//	}
//#endif
	edge = 1 - clamp(fogMaskColor.b - pow(1 - fogMaskColor.b, 0.3f) * edgeNoise, 0, 1);
	edge = saturate(edge - 0.5f) * 2.0f;
	fogColor.rgb = lerp(fogColor.rgb, _FOWSelectColor.rgb, step(0.01, fogMaskColor.b) * lerp(fogMaskColor.b, 1 - edge, _FOWSelectColor.a) * saturate(abs(_SinTime.w) * 1.5));
	return half4(fogColor.rgb, fogMask);
}
#endif

#endif // UNIVERSAL_POSTPROCESSING_COMMON_INCLUDED
