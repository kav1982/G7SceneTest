// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.


Shader "X7/GPUInstance"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_AnimMap ("AnimMap", 2D) ="white" {}
		_TexIndex("_TexIndex", Float) = 0
		_VertexNum("_VertexNum", Float) = 0
		_StartIndex("_StartIndex", Float) = 0
		_Frame("_Frame", Float) = 1
		_IsLoop("_IsLoop", Float) = 1
		_Speed("_Speed", Float) = 1
		_StartVec("Start", Vector) = (0,0,0,0)
		_StepVec("Step", Vector) = (0,0,0,0)

		[Header(ColorShift)]
		[Toggle(QR_COLOR_SHIFT)]_ColorShift("偏色", float) = 0
		[NoScaleOffset]_ColorShiftTex("遮罩", 2D) = "black" {}
		_Sensitivitry1("色相", Range(0, 1)) = 0
		_Sensitivitry2("饱和度", Range(0, 1)) = 0

		[HideInInspector]_ColorShiftSrcHSV1("", Vector) = (0, 0, 0, 1)
		[HideInInspector]_ColorShiftDstHSV1("", Vector) = (0, 0, 0, 1)
	}
	SubShader
	{
		Tags 
		{ 
			"Queue"="Geometry+200"
			"RenderType"="Opaque"
		}
		LOD 100
		Cull back
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//开启gpu instancing
			#pragma multi_compile_instancing
			//#pragma multi_compile_fog
			#pragma shader_feature_local_fragment _ QR_COLOR_SHIFT
			#pragma target 3.0
			
			//#include "UnityCG.cginc"
			#include "../ShaderLibrary/QRColorShift.hlsl"
			#include "../ShaderLibrary/Fog.hlsl"

			struct appdata
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float fog: TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _AnimMap;
			float4 _AnimMap_TexelSize;//x == 1/width

			float _VertexNum;

			UNITY_INSTANCING_BUFFER_START(Props)
				UNITY_DEFINE_INSTANCED_PROP(float, _TexIndex)
#define _TexIndex_arr Props
				UNITY_DEFINE_INSTANCED_PROP(float, _InitTime)
#define _InitTime_arr Props
				UNITY_DEFINE_INSTANCED_PROP(float, _StartIndex)
#define _StartIndex_arr Props
				UNITY_DEFINE_INSTANCED_PROP(float, _Frame)
#define _Frame_arr Props
				UNITY_DEFINE_INSTANCED_PROP(float, _IsLoop)
#define _IsLoop_arr Props
				UNITY_DEFINE_INSTANCED_PROP(float, _Speed)
#define _Speed_arr Props
				UNITY_DEFINE_INSTANCED_PROP(float4, _StartVec)
#define _StartVec_arr Props
				UNITY_DEFINE_INSTANCED_PROP(float4, _StepVec)
#define _StepVec_arr Props
				UNITY_DEFINE_INSTANCED_PROP(float, _ColorShift)
#define _ColorShift_arr Props
			UNITY_INSTANCING_BUFFER_END(Props)
			
			v2f vert (appdata v)
			{		
				UNITY_SETUP_INSTANCE_ID(v);
				float frame = UNITY_ACCESS_INSTANCED_PROP(_Frame_arr, _Frame);	
				float start = UNITY_ACCESS_INSTANCED_PROP(_StartIndex_arr, _StartIndex);
				float loopTemp = (1 - UNITY_ACCESS_INSTANCED_PROP(_IsLoop_arr, _IsLoop));
					
				float frame_time = frame/24.0;
				float f = (_Time.y - UNITY_ACCESS_INSTANCED_PROP(_InitTime_arr, _InitTime))*UNITY_ACCESS_INSTANCED_PROP(_Speed_arr, _Speed)/frame_time;
				float _CurIndex = 0;
				
				float isOnceAnim = f * loopTemp;
				f = fmod(f, 1.0);
				f = min(f,1);
				f = max(min(isOnceAnim,1.0),f);
				float pass_frame = floor(f*frame);
				
				_CurIndex = min(start + frame - 1, start + pass_frame);
				
				
				float temp = _CurIndex*_VertexNum + v.uv2.x;

				float animMap_x = ((fmod(temp,_AnimMap_TexelSize.w))+0.5) * _AnimMap_TexelSize.x;
				float animMap_y = (floor(temp/_AnimMap_TexelSize.w)) * _AnimMap_TexelSize.y;

				float3 pos = tex2Dlod(_AnimMap, float4(animMap_x, animMap_y, 0, 0)).rgb;
				float4 _start = UNITY_ACCESS_INSTANCED_PROP(_StartVec_arr, _StartVec);
				float4 _step = UNITY_ACCESS_INSTANCED_PROP(_StepVec_arr, _StepVec);
				float3 real_pos = float3(_start.x + pos.x*_step.x, _start.y + pos.y*_step.y, _start.z + pos.z*_step.z);

				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float _tex_index = UNITY_ACCESS_INSTANCED_PROP(_TexIndex_arr, _TexIndex);
				o.uv.x += 0.5*(_tex_index%2);
				o.uv.y += 0.5*floor(_tex_index/2);
				//需要把贴图拆成4份,
				o.vertex = TransformObjectToHClip(real_pos);
				float positionWSy = TransformObjectToWorld(real_pos).y;
				o.fog = ComputeXYJFogFactor(ComputeScreenPos(o.vertex / o.vertex.w).xy, positionWSy);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				half4 col = tex2D(_MainTex, i.uv);
				clip(col.a - 0.5f);
				col.rgb = lerp(col.rgb, colorShift(col, i.uv).rgb, UNITY_ACCESS_INSTANCED_PROP(_ColorShift_arr, _ColorShift));
				col.rgb = MixXYJFogColor(col.rgb, i.fog);
				return col;
			}
			ENDHLSL
		}
	}
}
