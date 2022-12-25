Shader "Bioum/Scene/CommonPBR"
{
    Properties
    {
        [MainColor]_BaseColor("颜色", Color) = (1,1,1,1)
        [MainTexture]_BaseMap ("贴图", 2D) = "white" {}
        _PenumbraTintColor("半影色调", Color) = (0.5,0.5,0.5,1)
        _SpecularColor("高光颜色", Color) = (1,1,1,1)
        
        [ToggleUI] _EmissiveAOMapUseUV2 ("自发光AO贴图使用2U", float) = 0
        [NoScaleOffset]_EmissiveAOMap ("自发光(RGB) AO(A)", 2D) = "white" {}
        [NoScaleOffset]_NormalMetalSmoothMap ("法线(AG) 光滑(R) 金属(B)", 2D) = "white" {}
        
        _NormalScale("法线强度", Range(-4.0, 4.0)) = 1.0
        _Metallic("金属度", Range(0.0, 1.0)) = 0.0
        _Smoothness("光滑度", Range(0.0, 1.0)) = 0.5
        _NormalMatelSmoothParam("法线金属光滑参数", vector) = (1,0,0.5,0)
        
        [HDR]_EmissiveColor("自发光颜色", Color) = (0,0,0,1)
        [ToggleUI] _EmissiveBake ("自发光参与烘焙", float) = 0
        _EmissiveBakeBoost ("烘焙亮度增强", range(0, 8)) = 1
        
        _AOStrength("AO强度", Range(0.0, 1.0)) = 1.0
        _FresnelStrength("菲涅尔强度", Range(0.0, 1.0)) = 1.0
        _F0Tint("非金属反射着色", Range(0.0, 1.0)) = 0.0
        _F0Strength("非金属反射强度", Range(0.0, 2.0)) = 0.5
        _IndirectParam ("间接光参数", vector) = (1,1,0,0.5)

        [ToggleUI] _SSSToggle ("SSS开关", float) = 0
        _SSSColor ("SSS颜色", Color) = (0.5, 0.0, 0.0, 1)
        _SSSParam ("SSS参数", vector) = (1,1,1,1)
        
        [Toggle(_DITHER_CLIP)] _DitherClip ("_DitherClip", float) = 0
        _Cutoff("透贴强度", Range(0.0, 1.0)) = 0.5
        _Transparent("透明度", Range(0.0, 1.0)) = 1
        [ToggleUI]_TransparentShadowCaster("半透明阴影", float) = 0
        _TransparentParam ("半透明参数", vector) = (1,1,1,1)
        
        [ToggleUI] _RimToggle ("RIM开关", float) = 0
        [HDR]_RimColorFront ("边缘光亮面颜色", Color) = (1,1,1,1)
        _RimColorBack ("边缘光暗面颜色", Color) = (0.5, 0.5, 0.5,1)
        _RimSmooth ("边缘光硬度", range(0.001, 0.449)) = 0.1
        _RimOffsetX ("边缘光亮部偏移", range(0, 4)) = 0.4
        _RimOffsetY ("边缘光暗部偏移", range(0, 4)) = 0.4
        _RimParam ("边缘光参数", vector) = (0.4, 0.4, 0.1, 5)
        
        [ToggleUI] _WindToggle ("风开关", float) = 0
        _WindScale ("缩放", float) = 0.2
        _WindSpeed ("速度", float) = 0.5
        _WindDirection ("风向", range(0,90)) = 40
        _WindIntensity ("强度", range(0, 1)) = 0.2
        _WindParam ("风参数", vector) = (0.2, 0, 0.2, 0.5)
        
        [ToggleUI] _SnowToggle ("积雪", float) = 0
        _SnowNormalMap ("_SnowNormalMap", 2D) = "white" {}
        _SnowNormalTilling ("_SnowNormalTilling", float) = 5
        _SnowNormalScale ("_SnowNormalScale", range(-4, 4)) = 1
        _SnowMaskRange ("_SnowMaskRange", range(-1, 1)) = 0
        _SnowMaskEdge ("_SnowMaskEdge", range(0, 0.499)) = 0
        _SnowParam ("_SnowParam", vector) = (5, 1, 0, 0)
        _SnowColor ("_SnowColor", color) = (0.8, 0.8, 0.8, 1)
        _SnowSmoothness ("_SnowSmoothness", range(0, 1)) = 0.5

        [HideInInspector] _BlendMode ("_BlendMode", float) = 0
        [HideInInspector] _CullMode ("_CullMode", float) = 0
        [HideInInspector] _SrcBlend ("_SrcBlend", float) = 1
        [HideInInspector] _DstBlend ("_DstBlend", float) = 0
        [HideInInspector] _ZWrite ("_ZWrite", float) = 1
        [HideInInspector][Toggle] _TransparentZWrite ("_TransparentZWrite", float) = 0
        [HideInInspector] _Cull ("_Cull", float) = 2
        // ↓烘焙需要这两个属性获取颜色数据↓ //
        [HideInInspector] _Color("Color", Color) = (1,1,1,1)
        [HideInInspector] _MainTex ("Main Tex", 2D) = "white" {}
    }
    
    HLSLINCLUDE
        #include "SceneCommonPBRLitInput.hlsl"
    ENDHLSL
    
    SubShader
    {
        LOD 300
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="CommonPrePass"}

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma multi_compile_instancing
            
            #pragma vertex PrePassVert
            #pragma fragment PrePassFrag

            #include "../ShaderLibrary/ObjectsPrePass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite] Cull[_Cull]

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            // _fragment 为仅对像素着色器编译变体
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            //#pragma multi_compile _ _SCREEN_SPACE_SHADOW

            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_ON
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_instancing

            #pragma shader_feature_local_fragment _ _ALPHATEST_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _EMISSIVE_AO_MAP
            #pragma shader_feature_local_fragment _ _SSS
            #pragma shader_feature_local_fragment _ _SNOW
            #pragma shader_feature_local _ _NORMALMAP_SNOW
            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local _ _RIM
            
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma multi_compile _ _PER_OBJECT_CAUSTIC
            #pragma multi_compile _ _PLANAR_REFLECTION
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 1
            #define _ENVIRONMENT_REFLECTION_ON 1
            #define _PER_PIXEL_SH 1
            #define _HIGH_QUALITY

            #include "SceneCommonPBRLitPass.hlsl"
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

            #define _HIGH_QUALITY
            
            #pragma vertex SceneShadowPassVertex
            #pragma fragment SceneShadowPassFragment

            #include "../ShaderLibrary/ShadowCasterPass-Scene.hlsl"
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

            #include "../ShaderLibrary/DepthOnlyPass-Scene.hlsl"
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
            
            #include "../ShaderLibrary/DepthNormalsPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex MetaPassVertex
            #pragma fragment MetaPassFragment

            #include "../CommonMetaPass.hlsl"
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
            #pragma target 3.0

            // _fragment 为仅对像素着色器编译变体
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _SCREEN_SPACE_SHADOW

            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_ON
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_instancing

            #pragma shader_feature_local_fragment _ _ALPHATEST_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _EMISSIVE_AO_MAP
            //#pragma shader_feature_local_fragment _ _SSS
            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local _ _RIM
            
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma multi_compile _ _PER_OBJECT_CAUSTIC
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 0
            #define _ENVIRONMENT_REFLECTION_ON 1
            #define _PER_PIXEL_SH 0
            #define _MEDIUM_QUALITY
            
            #include "SceneCommonPBRLitPass.hlsl"
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

            #include "../ShaderLibrary/ShadowCasterPass-Scene.hlsl"
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

            #include "../ShaderLibrary/DepthOnlyPass-Scene.hlsl"
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
            
            #include "../ShaderLibrary/DepthNormalsPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex MetaPassVertex
            #pragma fragment MetaPassFragment

            #include "../CommonMetaPass.hlsl"
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
            #pragma multi_compile _ LIGHTMAP_ON
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_instancing

            #pragma shader_feature_local_fragment _ _ALPHATEST_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _EMISSIVE_AO_MAP
            //#pragma shader_feature_local_fragment _ _SSS
            //#pragma shader_feature_local _ _NORMALMAP
            //#pragma shader_feature_local _ _RIM
            
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma multi_compile _ _PER_OBJECT_CAUSTIC
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 0
            #define _ENVIRONMENT_REFLECTION_ON 0
            #define _PER_PIXEL_SH 0
            #define _LOW_QUALITY

            #include "SceneCommonPBRLitPass.hlsl"
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

            #include "../ShaderLibrary/ShadowCasterPass-Scene.hlsl"
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

            #include "../ShaderLibrary/DepthOnlyPass-Scene.hlsl"
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
            
            #include "../ShaderLibrary/DepthNormalsPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex MetaPassVertex
            #pragma fragment MetaPassFragment

            #include "../CommonMetaPass.hlsl"
            ENDHLSL
        }
    }


    CustomEditor "SceneCommonGUI"
}
