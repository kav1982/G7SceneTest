#ifndef BIOUM_LIGHTING_CHARACTER_INCLUDED
#define BIOUM_LIGHTING_CHARACTER_INCLUDED

//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "LightingBase.hlsl"

half4 g_CharacterLightControl;

#define LIGHTCOLOR_NORMALIZE 0.65  // 降低将lambert二值化后亮部的亮度, 用于平衡观感亮度

half3 MainLightIncoming(half3 normalWS, Light light, SubSurface sss, half3 penumbraTint, LightingControl lightingControl)
{
    half3 atten = light.distanceAttenuation * light.shadowAttenuation;
    light.color *= lerp(LIGHTCOLOR_NORMALIZE, 1, lightingControl.smoothDiff);
    half3 NdotL;
#if _SSS
    half sssNdotL = dot(sss.normal, light.direction);
    half3 SG = SGDiffuseLighting(sssNdotL, sss.color.rgb);
    NdotL = smoothstep(0, lightingControl.smoothDiff, SG);
#else
    NdotL = saturate(dot(normalWS, light.direction));
    NdotL = smoothstep(0, lightingControl.smoothDiff, NdotL);
#endif

    half3 shadow = atten;
    half3 shadowTint = penumbraTint.rgb;
    half3 invTint = 1.0h - shadowTint;
    half3 shadow3 = shadow * shadow * shadow;
    atten = (shadow3 * invTint + shadow * shadowTint);

    half3 radiance = NdotL * light.color * atten * light.probeOcclusion * lightingControl.intensity;
    
    return radiance;
}
half3 AddLightIncoming(half3 normalWS, Light light, LightingControl lightingControl)
{
    light.color *= lerp(LIGHTCOLOR_NORMALIZE, 1, lightingControl.smoothDiff);
    half3 atten = light.distanceAttenuation * light.shadowAttenuation;
    half3 NdotL = saturate(dot(normalWS, light.direction));
    NdotL = smoothstep(0, lightingControl.smoothDiff, NdotL);
    half3 color = NdotL * light.color * atten * light.probeOcclusion;
    
    return color;
}



//hair
half3 ShiftT(half3 tangent, half3 normal, half shift)
{
	return tangent + normal * shift;
}
half2 KajiyaKaySpec(half3 tangent0, half3 tangent1, half3 viewDirWS, half3 lightDirWS, half2 smoothness)
{
	half3 halfDir = normalize(lightDirWS + viewDirWS);
	half tdoth0 = dot(tangent0, halfDir);
	half tdoth1 = dot(tangent1, halfDir);
	half2 sinTH = sqrt(max(0, 1 - half2(Square(tdoth0), Square(tdoth1))));
	half2 dirAtten = smoothstep(-1, 0, half2(tdoth0, tdoth1));

	half2 roughness = Pow4(1 - smoothness);
	half2 power = rcp(max(0.001, roughness));
    half2 intensity = smoothness * smoothness;

	return dirAtten * PositivePow(sinTH, power) * intensity;
}


//hair



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
half3 DirectLightingHair(Surface surface, Light light, half3 albedo, HairParam hairParam, half3 radiance)
{
    half3 shiftTangent0 = ShiftT(hairParam.tangent, surface.normal, hairParam.shift.x);
    half3 shiftTangent1 = ShiftT(hairParam.tangent, surface.normal, hairParam.shift.y);

    half2 spec = KajiyaKaySpec(shiftTangent0, shiftTangent1, surface.view, light.direction, hairParam.smoothness);
    spec *= hairParam.specIntensity;
    
    half3 specColor = spec.x + spec.y * hairParam.specColor;

    return radiance * (albedo + specColor);
}
// direct lighting


// add lighting
half3 AddLightingPBR(Surface surface, BRDF brdf, half3 vertexLighting, half4 shadowMask, LightingControl lightingControl)
{
    half3 color = 0;
#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, surface.position, shadowMask);
        half3 radiance = AddLightIncoming(surface.normal, light, lightingControl);
        color += DirectLightingPBR(surface, brdf, light.direction, radiance);
    }
#elif _ADDITIONAL_LIGHTS_VERTEX
    color += vertexLighting * brdf.diffuse;
#endif
    return color;
}
half3 AddLightingLambert(Surface surface, half3 vertexLighting, half4 shadowMask, LightingControl lightingControl)
{
    half3 color = 0;
#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, surface.position, shadowMask);
        half3 radiance = AddLightIncoming(surface.normal, light, lightingControl);
        color += DirectLightingLambert(surface.albedo.rgb, radiance);
    }
#elif _ADDITIONAL_LIGHTS_VERTEX
    color += vertexLighting * surface.albedo.rgb;
#endif
    return color;
}
// add lighting



half3 LightingPBR(Surface surface, SubSurface sss, BRDF brdf, half3 vertexLighting, GI gi, Light mainLight, LightingControl lightingControl)
{
    g_CharacterLightControl = lightingControl.useCustomLighting ? g_CharacterLightControl : half4(1,1,1,1);
    
    half3 color = IndirectLighting(surface, brdf, gi, sss.color, mainLight.ScreenSpaceAO) * g_CharacterLightControl.y;
    mainLight.color *= g_CharacterLightControl.x;
    
    half3 radiance = MainLightIncoming(surface.normal, mainLight, sss, surface.penumbraTint, lightingControl);
    color += DirectLightingPBR(surface, brdf, mainLight.direction, radiance);
    color += AddLightingPBR(surface, brdf, vertexLighting, gi.shadowMask, lightingControl);

    return max(0.01, color);
}

half3 LightingLambert(Surface surface, SubSurface sss, half3 vertexLighting, GI gi, Light mainLight, LightingControl lightingControl)
{
    g_CharacterLightControl = lightingControl.useCustomLighting ? g_CharacterLightControl : half4(1,1,1,1);
    
    half3 color = IndirectSimple(surface, gi.diffuse, sss.color, mainLight.ScreenSpaceAO) * g_CharacterLightControl.y;
    mainLight.color *= g_CharacterLightControl.x;
    
    half3 radiance = MainLightIncoming(surface.normal, mainLight, sss, surface.penumbraTint, lightingControl);
    color += DirectLightingLambert(surface.albedo.rgb, radiance);
    color += AddLightingLambert(surface, vertexLighting, gi.shadowMask, lightingControl);

    return max(0.01, color);
}

half3 LightingHair(Surface surface, SubSurface sss, HairParam hairParam, BRDF brdf, half3 vertexLighting, GI gi, Light mainLight, LightingControl lightingControl)
{
    g_CharacterLightControl = lightingControl.useCustomLighting ? g_CharacterLightControl : half4(1,1,1,1);
    
    half3 color = IndirectLighting(surface, brdf, gi, sss.color, mainLight.ScreenSpaceAO) * g_CharacterLightControl.y;
    mainLight.color *= g_CharacterLightControl.x;
    
    half3 radiance = MainLightIncoming(surface.normal, mainLight, sss, surface.penumbraTint, lightingControl);
    color += DirectLightingHair(surface, mainLight, surface.albedo.rgb, hairParam, radiance);
    color += AddLightingLambert(surface, vertexLighting, gi.shadowMask, lightingControl);

    return max(0.01, color);
}

#endif  //BIOUM_LIGHTING_CHARACTER_INCLUDED