#ifndef BIOUM_FOG_INCLUDE
#define BIOUM_FOG_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

half4 _Bioum_FogColor;

// x = start distance
// y = start height
// z = distance falloff
// w = height falloff
half4 _Bioum_FogParam;

//#define _BIOUM_FOG_EX 1
half4 _FogInfo;
half4 _FogColor;
half4 _HeightFogDensity;


//distance exp fog and height exp fog
//http://www.iquilezles.org/www/articles/fog/fog.htm

half3 MixBuiltInFog(half3 fragColor, half3 fogColor, half fogFactor)
{
    half3 color = fragColor;
    color = lerp(fogColor, fragColor, fogFactor);
    return color;
}

half3 MixBuiltInFog(half3 fragColor, half fogFactor)
{
    return MixBuiltInFog(fragColor, unity_FogColor.rgb, fogFactor);
}

half ComputeBuiltInFogFactor(float z)
{
    float clipZ_01 = UNITY_Z_0_FAR_FROM_CLIPSPACE(z);

    half fogFactor = 0;

    // factor = (end-z)/(end-start) = z * (-1/(end-start)) + (end/(end-start))
    //fogFactor = saturate(clipZ_01 * unity_FogParams.z + unity_FogParams.w);

    //unity_FogParams.w is zero when fog is disable
    fogFactor = saturate(clipZ_01 * unity_FogParams.z + lerp(unity_FogParams.w, 1, step(unity_FogParams.w, 0)));
    return fogFactor;
}

half ComputeBioumFogFactor(float positionCSz, float height, half fogStrength = 1) 
{
    float fogFactor = 0;
    #if _BIOUM_FOG_EX
        float dis = UNITY_Z_0_FAR_FROM_CLIPSPACE(positionCSz);

        float2 fac = (float2(dis, height) - _Bioum_FogParam.xy) * _Bioum_FogParam.zw;
        fac.x = -fac.x;
        float2 disAndHeight = max(0, 1 - exp(fac));
    
        // float disFogFactor = max(0, 1 - exp(-(dis - Bioum_FogParam.x) * Bioum_FogParam.y));
        // float heightFogFactor = max(0, 1 - exp((height - Bioum_FogParam.z) * Bioum_FogParam.w));
    
        fogFactor = lerp(disAndHeight.x * disAndHeight.y, saturate(disAndHeight.x + disAndHeight.y), disAndHeight.x);

        fogFactor += fogStrength - 1;
    #endif

    return saturate(fogFactor);
}

half ComputeXYJFogFactor(float2 viewPos, float positionWSy) 
{
    float linearDepthFog = saturate((viewPos.y + _HeightFogDensity.w - (sqrt(_HeightFogDensity.w * _HeightFogDensity.w - pow(viewPos.x-0.5, 2)))) / (_FogInfo.y - _FogInfo.x) + _FogInfo.x / (_FogInfo.x - _FogInfo.y));
	//_HeightFogDensity  x向上部分的浓度 y向下加深的高度值  z向下渐变的系数 w圆弧半径
	float highFog = (_FogInfo.z - positionWSy) / (_FogInfo.z - _FogInfo.w) * _HeightFogDensity.x;
    highFog = step(_FogInfo.w, positionWSy) * highFog + max(linearDepthFog * highFog, step(positionWSy, _FogInfo.w) * saturate((_FogInfo.w - positionWSy) / (_FogInfo.w - _HeightFogDensity.y)) * _HeightFogDensity.z);

	//return max(linearDepthFog, highFog);
	
	return linearDepthFog * highFog + step(positionWSy, _FogInfo.w) * highFog;
}

half3 GetScatteringColor(half3 lightDir, half3 lightColor, half3 viewDirWS)
{
    half sun = max(0, dot(-lightDir, viewDirWS));
    sun *= sun;
    return lightColor.rgb * sun;
}
half3 MixBioumFogColor(half3 fogColor, half3 color, half fogFactor, half3 viewDirWS)
{
    #if _BIOUM_FOG_EX
        half3 lightDir = _MainLightPosition.xyz;
        half3 lightColor = _MainLightColor.rgb;
        half3 scatteringColor = GetScatteringColor(lightDir, lightColor, viewDirWS);
        fogColor += scatteringColor;
        return lerp(color, fogColor, fogFactor);
    #endif
    
    return color;
}
half3 MixBioumFogColor(half3 color, half fogFactor, half3 viewDirWS)
{
    return MixBioumFogColor(_Bioum_FogColor.rgb, color, fogFactor, viewDirWS);
}

half3 MixBioumFogColor(half3 fogColor, half3 color, half fogFactor)
{
    return lerp(color, fogColor, fogFactor);
}
half3 MixBioumFogColor(half3 color, half fogFactor)
{
    return MixBioumFogColor(_Bioum_FogColor.rgb, color, fogFactor);
}

half3 MixXYJFogColor(half3 color, half fogFactor)
{
    return lerp(color, _FogColor.rgb, saturate(fogFactor * _FogColor.a));
}
	
#define BIOUM_BUILTIN_FOG_COORDS(idx) float fogCoord : TEXCOORD##idx;
#define BIOUM_TRANSFER_BUILTIN_FOG(o,outpos) o.fogCoord.x = outpos.z;
#define BIOUM_APPLY_BUILTIN_FOG(coord,col) col.rgb = MixBuiltInFog(col.rgb, ComputeBuiltInFogFactor(coord.x))

//fog end

#endif  //BIOUM_FOG_INCLUDE