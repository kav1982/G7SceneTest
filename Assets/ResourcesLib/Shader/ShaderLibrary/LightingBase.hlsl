#ifndef BIOUM_LIGHTING_BASE_INCLUDED
#define BIOUM_LIGHTING_BASE_INCLUDED

//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Common.hlsl"
#include "SurfaceStruct.hlsl"
#include "GI.hlsl"
#include "Light.hlsl"
#include "BRDF.hlsl"
#include "SSS.hlsl"

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    #define GET_VERTEX_LIGHTING(vertexLighting) vertexLighting
    #define OUTPUT_VERTEX_LIGHTING(normalWS, positionWS, outputName) outputName = VertexLighting(normalWS, positionWS)
    #define DECLARE_VERTEX_LIGHTING(lightingName, index) half3 lightingName : TEXCOORD##index;
#else
    #define GET_VERTEX_LIGHTING(vertexLighting) 0
    #define OUTPUT_VERTEX_LIGHTING(normalWS, positionWS, outputName)
    #define DECLARE_VERTEX_LIGHTING(lightingName, index)
#endif

// Renamed -> LIGHTMAP_SHADOW_MIXING
#if !defined(_MIXED_LIGHTING_SUBTRACTIVE) && defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK)
    #define _MIXED_LIGHTING_SUBTRACTIVE
#endif


half3 ViewSpaceToneRim(Rim rimParam, half3 fragColor, half3 normalVS, half4 viewDirVS, half3 normalWS, half occlusion) // viewDirVS.w : lightDirVS.x
{
    half2 offset = half2(-viewDirVS.w, viewDirVS.w) * rimParam.Offset;
    // half3 frontView = normalize(viewDirVS.xyz + half3(offset.x, 0, 0));
    // half3 backView = normalize(viewDirVS.xyz + half3(offset.y, 0, 0));
    half3 frontView = normalize(half3(offset.x, viewDirVS.yz));
    half3 backView = normalize(half3(offset.y, viewDirVS.yz));
    half NdotFV = max(0, dot(normalVS, frontView));
    half NdotBV = max(0, dot(normalVS, backView));

    normalVS.x = viewDirVS.w > 0 ? normalVS.x : -normalVS.x;
    half4 f = half4(normalVS.x, normalWS.y, -normalVS.x, -normalWS.y);
    half4 falloff = saturate(f * half4(0.7, 0.7, 0.3, 0.3) + half4(0.3, 0.3, 0.7, 0.7));
    
    //half2 rim = PositivePow(1 - half2(NdotFV, NdotBV), rimParam.rimPower);
    half2 rim = Pow4(1 - half2(NdotFV, NdotBV));
    rim = smoothstep(0.5 - rimParam.Smooth, 0.5 + rimParam.Smooth, rim);
    rim *= half2(falloff.x * falloff.y, falloff.z * falloff.w);

    half3 rimFColor = rim.x * rimParam.ColorFront.rgb;
    fragColor += rimFColor;

    fragColor = lerp(fragColor, fragColor * rimParam.ColorBack, rim.y);

    return fragColor;
}

half3 RimColor(half3 lightDirWS, half3 normalWS, half3 viewDirWS, half4 rimColor)
{
    half3 backLightDir = lightDirWS; // * half3(1, 0.5, 1);
    half NdotV = abs(dot(normalWS, viewDirWS));
    half NdotBL = dot(normalWS, backLightDir) * 0.5 + 0.5;
    half2 range = PositivePow(half2(1 - NdotV, NdotBL), rimColor.a);

    return range.yyy * range.xxx * rimColor.rgb;
}


half SpecularStrength(half3 viewWS, half3 normalWS, BRDF brdf, half3 lightDirection)
{
    half3 h = SafeNormalize(lightDirection + viewWS);
    half nh2 = Square(saturate(dot(normalWS, h)));
    half lh2 = Square(saturate(dot(lightDirection, h)));
    half d2 = Square(nh2 * brdf.roughness2MinusOne + 1.00001);
    half spec = brdf.roughness2 / (d2 * max(0.1, lh2) * brdf.normalizationTerm);
    spec = min(100, spec);
    return spec;
}
half3 DirectSpecular(Surface surface, BRDF brdf, half3 lightDirection)
{
    half3 specular = 0;
#if _SPECULAR_ON
    specular = brdf.specular * SpecularStrength(surface.view, surface.normal, brdf, lightDirection);
    specular *= surface.specularColor;
#endif
    return specular;
}

half3 IndirectColorApplyOcclusion(half3 color, half3 sssColor, half3 occlusion)
{
#if _SSS
    color = lerp(sssColor, color, occlusion);
#else
    color *= occlusion;
#endif

    return color;
}

half3 IndirectSimple(Surface surface, half3 giDiffuse, half3 sssColor, half ssao)
{
    half fresnelStrength = Pow4(1.0 - abs(dot(surface.normal, surface.view)));
    fresnelStrength *= surface.fresnelStrength;

    half3 color = giDiffuse * surface.albedo.rgb;
    color += fresnelStrength * giDiffuse * 0.2;

    color = IndirectColorApplyOcclusion(color, sssColor, min(ssao, surface.occlusion));
    
    return color;
}
half3 IndirectSimple(Surface surface, BRDF brdf, half3 giDiffuse, half3 sssColor, half ssao)
{
    half fresnelStrength = Pow4(1.0 - abs(dot(surface.normal, surface.view)));
    fresnelStrength *= surface.fresnelStrength;

    half3 color = giDiffuse * brdf.diffuse;
    color += fresnelStrength * giDiffuse * 0.2;

    color = IndirectColorApplyOcclusion(color, sssColor, min(ssao, surface.occlusion));
    
    return color;
}

half3 IndirectLighting(Surface surface, BRDF brdf, GI gi, half3 sssColor, half ssao)
{
    half3 color = 0;
#if _ENVIRONMENT_REFLECTION_ON
    half fresnelStrength = Pow4(1.0 - abs(dot(surface.normal, surface.view)));
    fresnelStrength *= surface.fresnelStrength;

    half3 reflection = gi.specular * lerp(brdf.specular, brdf.fresnel, fresnelStrength);
    reflection /= brdf.roughness2 + 1.0;

    color = gi.diffuse * brdf.diffuse + reflection;

    color = IndirectColorApplyOcclusion(color, sssColor, min(ssao, surface.occlusion));
#else
    color = IndirectSimple(surface, brdf, gi.diffuse, sssColor, ssao);
#endif
    
    return color;
}


half3 Lambert(half3 lightColor, half3 lightDir, half3 normal)
{
    half NdotL = saturate(dot(normal, lightDir));
    return lightColor * NdotL;
}

half3 VertexLighting(half3 normalWS, float3 positionWS)
{
    half3 color = 0;
    uint vertexLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < vertexLightCount; ++ lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, positionWS);
        color += Lambert(light.color, light.direction, normalWS) * light.distanceAttenuation;
    }
    return color;
}


#endif  //BIOUM_LIGHTING_BASE_INCLUDED