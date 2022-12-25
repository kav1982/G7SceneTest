Shader "Bioum/Scene/StylizedWater"
{
	Properties
	{
		//[HDR]_MainColor("MainColor", Color) = (1,1,1,1)
		_WaterColor("水颜色", color) = (0, 0.44, 0.62, 1)
		_WaterColorNear("浅水区颜色", color) = (0.1, 0.9, 0.89, 0.02)
		_WaterColorFar("深水区颜色", color) = (0.84, 1, 1, 0.15)
		
		[Header(AniParams)]
		_AnimationParams("XY=Direction, Z=Speed, W=fallOff", Vector) = (0.5,0.8,0.88,-1.0)
		[MaterialEnum(Mesh UV,0,World XZ projected ,1)]_WorldSpaceUV("UV Source", Float) = 1

		_WorldScale("场景缩放", float) = 1

	    [Space(10)]
        _FresnelPower ("菲涅尔强度", range(0.01, 5)) = 0.22
		_DepthVertical("横向深度", Range(0.01 , 8)) = 4.7
		_DepthHorizontal("纵向深度", Range(0.01 , 8)) = 1.52
		_DepthExp("渐变指数", Range(0 , 1)) = 1
    	//_SoftEdgeRange("边缘透明范围", range(0.01, 10)) = 5.5
    	_EdgeFade("边缘透明范围", Range(0, 100)) = 1
    	
    	[Space(10)]
    	[Toggle(_EDGEFOAM)] _EdgeFoamToggle("开启泡沫", float) = 0
    	[NoScaleOffset][SingleLineTexture]_EdgeFoamTexture ("EdgeFoam Texture", 2D) = "white" {}
        _EdgeFoamTiling ("EdgeFoam Tiling", Float ) = 44
        _EdgeFoamBlend ("EdgeFoam Blend", Range(0, 1) ) = 0.5
        _EdgeFoamVisibility ("EdgeFoam Visibility", Range(0, 1)) = 0.3
        _EdgeFoamIntensity ("EdgeFoam Intensity", Float ) = 3
        _EdgeFoamContrast ("EdgeFoam Contrast", Range(0, 0.5)) = 0.25
        _EdgeFoamColor ("EdgeFoam Color", Color) = (1,1,1,1)
        _EdgeFoamSpeed ("EdgeFoam Speed", Float ) = 2
		
		
    	[Toggle(_WAVE)] _WaveToggle("开启边缘", float) = 0
		_waveEdgeLength("waveEdgeDistance", Range(0.01 , 5)) = 2
		_waveFalloff("WaveFalloff", Range(0.01 , 1)) = 0.6
		[Header(EdgeParams)]
		_waveEdgeVector("X=Dist Y=Tiling Z=Clip W=Strength", Vector) = (1.6,4,0.7,0.3)

		[Toggle(_CHPFOAM)] _CHPFoamToggle("开启国画边缘", float) = 0
		_FoamNoiseTex ("Noise", 2D) = "white" {}
		_FoamNoiseDistTex ("NoiseDist", 2D) = "white" {}
		_FoamNoiseMix("noiseMix",Range(-1,1)) = 0.5
		_FoamNoiseDistortion("noiseDistortion",Range(0,10)) = 10
		_FoamNoiseSpeed("noiseSpeed",Range(0,0.1)) = 0.05
        _CHPFoamWidth("foamWidth",Range(0.01,4)) = 0
		_CHPFoamNum("foamNum",Range(1,30)) = 0
        _CHPFoamSpeed("foamSpeed",Range(0,3)) = 0.5
		_CHPFoamStart("foamStart",Range(1,20)) = 10
		_CHPFoamAtten("foamAtten",Range(0,0.1)) = 0.05
        _CHPFoamCol("foamColor",Color) = (0,0,0,1)
		_CHPFoamParam1("CHPFoamParam1",vector) = (0,0,0,0)
		_CHPFoamParam2("CHPFoamParam2",vector) = (0,0,0,0)
		
		[Toggle(_RIVER)] _RiverToggle("开启湖面模式", float) = 0
		[Header(MaskParams)]
    	_MaskFlow("X=亮度 Y=阈值 Z=缩放 W=平移", Vector) = (1,1,0,0)
	    [MaterialEnum(Camera Depth,0,Vertex Color (Red),1,Both combined,2)] _IntersectionSource("Intersection source", Float) = 0
		[NoScaleOffset][SingleLineTexture]_IntersectionNoise("Intersection noise", 2D) = "white" {}
		_IntersectionColor("Color", Color) = (1,1,1,1)
		//_IntersectionLength("Distance", Range(0.01 , 5)) = 2
		//_IntersectionClipping("Cutoff", Range(0.01, 1)) = 0.5
		_IntersectionFalloff("Falloff", Range(0.01 , 1)) = 0.5
		_IntersectionRippleStrength("Ripple Strength", Range(0 , 1)) = 0.5
		_IntersectionTiling("Noise Tiling", float) = 0.2
		_IntersectionSpeed("Speed multiplier", float) = 0.1
		_IntersectionRippleDist("Ripple distance", float) = 32
		
    	
    	[Header(Underwater)]
		[Toggle(_CAUSTICS)] _CausticsOn("Caustics ON", Float) = 0
    	[NoScaleOffset][SingleLineTexture]_CausticsTex("Caustics Mask", 2D) = "black" {}
	    //_DepthVertical("Vertical Depth", Range(0.01 , 8)) = 4
    	//_DepthHorizontal("Horizontal Depth", Range(0.01 , 8)) = 1
		_DepthExp("Exponential Blend", Range(0 , 1)) = 1
		_CausticsBrightness("Brightness", Float) = 2
		_CausticsTiling("Tiling", Float) = 0.5
		_CausticsSpeed("Speed multiplier", Float) = 0.1
		_CausticsDistortion("Distortion", Range(0, 1)) = 0.15
    	
    	[Header(Foam)]
    	[Toggle(_FOAM)] _FoamOn("Foam ON", Float) = 0
		[NoScaleOffset][SingleLineTexture]_FoamTex("Foam Mask", 2D) = "black" {}
		_FoamColor("Color", Color) = (1,1,1,1)
		_FoamSize("Cutoff", Range(0.01 , 0.999)) = 0.01
		_FoamSpeed("Speed multiplier", float) = 0.1
		_FoamWaveMask("Wave mask", Range(0 , 1)) = 0
		_FoamWaveMaskExp("Wave mask exponent", Range(1 , 8)) = 1
		_FoamTiling("Tiling", float) = 0.1

    }
    SubShader
    {
    	HLSLINCLUDE
            #include "StylizedWaterInput.hlsl"
        ENDHLSL
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"
        }
        Name "ForwardBase"
        Tags{"LightMode" = "UniversalForward"}
        Lod 300

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
        	ZTest LEqual
			ColorMask RGBA

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
			
            #pragma target 3.0

            #pragma shader_feature _ _REFLECTION_TEXTURE
            #pragma shader_feature _ _FOAM
            //#pragma shader_feature _ _WAVE
            #pragma shader_feature_local _ _RIVER
            #pragma shader_feature _ _CAUSTICS
            #pragma shader_feature _ _EDGEFOAM
			#pragma shader_feature_local _ _DEBUGRIVERMASK
			#pragma shader_feature_local _ _CHPFOAM

            #define _ENABLE_DEPTH_TEXTURE 1
            #define _USE_CUSTOM_TIME 1

            #pragma vertex WaterLitVert
            #pragma fragment WaterLitFrag

            #include "StylizedWaterPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"
        }
        Name "ForwardBase"
        Tags{"LightMode" = "UniversalForward"}
        Lod 200

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
			
            #pragma target 3.0

			//#pragma shader_feature _ _REFLECTION_TEXTURE
            #pragma shader_feature _ _FOAM
            //#pragma shader_feature _ _WAVE
            #pragma shader_feature_local _ _RIVER
            #pragma shader_feature _ _CAUSTICS
            #pragma shader_feature _ _EDGEFOAM
			#pragma shader_feature_local _ _CHPFOAM

            #define _ENABLE_DEPTH_TEXTURE 1          		

            #pragma vertex WaterLitVert
            #pragma fragment WaterLitFrag           

            #include "StylizedWaterPass.hlsl"

            ENDHLSL
        }
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"
        }
        Name "ForwardBase"
        Tags{"LightMode" = "UniversalForward"}
        Lod 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
			
            #pragma target 3.0
			
			//#pragma shader_feature _ _NORMAL
            //#pragma shader_feature _ _WAVE
            #pragma shader_feature_local _ _RIVER
            #pragma shader_feature _ _EDGEFOAM
			#pragma shader_feature_local _ _CHPFOAM
            //#pragma shader_feature _ _CAUSTICS
            //#define _ENABLE_DEPTH_TEXTURE 0            
            //#define _WAVE 0
			//#define _NORMAL 1

            #pragma vertex WaterLitVert
            #pragma fragment WaterLitFrag

            #include "StylizedWaterPass.hlsl"

            ENDHLSL
        }
    }
	CustomEditor"StylizedWaterGUI"
}
