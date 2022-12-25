Shader "Bioum/Scene/Terrain"
{
    Properties
    {
        _PenumbraTintColor("半影色调", Color) = (0.5,0.5,0.5,1)
        
        _Color0 ("颜色", Color) = (1,1,1,1)
        _Color1 ("颜色", Color) = (1,1,1,1)
        _Color2 ("颜色", Color) = (1,1,1,1)
        _Color3 ("颜色", Color) = (1,1,1,1)
        
        _Splat0 ("贴图", 2D) = "white" {}
        _Splat1 ("贴图", 2D) = "white" {}
        _Splat2 ("贴图", 2D) = "white" {}
        _Splat3 ("贴图", 2D) = "white" {}
        _Tilling0 ("tilling", float) = 1
        _Tilling1 ("tilling", float) = 1
        _Tilling2 ("tilling", float) = 1
        _Tilling3 ("tilling", float) = 1
        _Tilling ("tilling", vector) = (1,1,1,1)
        
        _SplatMask0 ("Mask贴图", 2D) = "grey" {}
        _SplatMask1 ("Mask贴图", 2D) = "grey" {}
        _SplatMask2 ("Mask贴图", 2D) = "grey" {}
        _SplatMask3 ("Mask贴图", 2D) = "grey" {}
        
        _NormalScale0 ("normal scale", range(-4,4)) = 1
        _NormalScale1 ("normal scale", range(-4,4)) = 1
        _NormalScale2 ("normal scale", range(-4,4)) = 1
        _NormalScale3 ("normal scale", range(-4,4)) = 1
        _NormalScale ("normal scale", vector) = (1,1,1,1)
        
        _Smoothness0 ("smoothness", range(0,1)) = 0.5
        _Smoothness1 ("smoothness", range(0,1)) = 0.5
        _Smoothness2 ("smoothness", range(0,1)) = 0.5
        _Smoothness3 ("smoothness", range(0,1)) = 0.5
        _Smoothness ("smoothness", vector) = (0.5, 0.5, 0.5, 0.5)
        
        _AOStrength0 ("ao strength", range(0,1)) = 1
        _AOStrength1 ("ao strength", range(0,1)) = 1
        _AOStrength2 ("ao strength", range(0,1)) = 1
        _AOStrength3 ("ao strength", range(0,1)) = 1
        _AOStrength ("ao strength", vector) = (1,1,1,1)
        
        _FresnelStrength0 ("fresnel strength", range(0,1)) = 1
        _FresnelStrength1 ("fresnel strength", range(0,1)) = 1
        _FresnelStrength2 ("fresnel strength", range(0,1)) = 1
        _FresnelStrength3 ("fresnel strength", range(0,1)) = 1
        _FresnelStrength ("fresnel strength", vector) = (1,1,1,1)
        
        _F0Tint0 ("F0 Tint", range(0,1)) = 0
        _F0Tint1 ("F0 Tint", range(0,1)) = 0
        _F0Tint2 ("F0 Tint", range(0,1)) = 0
        _F0Tint3 ("F0 Tint", range(0,1)) = 0
        _F0Tint ("F0 Tint", vector) = (0,0,0,0)
        
        _F0Strength0 ("F0 Strength", range(0,2)) = 0.5
        _F0Strength1 ("F0 Strength", range(0,2)) = 0.5
        _F0Strength2 ("F0 Strength", range(0,2)) = 0.5
        _F0Strength3 ("F0 Strength", range(0,2)) = 0.5
        _F0Strength ("F0 Strength", vector) = (0.5, 0.5, 0.5, 0.5)
        
        _HeightBlendWeight ("高度混合权重", range(0.01,1)) = 0.5
        [HideInInspector] _TexCount("_TexCount", float) = 4
		
		//Fog
		//_HeightFogDensity("_HeightFogDensity", Float) = 1.0
        //_FogInfo("_FogInfo", Vector) = (-80, -100, -1, -5)
		//_FogColor("_FogColor", Color) = (0.792, 0.572, 0.505, 0.298)
    }
    
    HLSLINCLUDE
        #include "SceneTerrainInput.hlsl"
    ENDHLSL
    
    SubShader
    {
        LOD 300
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "Queue"="AlphaTest+50"}
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="TerrainBlend"}

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            // _fragment 为仅对像素着色器编译变体
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _SCREEN_SPACE_SHADOW

            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_ON
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_instancing
            
            
            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local_fragment _TERRAIN_4TEX _TERRAIN_3TEX _TERRAIN_2TEX

            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma multi_compile _ _PER_OBJECT_CAUSTIC
            #pragma multi_compile _ _PLANAR_REFLECTION
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 1
            #define _ENVIRONMENT_REFLECTION_ON 1
            #define _PER_PIXEL_SH 0
            #define _HIGH_QUALITY
            #define _TERRAIN_BLEND

            #include "SceneTerrainPass.hlsl"
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

            // _fragment 为仅对像素着色器编译变体
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _SCREEN_SPACE_SHADOW

            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_ON
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_instancing
            
            
            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local_fragment _TERRAIN_4TEX _TERRAIN_3TEX _TERRAIN_2TEX

            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma multi_compile _ _PER_OBJECT_CAUSTIC
            #pragma multi_compile _ _PLANAR_REFLECTION
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 1
            #define _ENVIRONMENT_REFLECTION_ON 1
            #define _PER_PIXEL_SH 0
            #define _HIGH_QUALITY

            #include "SceneTerrainPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On ZTest LEqual
            Cull Back ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

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
            Cull Back

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            
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
            
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            
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

            #include "TerrainMetaPass.hlsl"
            ENDHLSL
        }
    }
    
    
    SubShader
    {
        LOD 200
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "Queue"="AlphaTest+50"}
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

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
            
            
            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local_fragment _TERRAIN_4TEX _TERRAIN_3TEX _TERRAIN_2TEX

            #pragma multi_compile _ _BIOUM_FOG_EX
            #pragma multi_compile _ _PER_OBJECT_CAUSTIC
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 1
            #define _ENVIRONMENT_REFLECTION_ON 0
            #define _PER_PIXEL_SH 0
            #define _MEDIUM_QUALITY

            #include "SceneTerrainPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On ZTest LEqual
            Cull Back ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

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
            Cull Back

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            
            #include "../ShaderLibrary/DepthOnlyPass-Scene.hlsl"
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

            #include "TerrainMetaPass.hlsl"
            ENDHLSL
        }
    }
    
    
    SubShader
    {
        LOD 100
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "Queue"="AlphaTest+50"}
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}

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
            
            
            //#pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local_fragment _TERRAIN_4TEX _TERRAIN_3TEX _TERRAIN_2TEX

            #pragma multi_compile _ _BIOUM_FOG_EX
            
            #pragma vertex CommonLitVert
            #pragma fragment CommonLitFrag

            #define _SPECULAR_ON 0
            #define _ENVIRONMENT_REFLECTION_ON 0
            #define _PER_PIXEL_SH 0
            #define _LOW_QUALITY

            #include "SceneTerrainPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On ZTest LEqual
            Cull Back ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

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
            Cull Back

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            
            #include "../ShaderLibrary/DepthOnlyPass-Scene.hlsl"
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

            #include "TerrainMetaPass.hlsl"
            ENDHLSL
        }
    }


    CustomEditor "SceneTerrainGUI"
}
