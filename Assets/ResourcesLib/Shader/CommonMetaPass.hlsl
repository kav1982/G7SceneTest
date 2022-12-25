#ifndef COMMOM_META_PASS_INCLUDED
#define COMMOM_META_PASS_INCLUDED


#include "ShaderLibrary/Common.hlsl"
#include "ShaderLibrary/LightingCommon.hlsl"
#include "ShaderLibrary/BRDF.hlsl"
#include "ShaderLibrary/GI.hlsl"

struct Attributes 
{
    float3 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;
    float2 lightMapUV : TEXCOORD1;
};

struct Varyings 
{
    float4 positionCS : SV_POSITION;
    float4 uv : TEXCOORD0;
};

Varyings MetaPassVertex (Attributes input) 
{
    Varyings output;
    input.positionOS.xy = input.lightMapUV * unity_LightmapST.xy + unity_LightmapST.zw;
    input.positionOS.z = input.positionOS.z > 0.0 ? HALF_MIN : 0.0;
    output.positionCS = TransformWorldToHClip(input.positionOS);
    output.uv.xy = input.texcoord.xy * _BASEMAP_ST.xy + _BASEMAP_ST.zw;
    output.uv.zw = Prop_UseUV2 != 0 ? input.lightMapUV : output.uv.xy;
    return output;
}

bool4 unity_MetaFragmentControl;
float unity_OneOverOutputBoost;
float unity_MaxOutputValue;
float4 MetaPassFragment (Varyings input) : SV_TARGET 
{
    Surface surface = (Surface)0;
    surface.albedo = sampleBaseMap(input.uv.xy);
    surface.metallic = 0;
    surface.smoothness = 0.5;
    
    half alpha = GetTransparent() * surface.albedo.a;
    BRDF brdf = GetBRDF(surface, alpha);
    
    float3 meta = 0;
    if (unity_MetaFragmentControl.x) 
    {
        meta.rgb = brdf.diffuse + brdf.specular * brdf.roughness * 0.5;
        meta.rgb = min(PositivePow(meta.rgb, unity_OneOverOutputBoost), unity_MaxOutputValue);
    }
    if (unity_MetaFragmentControl.y) 
    {
        float3 emiColor = sampleEmissiveAOMap(input.uv.zw).rgb;
        emiColor = PositivePow(emiColor, GetEmissiveBoost());
        meta += emiColor;
    }
    return half4(meta, alpha);
}

#endif