Shader "Post/RenderFeature/WaveEffect"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_iMouse("iMouse", Vector) = (500,500,0,0)
		_LineWidth("LineWidth", Float) = 0
		_Speed("Speed", Float) = 0
		_D("D", Range( 0.5 , 0.99)) = 0.95
		_WideNewOld("WideNew&Old", Vector) = (0,0,0,0)
		_oMouse("oMouse", Vector) = (0,0,0,0)
		_san("san", Range( 0 , 1)) = 0

	}

	SubShader
	{
		LOD 0		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		Cull Off
		HLSLINCLUDE
		#pragma target 2.0
		ENDHLSL

		
		Pass
		{
			Name "Unlit"
			

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#pragma prefer_hlslcc gles

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"



			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _iMouse;
			float4 _oMouse;
			float4 _WideNewOld;
			float _Speed;
			float _D;
			float _LineWidth;
			float _san;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float4 uv0 : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			float4 _RendererColor;

			float Line102(float2 uv, float2 PixelSize, float2 TouchMsg, float2 LastTouchMsg, float WideNew, float WideOld, float LineWidth, float TouchState, float mt)
			{
				float2 of = uv * PixelSize.xy - LastTouchMsg;
				float2 nf = TouchMsg - LastTouchMsg;
				float LineWide = clamp(dot(of, nf) / dot(nf, nf), 0, 1);
				float outB = 1 - (1 - mt) * (1 - step(0, TouchState) * smoothstep(0.5, 1.0, smoothstep(lerp(WideOld * LineWidth, WideNew * LineWidth, LineWide), 0, length(LineWide * nf - of))));
				return outB;
			}
			

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.texCoord0 = v.uv0;
				o.clipPos = TransformObjectToHClip(v.vertex.xyz);

				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float2 MouseXY = float2(_iMouse.x, _iMouse.y);
				float2 uv = IN.texCoord0.xy;
				float2 screenSize = _ScreenParams.xy / 2;

				float4 texCol = tex2D(_MainTex, uv);
				float3 duv = (float3((float2(1, 1) / screenSize), 0.0) * float3(3,2,0) * _Speed);
				float round = (tex2D(_MainTex, uv - duv.zy).r - 0.2) * 10.0;
				round += (tex2D(_MainTex, uv - duv.xz).r - 0.2) * 10.0;
				round += (tex2D(_MainTex, uv + duv.xz).r - 0.2) * 10.0;
				round += (tex2D(_MainTex, uv + duv.zy).r - 0.2) * 10.0;
				round -= 2;
				float clampResult99 = (step(0, _iMouse.z) * smoothstep(50.0, 0.0, length((MouseXY - uv * screenSize))) + ((texCol.g - 0.5) * -2.0) + round) * _D;
				clampResult99 = saturate((clampResult99 * 0.5 + 0.5) * 0.1 + 0.2);

				float localLine102 = Line102(uv, screenSize, MouseXY, _oMouse.xy, _WideNewOld.x, _WideNewOld.y, _LineWidth, _iMouse.z, texCol.b* _san);
				float4 Color = (float4(clampResult99 , (texCol.r - 0.2) * 10.0, localLine102 , 0.0));


				return Color;
			}

			ENDHLSL
		}
	}
	
}