// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Post/ScreenSpaceCloudShadow"
{
	Properties
	{
		[HideInInspector] _MainTex("Main Tex", 2D) = "black" {}
		_CloudTex ("Cloud Texture (R)", 2D) = "black" {}
		_ShadowFactor ("XYZ:ColorMultiplier", Vector) = (1,1,1,1)
		_CloudFactor ("XY:WindSpeed ZW:CloudTiling", Vector) = (0.05,0.05,2,2)
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent+1000"
			"IgnoreProjector"="True"
			"ForceNoShadowCasting"="True"
		}
		Pass
		{
			Fog { Mode Off }
			ZWrite Off ZTest Always
			Blend Zero OneMinusSrcColor

			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			//#include "UnityCG.cginc"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

			struct appdata_base 
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;

			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv  : TEXCOORD0;
				//float3 ray : TEXCOORD1;
			};

			sampler2D _CloudTex;
			//sampler2D _CameraDepthTexture;

			uniform float4 _ShadowFactor;
			uniform float4 _CloudFactor;

			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = TransformWorldToHClip(v.vertex);
				o.uv = v.texcoord.xy;

				//o.ray = mul(unity_ObjectToWorld, v.vertex) - _WorldSpaceCameraPos;

				return o;
			}

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

			float4 frag(v2f i) : SV_Target
			{
				//float  depth = Linear01Depth( SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, i.uv ) );

				//float  cloud_faded = tex2D(_CloudTex, ((i.ray * depth + _WorldSpaceCameraPos).xz * 0.005f + _CloudFactor.xy * _Time.x) * _CloudFactor.zw).r * (1.0 - depth);		// fade by depth (don't render shadow to faraway skybox..)


				float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv).r;
				float eyeDepth = LinearEyeDepth(depth, _ZBufferParams);
				half4 positionWS = GetWorldPosFromEyeDepth(i.uv, eyeDepth);
				float  cloud_faded = tex2D(_CloudTex, (positionWS.xz * 0.005f + _CloudFactor.xy * _Time.x) * _CloudFactor.zw).r * (1 - Linear01Depth(depth, _ZBufferParams));

				return float4(_ShadowFactor.xyz * cloud_faded, 1.0);
			}
			ENDHLSL
		}
	}
}
