Shader "Post/RenderFeature/WaveOut"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		//_BackGround("BackGround", 2D) = "white" {}
		_NormalPower("NormalPower", Float) = 0.5
		[HDR]_Color("Color", Color) = (0,0,0,0)

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

			

			sampler2D _GameCameraColorTexture;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color;
			float _NormalPower;
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

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.texCoord0 = v.uv0;
				o.clipPos = TransformObjectToHClip(v.vertex.xyz);

				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float2 uv = IN.texCoord0.xy;
				float3 duv = float3((float2(1, 1) / _ScreenParams.xy * 2), 0.0);
				float2 appendResult45 = float2(tex2D(_MainTex, uv + duv.xz).r - tex2D(_MainTex, uv - duv.xz).r, tex2D(_MainTex, uv + duv.zy).r - tex2D(_MainTex, uv - duv.zy).r) * 10;

				float3 Grad = normalize(float3((appendResult45 * _NormalPower), 1.0));
				float2 uv2 = Grad.xy + uv;
				float3 lightDir = normalize(float3(0.2, -0.5, 0.7));
				float Spec = pow(max(-(refract(lightDir, Grad , 0.95)).z , 0.0) , 32.0);

				float4 tex2DNode = tex2D(_MainTex, uv2);
				float4 Color = (tex2D(_GameCameraColorTexture, uv2) * max(dot(Grad, lightDir), 0.0)) + Spec + (tex2DNode.b * _Color);

				return Color;
			}

			ENDHLSL
		}
	}	
}