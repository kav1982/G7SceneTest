Shader "Bioum/Character/Skin"
{
    Properties
    {
        [MainColor]_BaseColor("颜色", Color) = (1,1,1,1)
        [MainTexture]_BaseMap ("贴图", 2D) = "white" {}
        _PenumbraTintColor("半影色调", Color) = (1,1,1,1)
        
        [NoScaleOffset]_NormalAOSmoothMap ("法线(AG) 光滑(R) AO(B)", 2D) = "white" {}
        _NormalScale("法线强度", Range(-4.0, 4.0)) = 1.0
        _Smoothness("光滑度", Range(0.0, 1.0)) = 0.8
        _NormalAOSmoothParam("法线AO光滑参数", vector) = (1,1,0,0)
        
        _AOStrength("AO强度", Range(0.0, 1.0)) = 1.0
        _FresnelStrength("菲涅尔强度", Range(0.0, 1.0)) = 1.0
        _F0Strength("反射强度", Range(0.0, 1.0)) = 0.5
        _IndirectParam ("间接光参数", vector) = (1,1,1,1)

        _SSSColor ("SSS颜色", Color) = (0.5, 0.0, 0.0, 1)
        
        [NoScaleOffset]_EmissiveMap ("自发光(RGB)", 2D) = "white" {}
        [HDR]_EmissiveColor("自发光颜色", Color) = (0,0,0,1)

        [ToggleUI] _RimToggle ("RIM开关", float) = 0
        [HDR]_RimColorFront ("边缘光亮面颜色", Color) = (1,1,1,1)
        _RimColorBack ("边缘光暗面颜色", Color) = (0.5, 0.5, 0.5,1)
        _RimSmooth ("边缘光硬度", range(0.001, 0.449)) = 0.1
        _RimOffsetX ("边缘光亮部偏移", range(0, 4)) = 0.4
        _RimOffsetY ("边缘光暗部偏移", range(0, 4)) = 0.4
        _RimParam ("边缘光参数", vector) = (0.4, 0.4, 0.1, 5)

        _LightIntensity ("灯光强度", range(0, 4)) = 1
        _SmoothDiff ("明暗交界线硬度", range(0.001, 1)) = 0.5
        _LightControlParam ("灯光控制参数", vector) = (0.5, 0.5, 0.5, 1)
        
        [HDR]_DissolveEdgeColor("dissolve Edge Color", color) = (11,1.6,0,1)
        _DissolveScale("dissolve Scale", float) = 20
        _DissolveFactor("dissolve factor", Range(0,1.01)) = 0
		_DissolveEdge("dissolve Edge", Range(0,0.2)) = 0.05
		_DissolveAni ("_DissolveAni", float) = 0.05
		_DissolveParam ("_DissolveParam", vector) = (0,0,0,0)
        
        _OutlineColor ("_OutlineColor", Color) = (0,0,0,0.01)
		_OutlineThickness ("_OutlineThickness", Range(0,0.05)) = 0.01
        
		[ToggleUI]_UseGlobalLightingControl ("_UseGlobalLightingControl", float) = 1
        
        [HideInInspector] _BattleParam ("_BattleParam", vector) = (0,0,0,0)
        
    }
    
    HLSLINCLUDE
        #include "CharacterSkinInput.hlsl"
    ENDHLSL
    
    SubShader
    {
        LOD 300
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        Pass
        {
            Name "Outline"
            Tags{"LightMode"="Outline"}
            ZWrite On Cull Front

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma vertex OutlineVert
            #pragma fragment OutlineFrag

            #include "OutlinePass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            #pragma shader_feature _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _SCREEN_SPACE_SHADOW

            #pragma shader_feature_fragment _ _SHADOWS_SOFT
            #pragma shader_feature _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local_fragment _ _EMISSIVE_MAP
            
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma shader_feature _ _USE_CUSTOM_LIGHTING_INPUT _USE_UI_LIGHTING_INPUT
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 1
            #define _ENVIRONMENT_REFLECTION_ON 1
            #define _PER_PIXEL_SH 1
            #define _SSS 1
            #define _HIGH_QUALITY

            #include "CharacterSkinPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            //#pragma multi_compile_instancing

            #define _HIGH_QUALITY

            #pragma vertex CharacterShadowPassVertex
            #pragma fragment CharacterShadowPassFragment

            #include "../ShaderLibrary/ShadowCasterPass-Character.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #define _HIGH_QUALITY

            #include "../ShaderLibrary/DepthOnlyPass-Character.hlsl"
            ENDHLSL
        }
    }
    
    SubShader
    {
        HLSLINCLUDE
            #include "CharacterSkinInput.hlsl"
        ENDHLSL
        
        LOD 200
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        Pass
        {
            Name "Outline"
            Tags{"LightMode"="Outline"}
            ZWrite On Cull Front

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma vertex OutlineVert
            #pragma fragment OutlineFrag

            #include "OutlinePass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma shader_feature _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _SCREEN_SPACE_SHADOW

            //#pragma shader_feature_fragment _ _SHADOWS_SOFT
            #pragma shader_feature _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local_fragment _ _EMISSIVE_MAP
            
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma shader_feature _ _USE_CUSTOM_LIGHTING_INPUT _USE_UI_LIGHTING_INPUT
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 1
            #define _ENVIRONMENT_REFLECTION_ON 0
            #define _PER_PIXEL_SH 0
            #define _MEDIUM_QUALITY
            #define _SSS 1

            #include "CharacterSkinPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            //#pragma multi_compile_instancing

            #pragma vertex CharacterShadowPassVertex
            #pragma fragment CharacterShadowPassFragment
            #define _MEDIUM_QUALITY

            #include "../ShaderLibrary/ShadowCasterPass-Character.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            #define _MEDIUM_QUALITY

            #include "../ShaderLibrary/DepthOnlyPass-Character.hlsl"
            ENDHLSL
        }
    }
    
    SubShader
    {
        HLSLINCLUDE
            #include "CharacterSkinInput.hlsl"
        ENDHLSL
        
        LOD 100
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        Pass
        {
            Name "Outline"
            Tags{"LightMode"="Outline"}
            ZWrite On Cull Front

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma vertex OutlineVert
            #pragma fragment OutlineFrag

            #include "OutlinePass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma shader_feature _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _SCREEN_SPACE_SHADOW

            //#pragma shader_feature_fragment _ _SHADOWS_SOFT
            #pragma shader_feature _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            //#pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local_fragment _ _EMISSIVE_MAP
            
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma shader_feature _ _USE_CUSTOM_LIGHTING_INPUT _USE_UI_LIGHTING_INPUT
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 0
            #define _ENVIRONMENT_REFLECTION_ON 0
            #define _PER_PIXEL_SH 0
            #define _LOW_QUALITY
            #define _SSS 0

            #include "CharacterSkinPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            //#pragma multi_compile_instancing

            #pragma vertex CharacterShadowPassVertex
            #pragma fragment CharacterShadowPassFragment
            #define _LOW_QUALITY

            #include "../ShaderLibrary/ShadowCasterPass-Character.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            #define _LOW_QUALITY

            #include "../ShaderLibrary/DepthOnlyPass-Character.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "CharacterSkinGUI"
}
