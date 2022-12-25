#ifndef BIOUM_STYLIZED_WATER
#define BIOUM_STYLIZED_WATER

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

//Constant Buffers  

TEXTURE2D(_EdgeFoamTexture);        SAMPLER(sampler_EdgeFoamTexture);
TEXTURE2D(_CameraColorTex);         SAMPLER(sampler_CameraColorTex);
TEXTURE2D(_IntersectionNoise);      SAMPLER(sampler_IntersectionNoise);
TEXTURE2D(_CausticsTex);            SAMPLER(sampler_CausticsTex);
TEXTURE2D(_FoamTex);                SAMPLER(sampler_FoamTex);

float4 _MainColor;

CBUFFER_START(UnityPerMaterial)
half4 _WaveSpeed;
half _EnvNormalScale;
half _SoftEdgeRange, _WaterColorRange;
half _HorizonDistance;
float4 _IntersectionColor;
half4 _WaterColor, _WaterColorNear, _WaterColorFar, _SpecColor;
float _WorldSpaceUV;
half _Transparent;
half _FresnelPower, _SpecPower;
half _Smoothness;
half _ThresholdSpeed;
half _ThresholdDensity;
half _MaxThreshold;
half _ThresholdFalloff;
float _FoamTiling;
float4 _FoamColor;
float _FoamSpeed;
half _FoamSize;
half _FoamWaveMask;
half _FoamWaveMaskExp;
half _FoamDensity;

float _EdgeFoamBlend;
float _EdgeFoamIntensity;
float4 _EdgeFoamColor;
float _EdgeFoamVisibility;
float _EdgeFoamContrast;
float _EdgeFoamTiling;
float _EdgeFoamSpeed;


half _RealtimeReflectionDistort;
float4 _AnimationParams;

float _DepthVertical;
float _DepthHorizontal;
float _DepthExp;

//Intersection
half _EdgeFade;
half _IntersectionSource;
//half _IntersectionLength;
half _IntersectionFalloff;
half _IntersectionTiling;
half _IntersectionRippleDist;
half _IntersectionRippleStrength;
//half _IntersectionClipping;
float _IntersectionSpeed;
float _waveEdgeLength;
float _waveFalloff;
float4 _waveEdgeVector;
float4 _MaskFlow;



//Underwater
half _CausticsBrightness;
float _CausticsTiling;
half _CausticsSpeed;
half _CausticsDistortion;
half4 _VertexColorMask;
//half _WaveTint;
half _WaterLodFadeLevel;
float _WorldScale;

TEXTURE2D(_FoamNoiseTex);        SAMPLER(sampler_FoamNoiseTex);
TEXTURE2D(_FoamNoiseDistTex);    SAMPLER(sampler_FoamNoiseDistTex);
float4 _FoamNoiseTex_ST;
float4 _FoamNoiseDistTex_ST;
half4 _CHPFoamParam1;
half4 _CHPFoamParam2;
half4 _CHPFoamCol;

CBUFFER_END

#define _FoamNoiseMix _CHPFoamParam1.x
#define _FoamNoiseDistortion _CHPFoamParam1.y
#define _FoamNoiseSpeed _CHPFoamParam1.z
#define _CHPFoamWidth _CHPFoamParam1.w
#define _CHPFoamNum _CHPFoamParam2.x
#define _CHPFoamSpeed _CHPFoamParam2.y
#define _CHPFoamStart _CHPFoamParam2.z
#define _CHPFoamAtten _CHPFoamParam2.w

//Chinese Painting Water Foam
#endif