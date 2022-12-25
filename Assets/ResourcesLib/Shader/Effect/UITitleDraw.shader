Shader "Bioum/UI/UITitleDraw"
{
	Properties
	{
		[HideInInspector]_MainTex ("Sprite Texture", 2D) = "white" {}
		[HideInInspector]_Color ("Tint", Color) = (1,1,1,1)
		_TextureDraw("Draw Texture", 2D) = "white" {}
		_Progress("Progress", Range( 0 , 1)) = 0.5
		_Offset("Offset", Range( 0 , 0.1)) = 0.03806899
		[Gamma]_Color0("Color1", Color) = (0.8235294,0.854902,0.8235294,0)
		[Gamma]_Color1("Color2", Color) = (0.8235294,0.854902,0.8235294,0)

	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
	LOD 0
		Cull Off

		
		Pass
		{
			HLSLPROGRAM

			#pragma target 3.0 
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};

			uniform sampler2D _TextureDraw;
			uniform float4 _TextureDraw_ST;
			uniform half _Progress;
			uniform float _Offset;
			uniform float4 _Color0;
			uniform float4 _Color1;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _TextureDraw);
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}
			
			real4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

				real4 color;
				float4 drawTex = tex2D(_TextureDraw, i.texcoord);
				float rat = ( 1.0 - (_Progress + _Offset) );				
				
				color = (drawTex.a * smoothstep(rat, (rat + _Offset), drawTex.r) * lerp(_Color1, _Color0, drawTex.g));
				return color;
			}
			ENDHLSL
		}
	}
}