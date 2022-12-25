Shader "Bioum/Scene/SceneBlendLit"
{
    Properties
    {
        [MainColor]_BaseColor("颜色", Color) = (1,1,1,1)
        [MainTexture]_BaseMap ("贴图", 2D) = "white" {}
        _PigmentMap ("贴图", 2D) = "white" {}
        _PenumbraTintColor("半影色调", Color) = (1,1,1,1)
        
        [Toggle] _EmissiveAOMapUseUV2 ("自发光AO贴图使用2U", float) = 0
        [NoScaleOffset]_EmissiveAOMap ("自发光(RGB) AO(A)", 2D) = "white" {}
        [NoScaleOffset]_NormalMetalSmoothMap ("法线(AG) 光滑(R) 金属(B)", 2D) = "white" {}
        
        [ToggleUI]_TerrainBlendToggle("_TerrainBlendToggle", float) = 0
        _TerrainBlendHeight("_TerrainBlendHeight", float) = 0.02
        _TerrainBlendFalloff("_TerrainBlendFalloff", float) = 1
        _TerrainBlendParam("_TerrainBlendParam", vector) = (0.02,1,0,0)
        _XOffset ("X轴向映射偏移", float) = 0 
        _YOffset ("Y轴向映射偏移", float) = 0
        
        
        [ToggleUI] _PAPER ("扁平法线", float) = 0
        _NormalScale("法线强度", Range(-4.0, 4.0)) = 1.0
        _AOStrength("AO强度", Range(0.0, 1.0)) = 1.0
        _NormalAOParam ("法线AO参数", vector) = (1,1,1,1)
        
        [HDR]_EmissiveColor("自发光颜色", Color) = (0,0,0,1)
        [Toggle] _EmissiveBake ("自发光参与烘焙", float) = 0
        _EmissiveBakeBoost ("烘焙亮度增强", range(0, 8)) = 1

		[ToggleUI]_VertexAO("顶点色AO开关",float) = 0
		_VertexAOStrength("顶点色AO强度",Range(0.01,10)) = 1
		_VertexAOCol("AO颜色",Color) = (0,0,0,1)
		_AOColStrength("AO颜色强度",Range(0,3)) = 1
		_VertexAOParam("顶点色AO参数",vector) = (0,0,0,1)
        
        
        [Toggle(_DITHER_CLIP)] _DitherClip ("_DitherClip", float) = 0
        _Cutoff("透贴强度", Range(0.0, 1.0)) = 0.5
        _Transparent("透明度", Range(0.0, 1.0)) = 1
        [Toggle]_TransparentShadowCaster("半透明阴影", float) = 0
        _TransparentParam ("半透明参数", vector) = (1,1,1,1)
        
		[ToggleUI]_DarkPartToggle("顶部添加色开关",float) = 0
		_DarkPartColor("顶部添加色",Color) = (0,0,0,0)
		[ToggleUI]_AddColorToggle("添加颜色",float) = 0
		_Contrast("对比度", range(0, 1)) = 0.5
		_DarkLigthIntensity("添加色强度", range(0.1, 20)) = 1
		_YClip("Y轴剔除", range(0, 1)) = 0.5
		_YAtten("Y轴衰减", range(1, 4)) = 0.5
		_DarkParam("顶部参数", vector) = (0.5,1,0.5,0.5)

		[ToggleUI]_ButGradientToggle("底部渐变色开关",float) = 0
		_ButGradientCol("底部渐变色",Color) = (0,0,0,0)
		_ButGradientIntensity("渐变色强度", range(0.1, 4)) = 1
		_YClipBut("Y轴剔除", range(0, 1)) = 0.5
		_YAttenBut("Y轴衰减", range(1, 4)) = 0.5
		_ButGradientParam("底部参数", vector) = (0.5,1,0.5,0.5)
        
        [ToggleUI] _WindToggle ("风开关", float) = 0
        _WindScale ("缩放", float) = 0.2
        _WindSpeed ("速度", float) = 0.5
        _WindDirection ("风向", range(0,90)) = 40
        _WindIntensity ("强度", range(0, 1)) = 0.2
        _WindParam ("风参数", vector) = (0.2, 0, 0.2, 0.5)
        

        _TestValue("Test Value", range(0, 5)) = 0
        _GroundInfluence("随地表颜色", Range(0,1)) = 1
        _ColorFalloff("_ColorFalloff", range(0.1, 5)) = 0.5
        _FalloffParam("_FalloffParam", vector) = (1,1,1,1)

        [HideInInspector] _BlendMode ("_BlendMode", float) = 0
        [HideInInspector] _CullMode ("_CullMode", float) = 0
		[HideInInspector] _RenderQueue ("_RenderQueue", float) = 0
        [HideInInspector] _SrcBlend ("_SrcBlend", float) = 1
        [HideInInspector] _DstBlend ("_DstBlend", float) = 0
        [HideInInspector] _ZWrite ("_ZWrite", float) = 1
        [HideInInspector][Toggle] _TransparentZWrite ("_TransparentZWrite", float) = 0
        [HideInInspector] _Cull ("_Cull", float) = 2
        // ↓烘焙需要这两个属性获取颜色数据↓ //
        [HideInInspector] _Color("Color", Color) = (1,1,1,1)
        [HideInInspector] _MainTex ("Main Tex", 2D) = "white" {}

        _Stencil("Stencil ID", Float) = 0
        [Rendering.CompareFunction] _StencilComp("Stencil Comparison", Float) = 8
    }
    
    HLSLINCLUDE
        #include "SceneBlendLitInput.hlsl"
    ENDHLSL
    
    SubShader
    {
        
        Stencil
        {
            Ref[_Stencil]
            Comp[_StencilComp]
        }
        
        LOD 300
        Tags{"RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite] Cull[_Cull]

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // _fragment 为仅对像素着色器编译变体

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ LIGHTMAP_ON
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            //#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_instancing
			#pragma shader_feature _ _VERTEXAO_ON
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _EMISSIVE_AO_MAP
            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local _ _PIGMAP_BLEND_ON
			#pragma shader_feature_local _ _DARKPART
			#pragma shader_feature_local _ _BUTGRADIENT
			#pragma shader_feature_local _ _ADDCOLOR
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma multi_compile _ _PER_OBJECT_CAUSTIC
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #define _HIGH_QUALITY
            #define _PER_PIXEL_SH 1
            
            #pragma vertex SimpleLitVert
            #pragma fragment SimpleLitFrag
            
            #include "SceneBlendLitPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On ZTest LEqual
            Cull[_Cull] ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

            #pragma shader_feature_local _ _ALPHATEST_ON
            #pragma shader_feature_local _ _DITHER_CLIP
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #define _HIGH_QUALITY
            
            #pragma vertex SceneShadowPassVertex
            #pragma fragment SceneShadowPassFragment

            #include "ShaderLibrary/ShadowCasterPass-Scene.hlsl"
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
        
    }
    
    SubShader
    {
        LOD 200
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite] Cull[_Cull]

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // _fragment 为仅对像素着色器编译变体

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ LIGHTMAP_ON
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            //#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_instancing

            #pragma shader_feature_local_fragment _ _ALPHATEST_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _EMISSIVE_AO_MAP
            #pragma shader_feature_local _ _NORMALMAP
            //#pragma shader_feature_local _ _PAPER
            #pragma shader_feature_local _ _PIGMAP_BLEND_ON
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma multi_compile _ _PER_OBJECT_CAUSTIC
            
            #pragma vertex SimpleLitVert
            #pragma fragment SimpleLitFrag

            #define _MEDIUM_QUALITY
            #define _PER_PIXEL_SH 0
            
            #include "SceneBlendLitPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On ZTest LEqual
            Cull[_Cull] ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

            #pragma shader_feature_local _ _ALPHATEST_ON
            #pragma shader_feature_local _ _DITHER_CLIP

            #define _MEDIUM_QUALITY
            
            #pragma vertex SceneShadowPassVertex
            #pragma fragment SceneShadowPassFragment

            #include "ShaderLibrary/ShadowCasterPass-Scene.hlsl"
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

            #define _MEDIUM_QUALITY

            #include "ShaderLibrary/DepthOnlyPass-Scene.hlsl"
            ENDHLSL
        }
        
    }
    
    SubShader
    {
        LOD 100
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite] Cull[_Cull]

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // _fragment 为仅对像素着色器编译变体

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _SCREEN_SPACE_SHADOW
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            
            #pragma multi_compile_instancing
            
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _EMISSIVE_AO_MAP
            #pragma shader_feature_local _ _PIGMAP_BLEND_ON
            
            
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma multi_compile _ _PER_OBJECT_CAUSTIC

            #define _LOW_QUALITY
            #define _PER_PIXEL_SH 0
            
            #pragma vertex SimpleLitVert
            #pragma fragment SimpleLitFrag
            
            #include "SceneBlendLitPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On ZTest LEqual
            Cull[_Cull] ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

            #pragma shader_feature_local _ _ALPHATEST_ON
            #pragma shader_feature_local _ _DITHER_CLIP

            #define _LOW_QUALITY
            
            #pragma vertex SceneShadowPassVertex
            #pragma fragment SceneShadowPassFragment

            #include "ShaderLibrary/ShadowCasterPass-Scene.hlsl"
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

            #define _LOW_QUALITY

            #include "ShaderLibrary/DepthOnlyPass-Scene.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "SceneBlendLitGUI"
}
