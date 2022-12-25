// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SlgEffect/Slg_Additive"
{
	Properties
	{
		_MainTex("主贴图", 2D) = "white" {}
		_Power("贴图强度", Float) = 1
		[HDR]_MainTex_Color("主贴图颜色", Color) = (1,1,1,1)
		_MainTexSpeedX("主贴图X方向速度", Float) = 0
		_MainTexSpeedY("主贴图Y方向速度", Float) = 0
		[Toggle(_SECONDTEX_ON_ON)] _SecondTex_ON("二层贴图开关", Float) = 0
		_SecondTex("二层贴图", 2D) = "white" {}
		[HDR]_SecondTexColor("二层贴图颜色", Color) = (1,1,1,1)
		_SecondTexSpeedX("二层贴图X方向速度", Float) = 0
		_SecondTexSpeedY("二层贴图Y方向速度", Float) = 0
		[Toggle(_DISTORTION_ON)] _Distortion("自扭曲功能开关", Float) = 0
		_DistortionTex("自扭曲贴图", 2D) = "white" {}
		_DistortionMaskStr("自扭曲强度", Range( 0 , 5)) = 0
		_DistortionSpeedX("自扭曲贴图X方向速度", Float) = 0
		_DistortionSpeedY("自扭曲贴图Y方向速度", Float) = 0
		_DistortionMaskTex("自扭曲贴图遮罩", 2D) = "white" {}
		[Toggle(_DISSOLVE_ON)] _Dissolve("溶解功能开关", Float) = 0
		_DissolveTex("溶解贴图", 2D) = "white" {}
		[Toggle(_DISSOLVEUV_ON)] _DissolveUv("溶解方式控制功能切换", Float) = 0
		_DissolveValue("溶解强度", Range( 0 , 1.15)) = 0
		_DissolveWidth("溶解边沿宽度", Range( 0 , 1)) = 0
		[HDR]_DissolveEdgeColor("溶解边沿颜色", Color) = (1,1,1,1)
		[Toggle(_MASK_ON)] _Mask("遮罩贴图开关", Float) = 0
		_MaskTex("遮罩贴图", 2D) = "white" {}
		_MaskTexPower("遮罩强度", Range( 0 , 10)) = 1
		[Toggle(_MASKTEX_UV_ON)] _MaskTex_Uv("遮罩Uv方式控制切换", Float) = 0
		_MaskTexSpeedX1("遮罩贴图X方向速度", Float) = 0
		_MaskTexSpeedY1("遮罩贴图Y方向速度", Float) = 0
		[Toggle(_RIM_ON)] _Rim("模型菲涅尔效果开关", Float) = 0
		[Toggle(_RIM_BOTHSIDE_ON)] _RIM_BothSide("特效渲染双面", Float) = 0
		_RimMin("菲涅尔光晕最小值", Range( 0 , 1)) = 0
		_RimMax("菲涅尔光晕最大值", Range( 0 , 1)) = 1
		_RimSmooth("菲涅尔光照递减强度", Range( 0 , 1)) = 1
		_RimIntensity("菲涅尔光照递减透明度", Range( 0 , 1)) = 1
		_ClipRect("Clip Rect", Vector) = (-9999999,-9999999,9999999,9999999)
		_SoftClipRect("Soft Clip Rect", Vector) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline"}
	LOD 100

		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		Blend SrcAlpha One
		AlphaToMask Off
		Cull Off
		ColorMask RGB
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="UniversalForward" }
			HLSLPROGRAM

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			//#include "UnityCG.cginc"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			//#include "UnityShaderVariables.cginc"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature _DISTORTION_ON
			#pragma shader_feature _SECONDTEX_ON_ON
			#pragma shader_feature _DISSOLVE_ON
			#pragma shader_feature _DISSOLVEUV_ON
			#pragma shader_feature _MASK_ON
			#pragma shader_feature _MASKTEX_UV_ON
			#pragma shader_feature _RIM_ON
			#pragma shader_feature _RIM_BOTHSIDE_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				half3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform half4 _ClipRect;
			uniform half4 _SoftClipRect;
			uniform half4 _MainTex_Color;
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			uniform half _MainTexSpeedX;
			uniform half _MainTexSpeedY;
			uniform sampler2D _DistortionTex;
			uniform half4 _DistortionTex_ST;
			uniform half _DistortionSpeedX;
			uniform half _DistortionSpeedY;
			uniform sampler2D _DistortionMaskTex;
			uniform half4 _DistortionMaskTex_ST;
			uniform half _DistortionMaskStr;
			uniform half _Power;
			uniform half4 _SecondTexColor;
			uniform sampler2D _SecondTex;
			uniform half4 _SecondTex_ST;
			uniform half _SecondTexSpeedX;
			uniform half _SecondTexSpeedY;
			uniform half _DissolveValue;
			uniform half _DissolveWidth;
			uniform sampler2D _DissolveTex;
			uniform half4 _DissolveTex_ST;
			uniform half4 _DissolveEdgeColor;
			uniform sampler2D _MaskTex;
			uniform half4 _MaskTex_ST;
			uniform half _MaskTexSpeedX1;
			uniform half _MaskTexSpeedY1;
			uniform half _MaskTexPower;
			uniform half _RimMin;
			uniform half _RimMax;
			uniform half _RimSmooth;
			uniform half _RimIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				half2 uv_MaskTex = v.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				half2 uv2_MaskTex = v.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				half2 break242 = uv2_MaskTex;
				half2 appendResult243 = (half2(break242.x , break242.y));
				half4 appendResult97 = (half4(_MaskTexSpeedX1 , _MaskTexSpeedY1 , 0.0 , 0.0));
				#ifdef _MASKTEX_UV_ON
				half4 staticSwitch244 = ( _Time.y * appendResult97 );
				#else
				half4 staticSwitch244 = half4( appendResult243, 0.0 , 0.0 );
				#endif
				half4 vertexToFrag102 = ( half4( uv_MaskTex, 0.0 , 0.0 ) + staticSwitch244 );
				o.ase_texcoord3 = vertexToFrag102;
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				o.ase_texcoord2 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = TransformObjectToHClip(v.vertex.xyz);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			half4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				half4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				half2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half2 appendResult9 = (half2(_MainTexSpeedX , _MainTexSpeedY));
				half2 uv_DistortionTex = i.ase_texcoord1.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				half4 appendResult57 = (half4(_DistortionSpeedX , _DistortionSpeedY , 0.0 , 0.0));
				float2 uv_DistortionMaskTex = i.ase_texcoord1.xy * _DistortionMaskTex_ST.xy + _DistortionMaskTex_ST.zw;
				#ifdef _DISTORTION_ON
				half staticSwitch68 = ( ( tex2D( _DistortionTex, ( half4( uv_DistortionTex, 0.0 , 0.0 ) + ( _Time.y * appendResult57 ) ).xy ).r - 0.0 ) * tex2D( _DistortionMaskTex, uv_DistortionMaskTex ).a * _DistortionMaskStr );
				#else
				half staticSwitch68 = 0.0;
				#endif
				half Distortion69 = staticSwitch68;
				half4 tex2DNode3 = tex2D( _MainTex, ( uv_MainTex + ( _Time.y * appendResult9 ) + Distortion69 ) );
				half3 temp_cast_2 = (_Power).xxx;
				half4 appendResult25 = (half4(( (_MainTex_Color).rgb * pow( abs(tex2DNode3).rgb , temp_cast_2 ) ) , ( _MainTex_Color.a * tex2DNode3.a )));
				half4 MainTexColor26 = appendResult25;
				half4 color49 = half4(1,1,1,1);
				half2 uv_SecondTex = i.ase_texcoord1.xy * _SecondTex_ST.xy + _SecondTex_ST.zw;
				half2 appendResult42 = (half2(_SecondTexSpeedX , _SecondTexSpeedY));
				#ifdef _SECONDTEX_ON_ON
				half4 staticSwitch52 = ( _SecondTexColor * tex2D( _SecondTex, ( uv_SecondTex + ( _Time.y * appendResult42 ) ) ) );
				#else
				half4 staticSwitch52 = color49;
				#endif
				half4 SecondTexColor53 = staticSwitch52;
				half4 color157 = half4(0,0,0,0);
				#ifdef _DISSOLVEUV_ON
				half staticSwitch145 = i.ase_texcoord2.w;
				#else
				half staticSwitch145 = _DissolveValue;
				#endif
				float2 uv_DissolveTex = i.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				half smoothstepResult150 = smoothstep( max( ( staticSwitch145 - _DissolveWidth ) , 0.0 ) , staticSwitch145 , tex2D( _DissolveTex, uv_DissolveTex ).a);
				#ifdef _DISSOLVE_ON
				half4 staticSwitch159 = half4( (( ( 1.0 - smoothstepResult150 ) * _DissolveEdgeColor )).rgb , 0.0 );
				#else
				half4 staticSwitch159 = color157;
				#endif
				half4 DissolveEdgeColor160 = staticSwitch159;
				#ifdef _DISSOLVE_ON
				half staticSwitch153 = smoothstepResult150;
				#else
				half staticSwitch153 = 1.0;
				#endif
				half Dissolve140 = staticSwitch153;
				half4 temp_cast_6 = (1.0).xxxx;
				half4 vertexToFrag102 = i.ase_texcoord3;
				#ifdef _MASK_ON
				half4 staticSwitch104 = ( tex2D( _MaskTex, vertexToFrag102.xy ) * _MaskTexPower );
				#else
				half4 staticSwitch104 = temp_cast_6;
				#endif
				half4 Mask105 = staticSwitch104;
				half3 ase_worldNormal = i.ase_texcoord4.xyz;
				float3 ase_worldViewDir = SafeNormalize(GetCameraPositionWS()-i.worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				half watchSide = saturate(dot( ase_worldNormal , ase_worldViewDir ));
				half backSide = saturate(dot( ase_worldNormal , -ase_worldViewDir ));
				half bothSide = watchSide+backSide;
				#ifdef _RIM_ON
				   #ifdef _RIM_BOTHSIDE_ON
				     half smoothstepResult217 = smoothstep( _RimMin , _RimMax , bothSide);
				   #else
				     half smoothstepResult217 = smoothstep( _RimMin , _RimMax , watchSide);
				   #endif
				half staticSwitch231 = ( pow( smoothstepResult217 , _RimSmooth ) * _RimIntensity );
				#else
				half staticSwitch231 = 1.0;
				#endif
				half Rim232 = staticSwitch231;
				half4 appendResult122 = (half4(( half4( ( (MainTexColor26).xyz * (SecondTexColor53).rgb * (i.ase_color).rgb ) , 0.0 ) + DissolveEdgeColor160 ).rgb , saturate( ( (MainTexColor26).w * (SecondTexColor53).a * i.ase_color.a * Dissolve140 * Mask105 * Rim232 ) ).r));

				finalColor = appendResult122;
				finalColor.a *= lerp(0, 1, saturate((WorldPosition.x - _ClipRect.x) / _SoftClipRect.x));
				finalColor.a *= lerp(0, 1, saturate((_ClipRect.z - WorldPosition.x) / _SoftClipRect.z));
				finalColor.a *= lerp(0, 1, saturate((WorldPosition.y - _ClipRect.y) / _SoftClipRect.y));
				finalColor.a *= lerp(0, 1, saturate((_ClipRect.w - WorldPosition.y) / _SoftClipRect.w));

				finalColor.rgb *= finalColor.a;
				return finalColor;
			}
			ENDHLSL
		}
	}
	//CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;12;1882;1006;2238.388;-1750.634;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;70;-2295.234,-381.5201;Inherit;False;2151.133;782;自扭曲;15;55;57;60;61;59;62;63;64;66;56;58;67;65;68;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2245.234,122.2721;Inherit;False;Property;_DistortionSpeedX;自扭曲贴图X方向速度;13;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-2241.234,251.2732;Inherit;False;Property;_DistortionSpeedY;自扭曲贴图Y方向速度;14;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;56;-2204.171,-67.22684;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;57;-1998.232,149.2721;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;60;-2084.122,-261.4747;Inherit;False;0;62;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1820.232,58.27223;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1644.121,-65.47464;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;62;-1475.023,-165.9389;Inherit;True;Property;_DistortionTex;自扭曲贴图;11;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;64;-1404.761,37.57079;Inherit;True;Property;_DistortionMaskTex;自扭曲贴图遮罩;15;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-1118.853,-160.3019;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1405.761,291.5707;Inherit;False;Property;_DistortionMaskStr;自扭曲强度;12;0;Create;False;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1025.836,-331.5201;Inherit;False;Constant;_Distortion_OFF;Distortion_OFF;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;28;-2298.148,-2553.505;Inherit;False;2602.448;1052.277;主贴图;18;4;25;23;22;21;20;17;18;16;13;3;10;5;9;7;6;26;71;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-924.4172,-0.08511853;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;106;-2498.563,1782.653;Inherit;False;2330.949;1061.205;遮罩;18;244;243;242;241;96;97;95;99;98;105;104;103;94;102;101;100;245;246;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;68;-762.2161,-257.4566;Inherit;False;Property;_Distortion;自扭曲功能开关;10;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-2190.148,-1616.228;Inherit;False;Property;_MainTexSpeedY;主贴图Y方向速度;4;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2228.148,-1733.229;Inherit;False;Property;_MainTexSpeedX;主贴图X方向速度;3;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;54;-2298.972,-1407.605;Inherit;False;2432.396;838.0331;二层贴图;13;53;52;45;40;39;49;42;41;43;38;44;47;37;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-478.4622,-126.2021;Inherit;False;Distortion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;-2001.147,-1731.229;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TimeNode;4;-2248.148,-1984.229;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;126;-2364.725,636.3885;Inherit;False;3085.904;880.7646;溶解;18;140;138;143;144;145;146;147;149;150;151;153;154;155;156;157;158;159;160;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;241;-2480,2112;Inherit;False;1;94;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;99;-2435.32,2742.999;Inherit;False;Property;_MaskTexSpeedY1;遮罩贴图Y方向速度;27;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-2439.32,2613.998;Inherit;False;Property;_MaskTexSpeedX1;遮罩贴图X方向速度;26;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;242;-2202,2117;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;97;-2203.3,2671.748;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-1826.634,-1821.672;Inherit;True;69;Distortion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;143;-2301.504,1021.028;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-2070.324,-814.8612;Inherit;False;Property;_SecondTexSpeedX;二层贴图X方向速度;8;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-2207.148,-2273.228;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;210;-2261.254,3156.245;Inherit;False;2124.596;936.1372;菲涅尔功能;11;232;231;225;224;221;220;219;217;216;215;211;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-2301.298,699.8842;Inherit;False;Property;_DissolveValue;溶解强度;19;0;Create;False;0;0;0;False;0;False;0;0.4764194;0;1.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;95;-2398.257,2424.499;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-2033.324,-696.8601;Inherit;False;Property;_SecondTexSpeedY;二层贴图Y方向速度;9;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-1860.147,-1986.229;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;243;-2035.353,2176.968;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-1843.322,-812.8612;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-2020.317,2485.998;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;145;-2011.337,938.1118;Inherit;False;Property;_DissolveUv;溶解方式控制功能切换;18;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1637.147,-2051.229;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-2045.779,1153.789;Inherit;False;Property;_DissolveWidth;溶解边沿宽度;20;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;211;-2211.254,3211.893;Inherit;False;491;545;菲涅尔;3;214;213;212;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TimeNode;41;-2049.26,-1029.36;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1384.148,-2095.229;Inherit;True;Property;_MainTex;主贴图;0;0;Create;False;0;0;0;False;0;False;-1;None;a9dac2d4aaad0654892cb58b03451d21;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1665.322,-902.8611;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;146;-1666.012,827.0315;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;213;-2199.254,3251.893;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-2049.899,-1189.699;Inherit;False;0;37;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;212;-2201.254,3598.893;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;244;-1888.895,2273.685;Inherit;False;Property;_MaskTex_Uv;遮罩Uv方式控制切换;25;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;100;-2177.108,1924.301;Inherit;False;0;94;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-1469.585,-1093.391;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;215;-2205.835,3981.308;Inherit;False;Property;_RimMax;菲涅尔光晕最大值;30;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;16;-970.4393,-2176.505;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-2206,3795.245;Inherit;False;Property;_RimMin;菲涅尔光晕最小值;29;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-1627.852,2024.737;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;149;-1404.677,705.8521;Inherit;True;Property;_DissolveTex;溶解贴图;17;0;Create;False;0;0;0;False;0;False;-1;None;374fcdc3004fb824ebce30b96b6b1a02;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;20;-848.4393,-2503.505;Inherit;False;Property;_MainTex_Color;主贴图颜色;2;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-973.4393,-1893.506;Inherit;False;Property;_Power;贴图强度;1;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;214;-1957.254,3340.893;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;151;-1403.011,933.6296;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;150;-1101.329,1024.586;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;217;-1656.886,3666.504;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;-1221.622,-1292.622;Inherit;False;Property;_SecondTexColor;二层贴图颜色;7;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;18;-712.4391,-2036.505;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;102;-1471.677,1920.624;Inherit;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;22;-583.6996,-2499.949;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-1534.037,3980.203;Inherit;False;Property;_RimSmooth;菲涅尔光照递减强度;31;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-1278.494,-1027.324;Inherit;True;Property;_SecondTex;二层贴图;6;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-328.6996,-2499.949;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;49;-867.6012,-1357.605;Inherit;False;Constant;_MainTex_Color_De;_MainTex_Color_De;2;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;245;-1144.679,2310.701;Inherit;False;Property;_MaskTexPower;遮罩强度;24;0;Create;False;0;0;0;False;0;False;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;94;-1211.672,1952.787;Inherit;True;Property;_MaskTex;遮罩贴图;23;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;155;-896.3557,1283.184;Inherit;False;Property;_DissolveEdgeColor;溶解边沿颜色;21;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;154;-737.6532,1024.072;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;220;-1147.317,3797.416;Inherit;False;Property;_RimIntensity;菲涅尔光照递减透明度;32;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-584.6996,-2321.949;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;221;-1271.853,3410.829;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-876.0533,-1038.527;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-1021.705,1832.653;Inherit;False;Constant;_MaskTex_OFF;MaskTex_OFF;25;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;-136.6998,-2325.949;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;246;-856.6792,2048.701;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;52;-510.2277,-1154.53;Inherit;True;Property;_SecondTex_ON;二层贴图开关;5;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;-505.6532,1148.072;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-919.0023,742.7802;Inherit;False;Constant;_Dissolve_OFF;Dissolve_OFF;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;224;-1024,3248.245;Inherit;False;Constant;_Rim_OFF;Rim_OFF;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;-890.5372,3410.003;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;157;-342.6532,905.0723;Inherit;False;Constant;_Color0;Color 0;26;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;104;-699.7049,1922.653;Inherit;False;Property;_Mask;遮罩贴图开关;22;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;153;-699.6532,861.0723;Inherit;False;Property;_Dissolve;溶解功能开关;16;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;158;-254.6532,1149.072;Inherit;True;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-122.9737,-1149.255;Inherit;False;SecondTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;231;-632.9997,3281.245;Inherit;False;Property;_Rim;模型菲涅尔效果开关;28;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;61.29954,-2370.949;Inherit;False;MainTexColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;115;771.7773,-385.1475;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-379.7348,702.205;Inherit;False;Dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;159;7.346802,1022.072;Inherit;True;Property;_Dissolve;Dissolve;16;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;153;False;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;232;-383.4104,3536.907;Inherit;False;Rim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;644.7349,-896.2446;Inherit;False;53;SecondTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-388.7049,2101.653;Inherit;False;Mask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;646.0358,-1150.927;Inherit;False;26;MainTexColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;110;1086.735,-997.2446;Inherit;True;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;112;1151.735,-641.2446;Inherit;False;FLOAT;3;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;370.3468,990.0723;Inherit;False;DissolveEdgeColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;108;1046.12,-1232.24;Inherit;True;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;1019.556,-126.9189;Inherit;False;105;Mask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;1150.448,-262.6903;Inherit;False;140;Dissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;111;1087.735,-767.2446;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;113;1153.735,-509.2446;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;1089.007,2.975586;Inherit;False;232;Rim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;1413.777,-859.1475;Inherit;True;160;DissolveEdgeColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;1410.077,-1151.147;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;1537.823,-512.9268;Inherit;True;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;124;1935.228,-662.915;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;1736.228,-961.915;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;122;2201.131,-960.191;Inherit;True;COLOR;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;209;2562.269,-926.6348;Half;False;True;-1;2;ASEMaterialInspector;100;1;SlgEffect/Slg_Additive;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;8;5;False;-1;1;False;-1;0;5;False;-1;10;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;False;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;57;0;58;0
WireConnection;57;1;59;0
WireConnection;55;0;56;2
WireConnection;55;1;57;0
WireConnection;61;0;60;0
WireConnection;61;1;55;0
WireConnection;62;1;61;0
WireConnection;63;0;62;1
WireConnection;65;0;63;0
WireConnection;65;1;64;4
WireConnection;65;2;66;0
WireConnection;68;1;67;0
WireConnection;68;0;65;0
WireConnection;69;0;68;0
WireConnection;9;0;6;0
WireConnection;9;1;7;0
WireConnection;242;0;241;0
WireConnection;97;0;98;0
WireConnection;97;1;99;0
WireConnection;5;0;4;2
WireConnection;5;1;9;0
WireConnection;243;0;242;0
WireConnection;243;1;242;1
WireConnection;42;0;39;0
WireConnection;42;1;40;0
WireConnection;96;0;95;2
WireConnection;96;1;97;0
WireConnection;145;1;144;0
WireConnection;145;0;143;4
WireConnection;10;0;13;0
WireConnection;10;1;5;0
WireConnection;10;2;71;0
WireConnection;3;1;10;0
WireConnection;43;0;41;2
WireConnection;43;1;42;0
WireConnection;146;0;145;0
WireConnection;146;1;147;0
WireConnection;244;1;243;0
WireConnection;244;0;96;0
WireConnection;44;0;38;0
WireConnection;44;1;43;0
WireConnection;16;0;3;0
WireConnection;101;0;100;0
WireConnection;101;1;244;0
WireConnection;214;0;213;0
WireConnection;214;1;212;0
WireConnection;151;0;146;0
WireConnection;150;0;149;4
WireConnection;150;1;151;0
WireConnection;150;2;145;0
WireConnection;217;0;214;0
WireConnection;217;1;216;0
WireConnection;217;2;215;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;102;0;101;0
WireConnection;22;0;20;0
WireConnection;37;1;44;0
WireConnection;23;0;22;0
WireConnection;23;1;18;0
WireConnection;94;1;102;0
WireConnection;154;0;150;0
WireConnection;21;0;20;4
WireConnection;21;1;3;4
WireConnection;221;0;217;0
WireConnection;221;1;219;0
WireConnection;47;0;45;0
WireConnection;47;1;37;0
WireConnection;25;0;23;0
WireConnection;25;3;21;0
WireConnection;246;0;94;0
WireConnection;246;1;245;0
WireConnection;52;1;49;0
WireConnection;52;0;47;0
WireConnection;156;0;154;0
WireConnection;156;1;155;0
WireConnection;225;0;221;0
WireConnection;225;1;220;0
WireConnection;104;1;103;0
WireConnection;104;0;246;0
WireConnection;153;1;138;0
WireConnection;153;0;150;0
WireConnection;158;0;156;0
WireConnection;53;0;52;0
WireConnection;231;1;224;0
WireConnection;231;0;225;0
WireConnection;26;0;25;0
WireConnection;140;0;153;0
WireConnection;159;1;157;0
WireConnection;159;0;158;0
WireConnection;232;0;231;0
WireConnection;105;0;104;0
WireConnection;110;0;109;0
WireConnection;112;0;107;0
WireConnection;160;0;159;0
WireConnection;108;0;107;0
WireConnection;111;0;115;0
WireConnection;113;0;109;0
WireConnection;116;0;108;0
WireConnection;116;1;110;0
WireConnection;116;2;111;0
WireConnection;118;0;112;0
WireConnection;118;1;113;0
WireConnection;118;2;115;4
WireConnection;118;3;119;0
WireConnection;118;4;120;0
WireConnection;118;5;240;0
WireConnection;124;0;118;0
WireConnection;121;0;116;0
WireConnection;121;1;117;0
WireConnection;122;0;121;0
WireConnection;122;3;124;0
WireConnection;209;0;122;0
ASEEND*/
//CHKSM=9BA86A6CE5175C61E6339EBFE4E0337D9B143B93