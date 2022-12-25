
Shader "Bioum/Scene/SceneTerrianMask"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5

		_Splat0("Layer 1", 2D) = "white" {}
		_Splat1("Layer 2", 2D) = "white" {}
		_Splat2("Layer 3", 2D) = "white" {}
		_Splat3("Layer 4", 2D) = "white" {}
		_SplatScale0 ("scale0", float) = 5
        _SplatScale1 ("scale1", float) = 5
        _SplatScale2 ("scale2", float) = 5
        _SplatScale3 ("scale3", float) = 5
        _SplatScale ("scale", vector) = (5,5,5,5)
		[Toggle(_NORMALMAP)] _NormalMapToggle("", float) = 0
		_Normal0("Normalmap 1", 2D) = "bump" {}
		_Normal1("Normalmap 2", 2D) = "bump" {}
		_Normal2("Normalmap 3", 2D) = "bump" {}
		_Normal3("Normalmap 4", 2D) = "bump" {}
		_NormalScale0 ("法线强度", range(-4, 4)) = 1
		_NormalScale1 ("法线强度", range(-4, 4)) = 1
		_NormalScale2 ("法线强度", range(-4, 4)) = 1
		_NormalScale3 ("法线强度", range(-4, 4)) = 1
		_NormalScale ("法线强度", vector) = (1,1,1,1)
		_Control("Control", 2D) = "white" {}

		[ToggleUI]_VertexAO("顶点色AO开关",float) = 0
		_VertexAOStrength("顶点色AO强度",Range(0.01,5)) = 1
		_VertexAOCol("AO颜色",Color) = (0,0,0,1)
		_AOColStrength("AO颜色强度",Range(0,3)) = 1
		_VertexAOParam("顶点色AO参数",vector) = (0,0,0,1)

		//_LightIntensity ("灯光强度", range(0, 4)) = 1
		_PenumbraTintColor ("半影色调", color) = (0.5, 0.5, 0.5, 1)

		[HideInInspector] _TexCount ("__TexCount", float) = 2.0
		[HideInInspector] _LightingModel ("__LightingModel", float) = 0.0

	}

	SubShader
	{
		LOD 0

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry-10" }
		Cull Back
		AlphaToMask Off
		
		
		
		Pass
		{

			Name "Forward"
			Tags { "LightMode" = "TerrainBlend" }

			HLSLPROGRAM

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 3.0
			//#pragma multi_compile_instancing
			#pragma multi_compile_fog

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF

			#pragma multi_compile _ LIGHTMAP_ON

			#pragma shader_feature TERRAIN_2TEX TERRAIN_3TEX TERRAIN_4TEX
			#pragma shader_feature LIGHTMODEL_LAMBERT LIGHTMODEL_NOLIGHT
			#pragma shader_feature_local _ _NORMALMAP
			#pragma shader_feature _ _VERTEXAO_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD
			#define _TERRAIN_BLEND

			#include"SceneTerrianMaskInput.hlsl"
			#include"SceneTerrianMaskPass.hlsl"

			ENDHLSL
		}
		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			Stencil
			{
				Ref 0
				Comp Equal
			}
			
			HLSLPROGRAM
			
			#pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0
			//#pragma multi_compile_instancing
			#pragma multi_compile_fog

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma shader_feature TERRAIN_2TEX TERRAIN_3TEX TERRAIN_4TEX
			#pragma shader_feature LIGHTMODEL_LAMBERT LIGHTMODEL_NOLIGHT
			#pragma shader_feature_local _ _NORMALMAP
			#pragma shader_feature _ _VERTEXAO_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include"SceneTerrianMaskInput.hlsl"
			#include"SceneTerrianMaskPass.hlsl"

			ENDHLSL
		}
		
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma shader_feature_local _ _ALPHATEST_ON
            #pragma shader_feature_local _ _DITHER_CLIP

            #define _HIGH_QUALITY

            #include "ShaderLibrary/DepthOnlyPass-Scene.hlsl"
            ENDHLSL
        }
		
		Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            
			float4 _BASEMAP_ST;
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
            
			#include "ShaderLibrary/DepthNormalsPass.hlsl"
            ENDHLSL
        }
	}	

	Fallback "Hidden/InternalErrorShader"	
	CustomEditor "SceneTerrainMaskGUI"
}