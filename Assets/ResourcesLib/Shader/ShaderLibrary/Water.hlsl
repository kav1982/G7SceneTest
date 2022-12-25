
//Prototyping!
//#define RECEIVE_PROJECTORS
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#if !defined(USE_CUSTOM_TIME)
#define TIME_FRAG_INPUT input.uv.z
#define TIME_VERTEX_OUTPUT output.uv.z
#else
float _CustomTime;
#define TIME_FRAG_INPUT _CustomTime
#define TIME_VERTEX_OUTPUT _CustomTime
#endif
#define TIME ((TIME_FRAG_INPUT * _AnimationParams.z) * _AnimationParams.xy)
#define TIME_VERTEX ((TIME_VERTEX_OUTPUT * _AnimationParams.z) * _AnimationParams.xy)


#ifdef RECEIVE_PROJECTORS
TEXTURE2D(_WaterProjectorDiffuse);	SAMPLER(sampler_WaterProjectorDiffuse);
float4 _WaterProjectorUV;
#endif

struct SceneDepth
{
	float raw;
	float linear01;
	float eye;
};

float frac(float v)
{
	return v - floor(v);
}

float LinearDepth(float z, float eyeDepth)
{
	
	return eyeDepth - Linear01Depth(z, _ZBufferParams) ; //1=orthographic
}



SceneDepth SampleDepth(float4 screenPos)
{
	SceneDepth depth = (SceneDepth)0;
	
	#ifndef _DISABLE_DEPTH_TEX
	screenPos.xyz /= screenPos.w;

	depth.raw = SampleSceneDepth(screenPos.xy);
	depth.eye = LinearEyeDepth(depth.raw, _ZBufferParams);
	depth.linear01 = LinearDepth(screenPos.z, depth.eye);
	#else
	depth.raw = 1.0;
	depth.eye = 1.0;
	depth.linear01 = 1.0;
	#endif

	return depth;
}


float4 PackedUV(float2 sourceUV, float2 time, float2 flowmap, float speed)
{
	#if _RIVER
	time *= flowmap;
	//time.x = 0; //Only move in forward direction
	#endif
	
	float2 uv1 = sourceUV.xy + (time.xy * speed);
	float2 uv2 = (sourceUV.xy * 0.5) + ((1 - time.xy) * speed * 0.5);			
	return float4(uv1.xy, uv2.xy);
}


float2 GetSourceUV(float2 uv, float2 wPos, float state) 
{
	float2 output =  lerp(uv, wPos, state);	

	// #ifdef _RIVER	
	// return uv*10;
	// #endif
	//
	return output;
}

float4 GetVertexColor(float4 inputColor, float4 mask)
{
	return inputColor * mask;
}

float DepthDistance(float3 wPos, float3 viewPos, float3 normal)
{
	return length((wPos - viewPos) * normal);
}

float SampleIntersection(float2 uv,  float gradient, float2 time)
{
	float inter = 0;
	float dist = 0;	
	float sine = sin(time.y * 10 - (gradient * _waveEdgeVector.x)) * _waveEdgeVector.w;
	float2 nUV = float2(uv.x, uv.y) * _waveEdgeVector.y * 0.1;
	float noise = SAMPLE_TEXTURE2D(_IntersectionNoise, sampler_IntersectionNoise, nUV + time.xy).g;
	dist = saturate(gradient / _waveFalloff);
	noise = saturate((noise + sine) * dist + dist);
	inter = step(_waveEdgeVector.z, noise);
	return saturate(inter);
}

float SampleLakEdge(float2 uv,  float gradient, float2 time)
{
			
	float2 nUV = float2(uv.x, uv.y) * _waveEdgeVector.y;
	float noisetex = SAMPLE_TEXTURE2D(_IntersectionNoise, sampler_IntersectionNoise, nUV + time.xy).b;
	float dist = saturate(gradient / _waveFalloff);
	float noise = saturate(noisetex * dist + dist);
	float inter = smoothstep(0,noise,_waveEdgeVector.z);
	//float inter = step(_IntersectionClipping, noise);
	return saturate(inter);	
}



//float SampleFoam(float2 uv, float2 time, float2 flowmap, float clipping, float mask, float slope)
float SampleFoam(float2 uv, float2 time, float2 flowmap, float clipping, float mask)
{
#if _FOAM
	float4 uvs = PackedUV(uv*0.01, time, flowmap, _FoamSpeed);	
	float f1 = SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, uvs.xy).r;	
	float f2 = SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, uvs.zw).r;
	
	#if UNITY_COLORSPACE_GAMMA
	f1 = SRGBToLinear(f1);
	f2 = SRGBToLinear(f2);
	#endif

	float foam = saturate(f1 + f2) * mask;

// #if _RIVER //Slopes
// 	uvs = PackedUV(uv, time, flowmap, _FoamSpeed * _SlopeParams.y);
// 	//Stretch UV vertically on slope
// 	uvs = uvs * float4(1.0, 1-_SlopeParams.x, 1.0, 1-_SlopeParams.x);
//
// 	//Cannot reuse the same UV, slope foam needs to be resampled and blended in
// 	float f3 = tex2D(_FoamTex,  uvs.xy).r;
// 	float f4 = tex2D(_FoamTex,  uvs.zw).r;
//
// 	#if UNITY_COLORSPACE_GAMMA
// 	f3 = SRGBToLinear(f3);
// 	f4 = SRGBToLinear(f4);
// 	#endif
//
// 	foam = saturate(lerp(f3 + f4, f1 + f2, slope)) * mask;
// #endif	
	foam = smoothstep(clipping, 1.0, foam) * foam * foam;
	return foam;
#else
	return 0;
#endif
}

float3 SampleCaustics(float2 uv, float2 time, float tiling)
{
	float3 caustics1 = SAMPLE_TEXTURE2D(_CausticsTex, sampler_CausticsTex, uv * tiling + (time.xy)).rrr;
	float3 caustics2 = SAMPLE_TEXTURE2D(_CausticsTex, sampler_CausticsTex, (uv * tiling * 0.8) - (time.xy)).rrr;

	#if UNITY_COLORSPACE_GAMMA
	caustics1 = SRGBToLinear(caustics1);
	caustics2 = SRGBToLinear(caustics2);
	#endif

	float3 caustics = min(caustics1, caustics2);	   	
	return caustics;
}

// URP UPGRADE COMMENT: //Specular reflection in world-space
// URP UPGRADE COMMENT: float4 SunSpecular(Light light, float3 viewDir, float3 normalWS, float perturbation, float size, float intensity)
// URP UPGRADE COMMENT: {
// URP UPGRADE COMMENT: 	//return LightingSpecular(1, light.direction, normalWS, viewDir, 1, lerp(8196, 64, size));
// URP UPGRADE COMMENT: 	
// URP UPGRADE COMMENT: 	float3 viewLightTerm = normalize(light.direction + (normalWS * perturbation) + viewDir);
// URP UPGRADE COMMENT: 	
// URP UPGRADE COMMENT: 	float NdotL = saturate(dot(viewLightTerm, float3(0, 1, 0)));
// URP UPGRADE COMMENT: 
// URP UPGRADE COMMENT: 	half specSize = lerp(8196, 64, size);
// URP UPGRADE COMMENT: 	float specular = (pow(NdotL, specSize));
// URP UPGRADE COMMENT: 	//Mask by shadows if available
// URP UPGRADE COMMENT: 	specular *= (light.distanceAttenuation * light.shadow);
// URP UPGRADE COMMENT: 
// URP UPGRADE COMMENT: 	float3 specColor = specular * light.color * intensity;
// URP UPGRADE COMMENT: 
// URP UPGRADE COMMENT: 	return float4(specColor, specSize);
// URP UPGRADE COMMENT: }

void SampleDiffuseProjectors(inout float3 color, float3 wPos, float4 screenPos)
{
#ifdef RECEIVE_PROJECTORS
	float2 uv = BoundsToWorldUV(wPos, _WaterProjectorUV);
	uv = screenPos.xy / screenPos.w;
	uv.y = 1- uv.y;
	
	float4 sample = SAMPLE_TEXTURE2D(_WaterProjectorDiffuse, sampler_WaterProjectorDiffuse, uv);
	//sample.a *= BoundsEdgeMask(uv - 0.5);

	color.rgb = lerp(color.rgb, sample.rgb, sample.a);
#endif
}

float3 ReconstructViewPos(float4 screenPos, float3 viewDir, SceneDepth sceneDepth)
{
	#if UNITY_REVERSED_Z
	float rawDepth = sceneDepth.raw;
	#else
	// Adjust z to match NDC for OpenGL
	float rawDepth = lerp(UNITY_NEAR_CLIP_VALUE, 1, sceneDepth.raw);
	#endif
	
	#if defined(ORTHOGRAPHIC_SUPPORT)
	//View to world position
	float4 viewPos = float4((screenPos.xy/screenPos.w) * 2.0 - 1.0, rawDepth, 1.0);
	float4x4 viewToWorld = UNITY_MATRIX_I_VP;
	#if UNITY_REVERSED_Z //Wrecked since 7.3.1 "fix" and causes warping, invert second row https://issuetracker.unity3d.com/issues/shadergraph-inverse-view-projection-transformation-matrix-is-not-the-inverse-of-view-projection-transformation-matrix
	//Commit https://github.com/Unity-Technologies/Graphics/pull/374/files
	viewToWorld._12_22_32_42 = -viewToWorld._12_22_32_42;              
	#endif
	float4 viewWorld = mul(viewToWorld, viewPos);
	float3 viewWorldPos = viewWorld.xyz / viewWorld.w;
	#endif

	//Projection to world position
	float3 camPos = _WorldSpaceCameraPos.xyz;
	float3 worldPos = sceneDepth.eye * (viewDir/screenPos.w) - camPos;
	float3 perspWorldPos = -worldPos;

	#if defined(ORTHOGRAPHIC_SUPPORT)
	return lerp(perspWorldPos, viewWorldPos, unity_OrthoParams.w);
	#else
	return perspWorldPos;
	#endif

}
half fakeSin(half val)
{
	 val = fmod(val,3.1415);
	 half v1 = 60*val - 70*val*val*val;
	 half v2 = 60 + 3*val*val;
	 return v1/v2 + 0.64;
}

half4 CHPFoamCol(half3 sourceCol,half sourceAlpha,half edge,half2 noiseUV,half mask)
{
    half realDepth = saturate(edge*4);
	realDepth = smoothstep(0,1,realDepth);
	half noiseV1 = SAMPLE_TEXTURE2D(_FoamNoiseTex,sampler_FoamNoiseTex,noiseUV*_FoamNoiseTex_ST.xy + _FoamNoiseSpeed*_Time.y*half2(0,1)).r;
	half noiseV2 = SAMPLE_TEXTURE2D(_FoamNoiseTex,sampler_FoamNoiseTex,noiseUV*_FoamNoiseTex_ST.xy + _FoamNoiseSpeed*_Time.y*half2(1,0)).r;
	half noiseX = SAMPLE_TEXTURE2D(_FoamNoiseDistTex,sampler_FoamNoiseDistTex,noiseUV*_FoamNoiseDistTex_ST.xy).r *_FoamNoiseDistortion;
	half noiseX2 = noiseX*0.5f;
	half noisePow = saturate(noiseV1+ noiseV2 + _FoamNoiseMix-0.2);
	half noisePow2 = saturate(noiseV1+ noiseV2 - _FoamNoiseMix);
	half noisePow3 = saturate(noiseV1+ noiseV2 - _FoamNoiseMix-0.2);
	half UVV = step(realDepth,1-_CHPFoamStart*0.05)*realDepth;
	half foamAtten = (1-UVV) * _CHPFoamAtten;
	half widthAtten = _CHPFoamWidth * UVV * UVV;

	half Width_Fill = widthAtten * (1-noisePow);
	half Width2_Fill = widthAtten * 5 * noisePow2;
	half Width3_Fill = widthAtten * 5 * noisePow3;

	half realWidth_Fill = step(foamAtten,Width_Fill) * Width_Fill;
	half realWidth2_Fill = step(foamAtten,Width2_Fill) * Width2_Fill;
	half realWidth3_Fill = step(foamAtten,Width3_Fill) * Width3_Fill;

	half wave1 = fakeSin(UVV*_CHPFoamNum+noiseX + _Time.y*_CHPFoamSpeed);
	half wave2 = fakeSin(UVV*_CHPFoamNum+noiseX2 + _Time.y*_CHPFoamSpeed + 1.67);
	half wave3 = fakeSin(UVV*_CHPFoamNum+noiseX2 + _Time.y*_CHPFoamSpeed*0.2);

	half area_Fill = step(1-realWidth_Fill,wave1);
	half area2_Fill = step(1-realWidth2_Fill,wave2);
	half area3_Fill = step(1-realWidth3_Fill,wave3);

	half areaX = step(realDepth,1-_CHPFoamStart*0.05);

	half replaceArea = (step(0,area_Fill - UVV) + step(0,area2_Fill - UVV)+step(0,area3_Fill - UVV))*areaX;
	//replaceArea = (step(0,area_Fill - UVV) + step(0,area2_Fill - UVV))*areaX;
	//replaceArea = step(0,area_Fill - UVV)*areaX;
	//replaceArea = step(0,area3 - UVV)*areaX;
	replaceArea *= mask;
	
	sourceCol.rgb = lerp(sourceCol.rgb,_CHPFoamCol.rgb,saturate(replaceArea) * _CHPFoamCol.a);
	half realAlpha = step(sourceAlpha,_CHPFoamCol.a);
	half alpha = lerp(sourceAlpha,_CHPFoamCol.a,saturate(replaceArea) * realAlpha);
	return half4(sourceCol,alpha);
}
