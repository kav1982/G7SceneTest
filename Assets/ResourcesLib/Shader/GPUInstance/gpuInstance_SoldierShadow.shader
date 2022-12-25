// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "X7/GPUInstance_SoldierShadow" {
Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
}

Category {
	Tags { "Queue"="Geometry+50" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off

	SubShader {
		Pass {
		
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles

			#pragma multi_compile_instancing
			#include "../ShaderLibrary/Fog.hlsl"

			sampler2D _MainTex;
			
			struct appdata {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				half fog : TEXCOORD1;
			};
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
			    UNITY_SETUP_INSTANCE_ID(v);
				v2f o;				
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				half positionWSy = TransformObjectToWorld(v.vertex.xyz).y;
				o.fog = ComputeXYJFogFactor(ComputeScreenPos(o.vertex / o.vertex.w).xy, positionWSy);
				return o;
			}

			
			half4 frag (v2f i) : SV_Target
			{			
				half4 col = tex2D(_MainTex, i.texcoord);
				col.rgb = MixXYJFogColor(col.rgb, i.fog);
				return col;
			}
			ENDHLSL
		}
	}	
}
}
