// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

// Upgrade NOTE: upgraded instancing buffer 'GIS_Props' to new syntax.


Shader "X7/GPUInstanceShadow"
{
	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}
		_AnimMap ("AnimMap", 2D) ="white" {}
		_TexIndex("_TexIndex", Float) = 0
		_VertexNum("_VertexNum", Float) = 0
		_StartIndex("_StartIndex", Float) = 0
		_Frame("_Frame", Float) = 1
		_IsLoop("_IsLoop", Float) = 1
		_Speed("_Speed", Float) = 1
		_StartVec("Start", Vector) = (0,0,0,0)
		_StepVec("Step", Vector) = (0,0,0,0)
		_ShadowProjDir("lightdir", Vector) = (0.6,3,-2,0)
		_ShadowPlane("ShadowPlane", Vector) = (0, 5, 0, 0.15)
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque"  "IgnoreProjector"="True" "Queue" = "Geometry+50" }
			LOD 200
			Cull off
			Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Blend One OneMinusSrcAlpha
			ZWrite off	
			//ZClip Off
			//ZTest Off
			Cull Back
			ColorMask RGB
			//INSTANCING_ON

			Stencil
			{
				Ref 0
				Comp Equal
				WriteMask 255
				ReadMask 255
				Pass Invert
				Fail Keep
				ZFail Keep
			}

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//开启gpu instancing
			#pragma multi_compile_instancing
			//#pragma multi_compile_fog
			#pragma target 3.0
			
			#include "../ShaderLibrary/Fog.hlsl"

			struct appdata
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				//float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float fog: TEXCOORD1;
				//float fogCoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			//sampler2D _MainTex;
			//float4 _MainTex_ST;

			sampler2D _AnimMap;
			float4 _AnimMap_TexelSize;//x == 1/width


			UNITY_INSTANCING_BUFFER_START(Props)
			   UNITY_DEFINE_INSTANCED_PROP(float4, _StartVec)
#define _StartVec_arr Props
			   UNITY_DEFINE_INSTANCED_PROP(float4, _StepVec)
#define _StepVec_arr Props
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
				UNITY_DEFINE_INSTANCED_PROP(float3, _ShadowProjDir)
#define _ShadowProjDir_arr Props
				UNITY_DEFINE_INSTANCED_PROP(float4, _ShadowPlane)
#define _ShadowPlane_arr Props
			UNITY_INSTANCING_BUFFER_END(Props)
			float _VertexNum;
			
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
				float3 real_pos = float3(_start.x + pos.x * _step.x, _start.y + pos.y * _step.y, _start.z + pos.z * _step.z);

				v2f o;
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//float _tex_index = UNITY_ACCESS_INSTANCED_PROP(_TexIndex);
				//o.uv.x += 0.5*(_tex_index%2);
				//o.uv.y += 0.5*floor(_tex_index/2);
				//需要把贴图拆成4份,
				float3 lightdir = normalize(UNITY_ACCESS_INSTANCED_PROP(_ShadowProjDir_arr, _ShadowProjDir));
				float3 worldpos = TransformObjectToWorld(real_pos).xyz;
				float4 ShadowPlane = UNITY_ACCESS_INSTANCED_PROP(_ShadowPlane_arr, _ShadowPlane);
				float distance = (ShadowPlane.w - dot(ShadowPlane.xyz, worldpos)) / dot(ShadowPlane.xyz, lightdir.xyz);
				worldpos = worldpos + distance * lightdir.xyz;
				o.vertex = mul(unity_MatrixVP, float4(worldpos, 1.0));
				o.fog = ComputeXYJFogFactor(ComputeScreenPos(o.vertex / o.vertex.w).xy, worldpos.y);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				half4 col = float4(0.0, 0.0, 0.0,0.45);
				col.rgb *= 0.45;
				col.rgb = MixXYJFogColor(col.rgb, i.fog);
				return col;
				//UNITY_CALC_FOG_FACTOR(i.fogCoord);
				//return float4(0.0, 0.0, 0.0, 0.45 * unityFogFactor);
				//float fogFac = i.fogCoord.x * unity_FogParams.z + unity_FogParams.w;
				//float fogFac = i.fogCoord.x * -0.125 + 2.5;
				//return float4(0.0, 0.0, 0.0, 0.45 * fogFac);
			}
			ENDHLSL
		}
	}

	FallBack Off
}
