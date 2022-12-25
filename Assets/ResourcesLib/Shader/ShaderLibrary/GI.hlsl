#ifndef BIOUM_GI_INCLUDE
#define BIOUM_GI_INCLUDE

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Color.hlsl"

#if LIGHTMAP_ON
    #define DECLARE_GI_DATA(lmName, shName, index) float2 lmName : TEXCOORD##index;
    #define OUTPUT_GI_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT) OUT.xy = lightmapUV.xy * lightmapScaleOffset.xy + lightmapScaleOffset.zw;
    #define OUTPUT_GI_SH(normalWS, OUT)
#elif _USE_CUSTOM_LIGHTING_INPUT
    #define DECLARE_GI_DATA(lmName, shName, index)
    #define OUTPUT_GI_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT)
    #define OUTPUT_GI_SH(normalWS, OUT)
#else
    #define DECLARE_GI_DATA(lmName, shName, index) half3 shName : TEXCOORD##index    
    #define OUTPUT_GI_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT)
    #define OUTPUT_GI_SH(normalWS, OUT) OUT.xyz = SampleSHVertex(normalWS)
#endif

#if _USE_CUSTOM_LIGHTING_INPUT
    TEXTURECUBE(_CustomEnvironmentCube);
    SAMPLER(sampler_CustomEnvironmentCube);
    half4 _CustomEnvironmentCube_HDR;
    half4 _CustomEnvironmentColor; // a : cube mipmap count
#endif



half3 SampleEnvironment (half3 viewWS, half3 normalWS, half perceptualRoughness) 
{
    half3 color = 0.5;
#if _ENVIRONMENT_REFLECTION_ON
    half3 uvw = reflect(-viewWS, normalWS);
    
    #if _USE_CUSTOM_LIGHTING_INPUT
        half lod = PerceptualRoughnessToMipmapLevel(perceptualRoughness, (uint)_CustomEnvironmentColor.a);
        half4 environment = SAMPLE_TEXTURECUBE_LOD(_CustomEnvironmentCube, sampler_CustomEnvironmentCube, uvw, lod);
        color = DecodeHDREnvironment(environment, _CustomEnvironmentCube_HDR);
    #else
        half lod = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
        half4 environment = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, uvw, lod);
        color = DecodeHDREnvironment(environment, unity_SpecCube0_HDR);
    #endif
#else
    #if _USE_CUSTOM_LIGHTING_INPUT
        color = _CustomEnvironmentColor.rgb;
    #else
        color = _GlossyEnvironmentColor.rgb;
    #endif
#endif
    return color;
}


#if defined(UNITY_DOTS_INSTANCING_ENABLED)
    #define LIGHTMAP_NAME unity_Lightmaps
    #define LIGHTMAP_INDIRECTION_NAME unity_LightmapsInd
    #define LIGHTMAP_SAMPLER_NAME samplerunity_Lightmaps
    #define LIGHTMAP_SAMPLE_EXTRA_ARGS lightmapUV, unity_LightmapIndex.x
#else
    #define LIGHTMAP_NAME unity_Lightmap
    #define LIGHTMAP_INDIRECTION_NAME unity_LightmapInd
    #define LIGHTMAP_SAMPLER_NAME samplerunity_Lightmap
    #define LIGHTMAP_SAMPLE_EXTRA_ARGS lightmapUV
#endif

half3 SampleDirectionalLightmap(float2 lightmapUV, half3 normalWS, inout half3 diffuse, half shadowMask = 1)
{
    half3 direction = 1;

    #if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
        float2 uv = lightmapUV;
        direction = SAMPLE_TEXTURE2D_LIGHTMAP(LIGHTMAP_INDIRECTION_NAME, LIGHTMAP_SAMPLER_NAME, LIGHTMAP_EXTRA_ARGS_USE);
        direction.rgb = direction.rgb * 2 - 1;
    
        half NdotL = saturate(dot(normalWS, direction.xyz));
        diffuse = lerp(NdotL * diffuse, diffuse, shadowMask);
        //diffuse += NdotL * diffuse;
    #endif
    
    return direction;
}
// Sample baked lightmap. Non-Direction and Directional if available.
// Realtime GI is not supported.
half3 SampleLightmap(float2 lightmapUV)
{
    #ifdef UNITY_LIGHTMAP_FULL_HDR
        bool encodedLightmap = false;
    #else
        bool encodedLightmap = true;
    #endif

    half4 decodeInstructions = half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h);

    // The shader library sample lightmap functions transform the lightmap uv coords to apply bias and scale.
    // However, universal pipeline already transformed those coords in vertex. We pass half4(1, 1, 0, 0) and
    // the compiler will optimize the transform away.
    half4 transformCoords = half4(1, 1, 0, 0);
    float2 uv = lightmapUV;
    half3 bakedColor = 0;
    
    #if defined(LIGHTMAP_ON)
        // Remark: baked lightmap is RGBM for now, dynamic lightmap is RGB9E5
        real4 lightmap = SAMPLE_TEXTURE2D_LIGHTMAP(LIGHTMAP_NAME, LIGHTMAP_SAMPLER_NAME, LIGHTMAP_EXTRA_ARGS_USE);
        bakedColor = encodedLightmap ? DecodeLightmap(lightmap, decodeInstructions) : lightmap.rgb;
    #endif

    return bakedColor;
}
half4 SampleShadowMask(half2 lightmapUV)
{
    #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
        return SAMPLE_TEXTURE2D_LIGHTMAP(SHADOWMASK_NAME, SHADOWMASK_SAMPLER_NAME, lightmapUV SHADOWMASK_SAMPLE_EXTRA_ARGS);
    #else
        return half4(1, 1, 1, 1);
    #endif
}


// Samples SH L0, L1 and L2 terms
half3 SampleSH(half3 normalWS)
{
    // LPPV is not supported in Ligthweight Pipeline
    real4 SHCoefficients[7];
    SHCoefficients[0] = unity_SHAr;
    SHCoefficients[1] = unity_SHAg;
    SHCoefficients[2] = unity_SHAb;
    SHCoefficients[3] = unity_SHBr;
    SHCoefficients[4] = unity_SHBg;
    SHCoefficients[5] = unity_SHBb;
    SHCoefficients[6] = unity_SHC;

    return max(half3(0, 0, 0), SampleSH9(SHCoefficients, normalWS));
}

// SH Vertex Evaluation. Depending on target SH sampling might be
// done completely per vertex or mixed with L2 term per vertex and L0, L1
// per pixel. See SampleSHPixel
half3 SampleSHVertex(half3 normalWS)
{
    #if !_PER_PIXEL_SH
        return SampleSH(normalWS);
    #else
        // no max since this is only L2 contribution
        return SHEvalLinearL2(normalWS, unity_SHBr, unity_SHBg, unity_SHBb, unity_SHC);
    #endif
}

// SH Pixel Evaluation. Depending on target SH sampling might be done
// mixed or fully in pixel. See SampleSHVertex
half3 SampleSHPixel(half3 L2Term, half3 normalWS)
{
    #if _USE_CUSTOM_LIGHTING_INPUT
        return _CustomEnvironmentColor.rgb;
    #else
        #if !_PER_PIXEL_SH
            return L2Term;
        #else
            half3 L0L1Term = SHEvalLinearL0L1(normalWS, unity_SHAr, unity_SHAg, unity_SHAb);
            half3 res = L2Term + L0L1Term;
            return max(half3(0, 0, 0), res);
        #endif
    #endif
}

half3 SampleGIDiffuse(half2 lightmapUV, half3 vertexSH, half3 normalWS)
{
    #if LIGHTMAP_ON
        return SampleLightmap(lightmapUV);
    #else
        return SampleSHPixel(vertexSH, normalWS);
    #endif
}

TEXTURE2D(_PlanarReflectionTexture);
half3 ApplyPlanarReflection(half3 giSpecular, half2 screenSpaceUV, half roughness)
{
    half lod = PerceptualRoughnessToMipmapLevel(roughness);
    half4 reflection = SAMPLE_TEXTURE2D_LOD(_PlanarReflectionTexture, Sampler_LinearClamp, screenSpaceUV, lod);
    half3 color = lerp(giSpecular, reflection.rgb, reflection.a);
    return color;
}


struct GI 
{
    half3 diffuse;
    half3 specular;
    half4 shadowMask;
    half3 lightDirection;
};

GI GetGI (half2 lightMapUV, half3 vertexSH, Surface surface, half perceptualRoughness)
{
    GI gi;
    gi.diffuse = SampleGIDiffuse(lightMapUV, vertexSH, surface.normal);
    gi.shadowMask = SampleShadowMask(lightMapUV);
    gi.specular = SampleEnvironment(surface.view, surface.normal, perceptualRoughness);
    gi.lightDirection = SampleDirectionalLightmap(lightMapUV, surface.normal, gi.diffuse, gi.shadowMask.x);
    return gi;
}

GI GetSimpleGI (half2 lightMapUV, half3 vertexSH) 
{
    GI gi = (GI)0;
    #ifndef BIOUM_ADDPASS

    gi.diffuse = SampleLightmap(lightMapUV) + vertexSH;
    gi.specular = unity_IndirectSpecColor.rgb;
    gi.shadowMask = SampleShadowMask(lightMapUV).r;
    gi.diffuse = ColorSpaceConvertInput(gi.diffuse);

    #endif

    return gi;
}

#ifdef LIGHTMAP_ON
#define GET_GI(lmName, shName, normalWSName, roughnessName) GetGI(lmName, 0, normalWSName, roughnessName)
#define GET_SIMPLE_GI(lmName, shName) GetSimpleGI(lmName, 0)
#else
#define GET_GI(lmName, shName, normalWSName, roughnessName) GetGI(0, shName, normalWSName, roughnessName)
#define GET_SIMPLE_GI(lmName, shName) GetSimpleGI(0, shName)
#endif


#endif