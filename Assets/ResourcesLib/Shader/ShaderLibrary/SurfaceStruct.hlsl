#ifndef BIOUM_STRUCT_UNCLUDE
#define BIOUM_STRUCT_UNCLUDE

struct Surface
{
    half4 albedo;
    float3 position;
    
    half  metallic;
    half  smoothness;
    half  occlusion;
    
    half3 view;
    half3 normal;
    
    half fresnelStrength;
    half F0Tint;
    half F0Strength;
    
    half3 emissive;
    half3 penumbraTint;
    half3 specularColor;
};

struct SubSurface
{
    half3 color;
    half3 normal;
    int occlusionMode;
    bool doToneMapping;
};


struct VertexData
{
    float4 shadowCoord;
    half3 lighting;
};


struct LightingControl
{
    half intensity;
    half smoothDiff;
    bool useCustomLighting;
};
LightingControl InitLightingControl()
{
    LightingControl control;
    control.smoothDiff = 1;
    control.intensity = 1;
    control.useCustomLighting = false;
    return control;
}

struct Rim
{
    half3 ColorFront;
    half3 ColorBack;
    half2 Offset;
    half Power;
    half Smooth;
};

struct HairParam
{
    half2 shift;
    half2 smoothness;
    half2 specIntensity;
    half3 tangent;
    half3 specColor;
    bool doubleSpecular;
};

#endif