Shader "Bioum/LowPoly/SceneCommon"
{
	Properties
	{   
		[HDR]_MainColor ("颜色", Color) = (1,1,1,1)
		[HDR]_EmiColor ("自发光颜色", Color) = (0,0,0,1)
		_MainTex ("颜色(RGB)", 2D) = "grey" {} 
		_AddtionTex ("覆盖遮罩", 2D) = "black" {}
		_AddtionColor ("覆盖颜色", Color) = (0.8,0.8,0.8,1)
		_AddtionStrength("覆盖强度", range(0,10)) = 0 
		 
		
		[Header(MatCap)]
		[Toggle(_MATCAP)] _MatToggle("金属贴图", float) = 0
		_MatCap("MatCap", 2D) = "white" {}
		_MaskMap("Mask Tex", 2D) = "white" {}
		_MixLerp ("Mix Lerp", Range(0.0, 1.0)) = 1
    	_MatStrength ("Matcap Strength", Range(0.0, 5.0)) = 1
		
		[Header(Sky)]
		[Toggle(_REFSKY)] _SkyToggle("天空反射", float) = 1
		_SkyTile("天空缩放", range(0,4)) = 1
		_SkyStrength("天空亮度", range(0,1)) = 0.8
		_SkyDistort("天空扭曲强度", range(0,0.2)) = 0.1
		_CloudSpeed("云飘动速度", range(-2,2)) = 0.5
		[NoScaleOffset]_SkyTex("天空贴图", 2D) = "white" {}
		
		[Header(Emisson)]
		[Toggle(_EMI)] _EmiToggle("自发光常亮", float) = 0
        [NoScaleOffset]_MAESTex("emission", 2D) = "white" {}
		
        [NoScaleOffset]_LightMap("lightmap", 2D) = "grey" {}
		
		_NormalScale("法线强度", range(-4, 4)) = 1.0
		_AOStrength("AO强度", range(0,1)) = 1.0
		_Cutoff("透贴强度", range(0, 1)) = 0.5
		_Transparent("透明度", range(0, 1)) = 1
						
		[HideInInspector] _BlendMode ("__BlendMode", Float) = 0.0
		[HideInInspector] _CullMode ("__CullMode", Float) = 0.0
		[HideInInspector] _StencilMode ("__StencilMode", Float) = 3.0
		[HideInInspector] _SrcBlend("__SrcBlend",float) = 1
		[HideInInspector] _DstBlend("__DstBlend",float) = 0
        [HideInInspector] _ZWrite("__ZWrite",float) = 1
		[HideInInspector] _Cull("_ZWrite",float) = 2
	}

	SubShader
	{

		Stencil
		{
			Ref [_StencilMode]
			Comp Gequal
			Pass Replace
		}
		HLSLINCLUDE
			#include "LowPoly-SceneCommon-Input.hlsl"
		ENDHLSL

		Tags{ "RenderType"="Opaque" "Reflection"="On"}

		Pass 
		{
			Name "FORWARD_BASE"
			Blend [_SrcBlend] [_DstBlend] 
            ZWrite [_ZWrite] Cull[_Cull]
            //ZWrite Off
            //ZTest Off
			
			Tags { "LightMode" = "UniversalForward"}
			HLSLPROGRAM
			#pragma target 3.5
            #pragma prefer_hlslcc gles            
			#pragma vertex ForwardBaseVert
			#pragma fragment ForwardBaseFrag
	
			#pragma multi_compile _ _EMI // _EMI会在SceneDayNight里动态开，所以需要用multi_compile
			#pragma shader_feature _ _MATCAP
			#pragma shader_feature _ _REFSKY
			#pragma multi_compile_instancing
			#pragma instancing_options forcemaxcount:127
			#pragma shader_feature __ ENABLE_ALPHATEST ENABLE_PREMULTI
			#include "LowPoly-SceneCommon-Pass.hlsl"
			
			ENDHLSL
		}
		
		Pass
        {
            Name "PrePass"
            Tags{"LightMode" = "CustomPrePass"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma shader_feature_local _ALPHATEST_ON
            #pragma multi_compile_local _ SICKNESS_MAP

            #include "ShaderLibrary/DepthOnlyPass-Scene.hlsl"
            ENDHLSL
        }

	}
	CustomEditor "BArtLib.LowPolySceneCommonGUI"
}
