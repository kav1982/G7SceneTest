Shader "Bioum/Scene/GrassGroup"
{
	Properties
    {
        _MainTex ("贴图", 2D) = "white" {}
    	//_PigmentMap ("贴图", 2D) = "white" {}
        //_MainColor ("颜色", Color) = (1,1,1,1)
        _Cutoff("透贴强度", Range(0.0, 1.0)) = 0.35
        _XOffset ("X轴向映射偏移", float) = 0 
        _YOffset ("Y轴向映射偏移", float) = 0 
        _GroundInfluence("随地表颜色", Range(0,1)) = 1
        _Color("颜色", Color) = (1,1,1,1)
    	
        _LightColorControl ("暗部颜色", color) = (0.5, 0.5, 0.5, 1)
    	_LightIntensity ("灯光强度", range(0, 4)) = 1
        _SmoothDiff ("明暗交界线硬度", range(0.001, 1)) = 0.5
        
        [HDR]_SpecularColor("高光颜色", Color) = (1,1,1,1)
        _NormalWarp("透光度", Range(0.0, 1.0)) = 0.5
        _Smoothness("光滑度", Range(0.0, 1.0)) = 0.5
        _LightingParam("_LightingParam", vector) = (1,1,1,1)
        
        [ToggleUI] _GamePos ("使用游戏坐标", float) = 0
        _DirectionX("Direction X", range(0,1)) = 0
        _DirectionZ("Direction Z", range(0,1)) = 0.2
        _WindSpeed("_WindSpeed", range(0,2)) = 0.5
        _WindScale("_WindScale", range(0,4)) = 0.5
        _WindParam("_WindParam", vector) = (1,1,1,1)
        
        _WindFalloff("_WindFalloff", range(0.1, 5)) = 0.5
        _ColorFalloff("_ColorFalloff", range(0.1, 5)) = 0.5
        _FalloffParam("_FalloffParam", vector) = (1,1,1,1)
        _tmpUV("_tmpUV", vector) = (1,1,1,1)
    }

    SubShader
    {
        HLSLINCLUDE
            //#define COLOR_SPACE_CONVERSION 1
            #include "SceneGrassGroupInput.hlsl"
        ENDHLSL
        
        LOD 200
        Tags{"RenderType" = "TransparentCutout" "IgnoreProjector" = "True" "Queue"="Alphatest" "DisableBatching"="True"}
        Pass
        {
            Name "ForwardBase"
            Tags{"LightMode"="UniversalForward"}
            Cull off

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            #pragma multi_compile_instancing
            #pragma instancing_options forcemaxcount:127
            
            //#pragma shader_feature _ LOD_FADE_CROSSFADE            
			#pragma shader_feature _ SHADOWS_SHADOWMASK
            #pragma shader_feature_local _ _GAME_POS

            #define _MAIN_LIGHT_SHADOWS 1
            #define _SPECULAR 1

            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag
                                       

            #include "SceneGrassGroupPass.hlsl"
            ENDHLSL
        }

    }

    CustomEditor "SceneGrassGUI"
}
