Shader "Bioum/Scene/OnlyStencil"
{
	Properties
	{
		[MainTexture] _BaseMap("贴图", 2D) = "white" {}
		_clipAlpha("Alpha Clip", Range(0, 1)) = 0.5
		_stencilValue("StencilValue", Range(0, 255)) = 1
	}
	SubShader
	{
		Tags { "Queue" = "Geometry-20" "IgnoreProjector" = "True" "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
		Blend Zero One//SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		ZTest Always
		LOD 100

		Pass
		{
			Stencil
			{
				Ref [_stencilValue]
				Comp Always
				Pass Replace
			}
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
			UNITY_DEFINE_INSTANCED_PROP(real, _clipAlpha)
			UNITY_INSTANCING_BUFFER_END(Props)

			#define Prop_BaseMap_ST UNITY_ACCESS_INSTANCED_PROP(Props, _BaseMap_ST)
			#define Prop_clipAlpha UNITY_ACCESS_INSTANCED_PROP(Props, _clipAlpha)
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);

			struct appdata
			{
				float4 vertex : POSITION;
				real2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				real2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			v2f vert (appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = v.texcoord * Prop_BaseMap_ST.xy + Prop_BaseMap_ST.zw;
				return o;
			}
			
			real4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				// sample the texture
				real4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
				clip(col.a - Prop_clipAlpha);
				return col;
			}
			ENDHLSL
		}
	}
}
