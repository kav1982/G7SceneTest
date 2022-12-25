#ifndef BIOUM_TERRAIN_INPUT_INCLUDE
#define BIOUM_TERRAIN_INPUT_INCLUDE

#include "../ShaderLibrary/Common.hlsl"

//Constant Buffers  

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(half4, _Color0)
UNITY_DEFINE_INSTANCED_PROP(half4, _Color1)
UNITY_DEFINE_INSTANCED_PROP(half4, _Color2)
UNITY_DEFINE_INSTANCED_PROP(half4, _Color3)
UNITY_DEFINE_INSTANCED_PROP(half4, _Tilling)
UNITY_DEFINE_INSTANCED_PROP(half4, _NormalScale)
UNITY_DEFINE_INSTANCED_PROP(half4, _Smoothness)
UNITY_DEFINE_INSTANCED_PROP(half4, _AOStrength)
UNITY_DEFINE_INSTANCED_PROP(half4, _FresnelStrength)
UNITY_DEFINE_INSTANCED_PROP(half4, _F0Tint)
UNITY_DEFINE_INSTANCED_PROP(half4, _F0Strength)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#define Prop_Tilling UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Tilling)
#define Prop_NormalScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalScale)
#define Prop_Smoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness)
#define Prop_AOStrength UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _AOStrength)
#define Prop_FresnelStrength UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _FresnelStrength)
#define Prop_F0Tint UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _F0Tint)
#define Prop_F0Strength UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _F0Strength)

#define Prop_Color0 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color0)
#define Prop_Color1 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color1)
#define Prop_Color2 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color2)
#define Prop_Color3 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color3)

#define Prop_PenumbraTintColor half3(Prop_Color0.a, Prop_Color1.a, Prop_Color2.a)
#define Prop_HeightBlendWeight Prop_Color3.a

TEXTURE2D(_Splat0);
TEXTURE2D(_Splat1);
TEXTURE2D(_Splat2);
TEXTURE2D(_Splat3);
TEXTURE2D(_SplatMask0);
TEXTURE2D(_SplatMask1);
TEXTURE2D(_SplatMask2);
TEXTURE2D(_SplatMask3);
SAMPLER(sampler_Splat0);


half4 sampleBaseMap(TEXTURE2D_PARAM(textureName, samplerName), float2 uv, half3 color)
{
    half4 map = SAMPLE_TEXTURE2D(textureName, samplerName, uv);
    map.rgb *= color;
    return map;
}

half3 sampleMaskMap(TEXTURE2D_PARAM(textureName, samplerName), float2 uv, uint id, out half smoothness, out half ao)
{
    half4 map = SAMPLE_TEXTURE2D(textureName, samplerName, uv);
    half2 data;
    half3 normalTS = UnpackNormalAndData(map, Prop_NormalScale[id], data);

    smoothness = data.x * Prop_Smoothness[id];
    ao = LerpWhiteTo(data.y, Prop_AOStrength[id]);
        
    return normalTS;
}

half4 ApplyHeightMap(half4 controlMask, half4 heightMap)
{
    // heights are in mask blue channel, we multiply by the splat Control weights to get combined height
    half4 splatHeight = heightMap * controlMask;
    half maxHeight = max(splatHeight.r, max(splatHeight.g, max(splatHeight.b, splatHeight.a)));
    
    // Ensure that the transition height is not zero.
    half transition = max(Prop_HeightBlendWeight, 1e-5);

    // This sets the highest splat to "transition", and everything else to a lower value relative to that, clamping to zero
    // Then we clamp this to zero and normalize everything
    half4 weightedHeights = splatHeight + transition - maxHeight.xxxx;
    weightedHeights = max(0, weightedHeights);

    // We need to add an epsilon here for active layers (hence the blendMask again)
    // so that at least a layer shows up if everything's too low.
    weightedHeights = (weightedHeights + 1e-6) * controlMask;

    // Normalize (and clamp to epsilon to keep from dividing by zero)
    half sumHeight = max(dot(weightedHeights, half4(1, 1, 1, 1)), 1e-6);
    controlMask = weightedHeights / sumHeight.xxxx;
    
    return controlMask;
}


#endif 