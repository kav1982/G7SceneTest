// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Spine/Skeleton" {
	Properties {
		_Cutoff ("Shadow alpha cutoff", Range(0,1)) = 0.1
		[NoScaleOffset] _MainTex ("Main Texture", 2D) = "black" {}
		//[Toggle(_STRAIGHT_ALPHA_INPUT)] _StraightAlphaInput("Straight Alpha Texture", Int) = 0
		[Space(40)]
        _FadeEdge ("_FadeEdge", Vector) = (-3.51, 3.51, -5, 15)
        _FadeWidth ("_FadeWidth", float) = 0.1
		[Toggle(ALPHA_MASK)]_AlphaMask("开启遮罩", float) = 0
		_AlphaTex ("Alpha Texture", 2D) = "black" {}
		[HideInInspector] _StencilRef("Stencil Reference", Float) = 1.0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 8 // Set to Always as default

		// Outline properties are drawn via custom editor.
		[HideInInspector] _OutlineWidth("Outline Width", Range(0,8)) = 3.0
		[HideInInspector] _OutlineColor("Outline Color", Color) = (1,1,0,1)
		[HideInInspector] _OutlineReferenceTexWidth("Reference Texture Width", Int) = 1024
		[HideInInspector] _ThresholdEnd("Outline Threshold", Range(0,1)) = 0.25
		[HideInInspector] _OutlineSmoothness("Outline Smoothness", Range(0,1)) = 1.0
		[HideInInspector][MaterialToggle(_USE8NEIGHBOURHOOD_ON)] _Use8Neighbourhood("Sample 8 Neighbours", Float) = 1
		[HideInInspector] _OutlineMipLevel("Outline Mip Level", Range(0,3)) = 0
	}

	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

		Fog { Mode Off }
		Cull off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		Lighting Off

		Stencil {
			Ref[_StencilRef]
			Comp[_StencilComp]
			Pass Keep
		}

		Pass {
			Name "Normal"

			CGPROGRAM
			//#pragma shader_feature _ _STRAIGHT_ALPHA_INPUT
			#pragma multi_compile _ ALPHA_MASK
			#pragma multi_compile _ NEED_GAMMA
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			sampler2D _MainTex;
            sampler2D _AlphaTex;
			float4 _AlphaTex_ST;
			
            float4 _FadeEdge;
            float _FadeWidth;
            
			struct VertexInput {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 vertexColor : COLOR;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 vertexColor : COLOR;
				
                float2 localPos : TEXCOORD2;
			};

			VertexOutput vert (VertexInput v) {
				VertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv = v.uv;
				#if ALPHA_MASK
				o.uv1=v.vertex.xyz; 
				#else
				o.localPos = v.vertex.xy;
				#endif
				//mul(unity_ObjectToWorld, v.vertex);  
				o.vertexColor = v.vertexColor;

				return o;
			}

            float GetFadeAlpha(VertexOutput i)
            {
				//Left
				float edge = _FadeEdge.x - _FadeWidth;
				float tLeft = clamp(i.localPos.x, edge, _FadeEdge.x);
				tLeft = (tLeft - edge) / _FadeWidth;
				
				//Right
				edge = _FadeEdge.y + _FadeWidth;
				float tRight = clamp(i.localPos.x, _FadeEdge.y, edge);
				tRight = 1 - (tRight - _FadeEdge.y) / _FadeWidth;
				
				//Bottom
				edge = _FadeEdge.z - _FadeWidth;
				float tBottom = clamp(i.localPos.y, edge, _FadeEdge.z);
				tBottom = (tBottom - edge) / _FadeWidth;
				
				//Top
				edge = _FadeEdge.w + _FadeWidth;
				float tTop = clamp(i.localPos.y, _FadeEdge.w, edge);
				tTop = 1 - (tTop - _FadeEdge.w) / _FadeWidth;
				
				return min( min(tLeft, tRight), min(tBottom, tTop) );
            }

			float4 frag (VertexOutput i) : SV_Target {
				float4 texColor = tex2D(_MainTex, i.uv);
               
				//#if defined(_STRAIGHT_ALPHA_INPUT)
				texColor.rgb *= texColor.a;
				//#endif
                
				#if ALPHA_MASK
                float4 AlphaColor = tex2D(_AlphaTex,TRANSFORM_TEX(i.uv1,_AlphaTex));
				texColor *=AlphaColor.r;
				#else
				texColor *= GetFadeAlpha(i);
                #endif
				#if !NEED_GAMMA
				texColor.rgb = LinearToSRGB(texColor.rgb);
				#endif

				return (texColor * i.vertexColor);
			}
			ENDCG
		}

		Pass {
			Name "Caster"
			Tags { "LightMode"="ShadowCaster" }
			Offset 1, 1
			ZWrite On
			ZTest LEqual

			Fog { Mode Off }
			Cull Off
			Lighting Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			fixed _Cutoff;

			struct VertexOutput {
				V2F_SHADOW_CASTER;
				float4 uvAndAlpha : TEXCOORD1;
			};

			VertexOutput vert (appdata_base v, float4 vertexColor : COLOR) {
				VertexOutput o;
				o.uvAndAlpha = v.texcoord;
				o.uvAndAlpha.a = vertexColor.a;
				TRANSFER_SHADOW_CASTER(o)
				return o;
			}

			float4 frag (VertexOutput i) : SV_Target {
				fixed4 texcol = tex2D(_MainTex, i.uvAndAlpha.xy);
				clip(texcol.a * i.uvAndAlpha.a - _Cutoff);
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
	}
	CustomEditor "SpineShaderWithOutlineGUI"
}
