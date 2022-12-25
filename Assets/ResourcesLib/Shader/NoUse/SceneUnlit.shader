Shader "Bioum/Scene/Unlit"
{
    Properties
    {
        [MainColor][HDR]_BaseColor("颜色", Color) = (1,1,1,1)
        [MainTexture]_BaseMap ("贴图", 2D) = "white" {}
        
        [Toggle] _EmissiveMapUseUV2 ("自发光贴图使用2U", float) = 0
        [NoScaleOffset]_EmissiveMap ("自发光(RGB)", 2D) = "white" {}
        [HDR]_EmissiveColor("自发光颜色", Color) = (0,0,0,1)
        [Toggle] _EmissiveBake ("自发光参与烘焙", float) = 0
        _EmissiveBakeBoost ("烘焙亮度增强", range(0, 8)) = 1
        
        _Cutoff("透贴强度", Range(0.0, 1.0)) = 0.5
        _Transparent("透明度", Range(0.0, 1.0)) = 1
        [ToggleUI]_TransparentShadowCaster("半透明阴影", float) = 0
        
        [ToggleUI]_UseFog("接受雾", float) = 0
        _FogIntensity("雾强度", range(0,1)) = 1
        
        _UnlitShaderParam ("参数集合", vector) = (1,1,1,1)
        
        [HideInInspector] _BlendMode ("_BlendMode", float) = 0
        [HideInInspector] _CullMode ("_CullMode", float) = 0
        [HideInInspector] _SrcBlend ("_SrcBlend", float) = 1
        [HideInInspector] _DstBlend ("_DstBlend", float) = 0
        [HideInInspector] _ZWrite ("_ZWrite", float) = 1
        [HideInInspector][Toggle] _TransparentZWrite ("_TransparentZWrite", float) = 0
        [HideInInspector] _Cull ("_Cull", float) = 2
    }
    
    HLSLINCLUDE
        #include "SceneUnlitInput.hlsl"
    ENDHLSL
    
    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        LOD 300

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

            #pragma shader_feature _ _BIOUM_FOG_EX
            
            #pragma shader_feature_local _ _ALPHATEST_ON
            #pragma shader_feature_local _ _USE_FOG
            #pragma shader_feature_local_fragment _ _EMISSIVE_MAP

            #define _HIGH_QUALITY
            
            #pragma vertex UnlitVert
            #pragma fragment UnlitFrag

            #include "SceneUnlitPass.hlsl"
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

            //#pragma multi_compile_instancing

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
    }
    
    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        LOD 100

        HLSLINCLUDE
            #include "SceneUnlitInput.hlsl"
        ENDHLSL

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

            #pragma shader_feature _ _BIOUM_FOG_EX
            
            #pragma shader_feature_local _ _ALPHATEST_ON
            #pragma shader_feature_local _ _USE_FOG
            #pragma shader_feature_local_fragment _ _EMISSIVE_MAP
            #define _LOW_QUALITY
            
            #pragma vertex UnlitVert
            #pragma fragment UnlitFrag

            #include "SceneUnlitPass.hlsl"
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

            //#pragma multi_compile_instancing

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
    }
    CustomEditor "SceneUnlitGUI"
}
