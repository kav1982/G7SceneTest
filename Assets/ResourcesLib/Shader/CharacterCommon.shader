Shader "Bioum/Character/Common"
{
    Properties
    {
        [MainColor]_BaseColor("颜色", Color) = (1,1,1,1)
        [MainTexture]_BaseMap ("贴图", 2D) = "white" {}
        [ToggleUI]_UseBrushTex("_UseBrushTex",float) = 0
        _BrushTex ("笔刷贴图", 2D) = "white" {}
        //_ColorRat ("原图饱和图", Range(0, 1)) = 0.3
        _PenumbraTintColor("半影色调", Color) = (1,1,1,1)
        
        [ToggleUI] _EmissiveAOMapUseUV2 ("自发光AO贴图使用2U", float) = 0
        [NoScaleOffset]_EmissiveAOMap ("自发光(RGB) AO(A)", 2D) = "white" {}
        //[NoScaleOffset]_NormalMap("法线(RG)", 2D) = "white" {}
        
        [Toggle(_OUT_LINE)] _OUT_LINE_ON("Out Line", float) = 0
        _OutLineCol("OutLine Color", Color) = (0, 0, 0, 1)
        _OutLineMul("OutLine x", float) = 12.9
        _OutLineAdd("OutLine +", float) = -9.7
        
        _reflectionRat("Reflection Rat", Range(1, 3)) = 0.5
        _reflectionPow("Reflection Pow", Range(0, 20)) = 5
        _SmoothReflection("Smooth Reflection", Range(0.01, 2)) = 1
        
        //_NormalScale("法线强度", Range(-4.0, 4.0)) = 1.0        
        [HDR]_EmissiveColor("自发光颜色", Color) = (0,0,0,1)
        [ToggleUI] _EmissiveBake ("自发光参与烘焙", float) = 0
        _EmissiveBakeBoost ("烘焙亮度增强", range(0, 8)) = 1
        
        _AOStrength("AO强度", Range(0.0, 1.0)) = 1.0

        _IndirectParam ("法线强度 Ao参数", vector) = (1,1,1,1)

        [ToggleUI] _SSSToggle ("SSS开关", float) = 0
        _SSSColor ("SSS颜色", Color) = (0.5, 0.0, 0.0, 1)
        
        _Cutoff("透贴强度", Range(0.0, 1.0)) = 0.5
        _Transparent("透明度", Range(0.0, 1.0)) = 1
        [ToggleUI]_TransparentShadowCaster("半透明阴影", float) = 0
        _TransparentParam ("半透明参数", vector) = (1,1,1,1)

        _LightIntensity ("灯光强度", range(0, 4)) = 1
        _SmoothDiff ("明暗交界线硬度", range(0.001, 2)) = 0.5
        _LightOffset("减弱光照",range(0,1)) = 0.5
        _LightControlParam ("灯光控制参数", vector) = (0.5, 0.5, 0.5, 1)
        
        
        [ToggleUI] _UseDissolove ("_UseDissolove", float) = 0
        [ToggleUI] _DissoloveTurn("DissoloveTurn",float) = 0
        _DissolveAmount("Dissolve Amount",float) = 0.5
        _DissolveNoiseTex("_DissolveNoiseTex",2D) = "white" {}
        _NoiseTile("Tile",Range(0,10)) = 1
        _NoiseSpeed("NoiseSpeed",Range(0,1)) = 0.1
        _ExpandWidth("expandWidth",float) = 0.5
        _ClipWidth("clipWidth",float) = 1
        _ClipPow("clipPow",Range(0,4)) =0.5
        //_DissolveDisapper("_DissolveDisapper",Range(0,10)) = 5
        _DissolveScale("_DissolveScale",Range(-1,1.5)) = 1
        
        _DissolveEdgeColor("_DissolveEdgeColor", color) = (1,1,1,1)
        _DissolveEdgeColStrength("_DissolveEdgeColStrength",float) = 1
        _DissolveEdgePow("_DissolveEdgePow",float) = 1
        _DissoloveParam1("_DissoloveParam1",vector) = (1,1,1,1)
        _DissoloveParam2("_DissoloveParam2",vector) = (1,1,1,1)
        //_DissoloveParam3("_DissoloveParam3",vector) = (1,1,1,1)
        
        //[ToggleUI]_UseGlobalLightingControl ("_UseGlobalLightingControl", float) = 1
        
        
		[HideInInspector] _BattleParam ("_BattleParam", vector) = (0,0,0,0)
        
        [HideInInspector] _BlendMode ("_BlendMode", float) = 0
        [HideInInspector] _CullMode ("_CullMode", float) = 0
        [HideInInspector] _SrcBlend ("_SrcBlend", float) = 1
        [HideInInspector] _DstBlend ("_DstBlend", float) = 0
        [HideInInspector] _ZWrite ("_ZWrite", float) = 1
        [HideInInspector][ToggleUI] _TransparentZWrite ("_TransparentZWrite", float) = 0
        [HideInInspector] _Cull ("_Cull", float) = 2
    }
    
    HLSLINCLUDE
        #include "CharacterCommonInput.hlsl"
    ENDHLSL
    
    SubShader
    {
        LOD 300
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

            #pragma shader_feature _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _SCREEN_SPACE_SHADOW

            #pragma shader_feature_fragment _ _SHADOWS_SOFT
            #pragma shader_feature _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            #pragma shader_feature_local_fragment _ _ALPHATEST_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _SSS
            #pragma shader_feature_local_fragment _ _EMISSIVE_AO_MAP
            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local _ _OUT_LINE
            #pragma shader_feature_local _ _USE_BRUSHTEX
            #pragma shader_feature_local _ _USE_DISSOLOVE
            #pragma shader_feature_local _ _DISSOLOVETURN
            
            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma shader_feature _ _USE_CUSTOM_LIGHTING_INPUT _USE_UI_LIGHTING_INPUT
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 1
            #define _ENVIRONMENT_REFLECTION_ON 1
            #define _PER_PIXEL_SH 1
            #define _HIGH_QUALITY

            #include "CharacterCommonPass.hlsl"
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
            
            #pragma vertex CharacterShadowPassVertex
            #pragma fragment CharacterShadowPassFragment

            #include "ShaderLibrary/ShadowCasterPass-Character.hlsl"
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

            #include "ShaderLibrary/DepthOnlyPass-Character.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "CharacterCommonGUI"
}
