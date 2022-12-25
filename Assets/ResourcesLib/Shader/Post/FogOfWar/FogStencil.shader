Shader "X7/WarFog/FogStencil"
{
	Properties
	{
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
			Tags{"LightMode" = "FogEye"}
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
			UNITY_INSTANCING_BUFFER_END(Props)

			struct appdata
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			v2f vert (appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}
			
			real4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				// sample the texture
				real4 col = real4(0,0,0,0);
				return col;
			}
			ENDHLSL
		}
	}
}
