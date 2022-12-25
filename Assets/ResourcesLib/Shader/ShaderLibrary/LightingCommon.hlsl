#ifndef BIOUM_LIGHTING_INCLUDED
#define BIOUM_LIGHTING_INCLUDED

//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "LightingBase.hlsl"

half4 _TerrainBlendPositionMinMax;
TEXTURE2D(_TerrainBlendTarget);

half3 TerrainBlend(half3 albedo, float3 positionWS, half blendHeight, half blendFalloff)
{
    half2 terrainUV = (positionWS.xz - _TerrainBlendPositionMinMax.xy) / (_TerrainBlendPositionMinMax.zw - _TerrainBlendPositionMinMax.xy);
    half4 terrainTex = SAMPLE_TEXTURE2D(_TerrainBlendTarget, Sampler_LinearClamp, terrainUV);
    half heightBlend = saturate((positionWS.y + blendHeight) * blendFalloff);
    return lerp(terrainTex.rgb, albedo, heightBlend * heightBlend);
}

half3 PigTexBlend(half3 albedo, half3 pigmentCol, float3 positionWS, half blendHeight, half blendFalloff)
{
    half heightBlend = saturate((positionWS.y + blendHeight) * blendFalloff);
    return lerp(pigmentCol.rgb, albedo, heightBlend);
}

// radiance lighting
half4 MainLightShadowColor(Light light, half3 penumbraTint)
{
    half3 shadow = light.shadowAttenuation;
    
#if defined(_HIGH_QUALITY) || defined(_MEDIUM_QUALITY)
    half3 shadowTint = penumbraTint;
    half3 invTint = 1.0h - shadowTint;
    half3 shadow3 = shadow * shadow * shadow;
    //half3 shadow2 = shadow * shadow;
    shadow = (shadow3 * invTint + shadow * shadowTint);
#endif

    return half4(min(shadow, light.probeOcclusion.xxx), light.shadowAttenuation);
}
half3 MainLightIncoming(half3 normalWS, Light light, SubSurface sss, half3 penumbraTint)
{
    half3 atten = light.distanceAttenuation;
    half3 NdotL;
#if _SSS
    half sssNdotL = dot(sss.normal, light.direction);
    NdotL = SGDiffuseLighting(sssNdotL, sss.color.rgb);
#else
    NdotL = saturate(dot(normalWS, light.direction));
#endif
    
    half3 radiance = NdotL *light.color * atten * light.shadowAttenuation;
	radiance += saturate(1-NdotL)*penumbraTint;
    
    return radiance;
}

half3 MainLightInLit(half3 normalWS, Light light, half3 penumbraTint)
{
    half3 atten = light.distanceAttenuation;
    half3 NdotL;
    
    NdotL = saturate(dot(normalWS, light.direction));
    half3 radiance = NdotL *light.color * atten * light.shadowAttenuation;
    radiance += saturate(1-NdotL)*penumbraTint;
    return radiance;
}

half3 AddLightIncoming(half3 normalWS, Light light)
{
    half3 atten = light.distanceAttenuation * light.shadowAttenuation;
    half3 color = Lambert(light.color, light.direction, normalWS) * atten * light.probeOcclusion;
    
    return color;
}
// radiance lighting


// direct lighting
half3 DirectLightingPBR(Surface surface, BRDF brdf, half3 lightDirection, half3 radiance)
{
    half3 directSpecular = DirectSpecular(surface, brdf, lightDirection);
    return radiance * (directSpecular + brdf.diffuse);
}
half3 DirectLightingLambert(half3 albedo, half3 radiance)
{
    return radiance * albedo;
}
half3 DirectLightingPBRCombinedDirectionalLightmap(Surface surface, BRDF brdf, Light mainLight, half3 radiance)
{
    half4 shadowColor = MainLightShadowColor(mainLight, surface.penumbraTint);
    half3 directSpecular = DirectSpecular(surface, brdf, mainLight.direction);
    #if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
        return radiance * brdf.diffuse * shadowColor.rgb + directSpecular * mainLight.color;
    #else
        return radiance * (directSpecular + brdf.diffuse) * shadowColor.rgb;
    #endif
}
// direct lighting


// add lighting
half3 AddLightingPBR(Surface surface, BRDF brdf, half3 vertexLighting, half4 shadowMask)
{
    half3 color = 0;
#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, surface.position, shadowMask);
        half3 radiance = AddLightIncoming(surface.normal, light);
        color += DirectLightingPBR(surface, brdf, light.direction, radiance);
    }
#elif _ADDITIONAL_LIGHTS_VERTEX
    color += vertexLighting * brdf.diffuse;
#endif
    return color;
}
half3 AddLightingLambert(half3 albedo, half3 normalWS, float3 positionWS, half3 vertexLighting, half4 shadowMask)
{
    half3 color = 0;
#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, positionWS, shadowMask);
        half3 radiance = AddLightIncoming(normalWS, light);
        color += DirectLightingLambert(albedo, radiance);
    }
#elif _ADDITIONAL_LIGHTS_VERTEX
    color += vertexLighting * albedo;
#endif
    return color;
}


// add lighting

#if _PER_OBJECT_CAUSTIC
TEXTURE2D(_Bioum_CausticTexture);
half4 _Bioum_CausticColor;
half4 _Bioum_CausticParam;
#define causticAni _Bioum_CausticParam.x
#define causticDistort _Bioum_CausticParam.y
#define causticTilling _Bioum_CausticParam.z
#define causticDistortTilling _Bioum_CausticParam.w
#endif

half3 ApplyCaustic(half3 color, float3 positionWS, half3 normal, half shadow)
{
    #if _PER_OBJECT_CAUSTIC
        half4 uv = positionWS.xzxz * causticTilling * half4(1,1, causticDistortTilling.xx);
        half4 ani = frac(causticAni * _Time.y);
        uv += half4(ani.xy, -ani.zw);
        half noise = SAMPLE_TEXTURE2D(_Bioum_CausticTexture, Sampler_LinearRepeat, uv.zw).g;
        uv.xy += noise * causticDistort;
        half caustic = SAMPLE_TEXTURE2D(_Bioum_CausticTexture, Sampler_LinearRepeat, uv.xy).r;
        half3 causticColor = caustic * _Bioum_CausticColor.rgb;
        return color + color * causticColor * shadow * max(0, normal.y);
    #endif

    return color;
}


// final lighting
half3 LightingPBR(Surface surface, SubSurface sss, BRDF brdf, VertexData vertexData, GI gi, Light mainLight)
{
    half ao = min(surface.occlusion, mainLight.ScreenSpaceAO);
    half3 color = IndirectLighting(surface, brdf, gi, sss.color, mainLight.ScreenSpaceAO);
    color *= ao;
    
    half3 radiance = MainLightIncoming(surface.normal, mainLight, sss, surface.penumbraTint);
    color += DirectLightingPBRCombinedDirectionalLightmap(surface, brdf, mainLight, radiance);

    #ifdef _HIGH_QUALITY
        color += AddLightingPBR(surface, brdf, vertexData.lighting, gi.shadowMask);
    #else
        color += AddLightingLambert(brdf.diffuse, surface.normal, surface.position, vertexData.lighting, gi.shadowMask);
    #endif

    color = ApplyCaustic(color, surface.position, surface.normal, mainLight.shadowAttenuation);
    
    return max(0.01, color);
}

half3 MainLightIncomingX(half3 normalWS, Light light, SubSurface sss, half3 penumbraTint,float SmoothDiff,float LightOffset)
{
    half3 atten = light.distanceAttenuation;
    half3 NdotL;
    #if _SSS
    half sssNdotL = dot(sss.normal, light.direction);
    NdotL = SGDiffuseLighting(sssNdotL, sss.color.rgb);
    #else
    NdotL = saturate(dot(normalWS, light.direction));
    #endif
    NdotL = smoothstep(0,SmoothDiff,NdotL);
    
    half3 radiance = (1-LightOffset) * NdotL *light.color * atten * light.shadowAttenuation + LightOffset*light.shadowAttenuation;
    radiance += (1-NdotL) * penumbraTint;
    
    return radiance;
}


half3 LightingLambert(Surface surface, SubSurface sss, VertexData vertexData, GI gi, Light mainLight)
{
	half3 color = gi.diffuse * surface.albedo.rgb;
    color *= min(mainLight.ScreenSpaceAO,surface.occlusion);
    half3 radiance = MainLightIncoming(surface.normal, mainLight, sss, surface.penumbraTint);
    color += DirectLightingLambert(surface.albedo.rgb, radiance);
    color += AddLightingLambert(surface.albedo.rgb, surface.normal, surface.position, vertexData.lighting, gi.shadowMask);
    color = ApplyCaustic(color, surface.position, surface.normal, mainLight.shadowAttenuation);
    return max(0.01, color);
}

half3 LightingLambertlit(Surface surface, VertexData vertexData, GI gi, Light mainLight)
{
    half3 color = gi.diffuse * surface.albedo.rgb;
    color *= surface.occlusion;
    half3 radiance = MainLightInLit(surface.normal, mainLight, surface.penumbraTint);
    color += DirectLightingLambert(surface.albedo.rgb, radiance);
    color += AddLightingLambert(surface.albedo.rgb, surface.normal, surface.position, vertexData.lighting, gi.shadowMask);
    color = ApplyCaustic(color, surface.position, surface.normal, mainLight.shadowAttenuation);
    return max(0.01, color);
}

half3 LightingLambertX(Surface surface, SubSurface sss, VertexData vertexData, GI gi, Light mainLight,float3 LightControlParam)
{
    half3 color = gi.diffuse * surface.albedo.rgb;
    color *= min(mainLight.ScreenSpaceAO,surface.occlusion);
    half3 radiance = MainLightIncomingX(surface.normal, mainLight, sss, surface.penumbraTint,LightControlParam.y,LightControlParam.z);
    color += DirectLightingLambert(surface.albedo.rgb, radiance);
    color += AddLightingLambert(surface.albedo.rgb, surface.normal, surface.position, vertexData.lighting, gi.shadowMask);
    color = ApplyCaustic(color, surface.position, surface.normal, mainLight.shadowAttenuation);
    return max(0.01, color);
}


//---------添加--------

half4 g_SceneColorParam; //x:主光源亮度调整 Y:环境光亮度调整
half4 g_SceneTint;
half4 g_GlobalShadowColor;

half3 IncomingLight(Surface surface, Light light, SubSurface sss)
{
	half3 atten = light.shadowAttenuation * light.distanceAttenuation;
    half3 NdotL;
#if _SSS
    half sssNdotL = dot(sss.normal, light.direction);
    NdotL = SGDiffuseLighting(sssNdotL, sss.color.rgb);
#else
    NdotL = saturate(dot(surface.normal, light.direction));
#endif
    
    half3 radiance = NdotL * light.color * atten;
    
    return radiance;
}

half3 ApplyAddShadowColor(half3 color, half shadow, half3 shadowColor,half lightIntensity)
{
	return lerp(color,shadowColor,shadow) * lightIntensity;
}

half3 indirectSimple(Surface surface, GI gi, half4 colorControl = 0.5)
{
	gi.diffuse = lerp(gi.diffuse, colorControl.rgb, colorControl.rgb);
	if (g_SceneColorParam.w != 0)
	{
		gi.diffuse = lerp(gi.diffuse, g_SceneTint.rgb, g_SceneTint.a);
		gi.diffuse *= g_SceneColorParam.y;
	}
	half3 color = surface.albedo.rgb * gi.diffuse * surface.occlusion;

	return color;
}

half3 BioumLightingLambert(Surface surface, SubSurface sss, GI gi, Light mainLight, half3 shadowColor,half lightIntensity)
{
	half3 color = 0;
	half NdotL = saturate(dot(surface.normal, mainLight.direction));
	half shadowAttenuation = saturate(1-mainLight.shadowAttenuation * NdotL);

	gi.diffuse = lerp(unity_ShadowColor.rgb, gi.diffuse, shadowAttenuation);

	#ifndef BIOUM_ADDPASS
		color = indirectSimple(surface, gi);
	#endif

	color = ApplyAddShadowColor(color,shadowAttenuation,shadowColor,lightIntensity);

	color += IncomingLight(surface, mainLight,sss) * surface.albedo.rgb;		
	return color;
}

half3 GetLightingWithLightmap(Surface surface, GI gi, half3 emiColor)
{
	half3 color = 0;	
	color = gi.diffuse * surface.albedo.rgb * surface.occlusion;	
	color += emiColor;
	color = NeutralTonemap(color);

#if defined(UNITY_COLORSPACE_GAMMA)
	color = LinearToSRGB(color);
#endif

	return color;
}

half3 GetLightingWithLightmap(Surface surface, GI gi)
{
	half3 color = 0;	
	color = gi.diffuse * surface.albedo.rgb * surface.occlusion;	
	color = NeutralTonemap(color);
#if defined(UNITY_COLORSPACE_GAMMA)
	color = LinearToSRGB(color);
#endif
	return color;
}



#endif  //BIOUM_LIGHTING_INCLUDED