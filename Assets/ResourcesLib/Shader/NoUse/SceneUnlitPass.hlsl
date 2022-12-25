#ifndef BIOUM_SCENE_UNLIT_PASS_INCLUDE
#define BIOUM_SCENE_UNLIT_PASS_INCLUDE

#include "../ShaderLibrary/Fog.hlsl"

struct Attributes
{
    float3 positionOS: POSITION;
    real2 texcoord: TEXCOORD0;
    real2 lightmapUV: TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    real4 uv: TEXCOORD0;
#if _USE_FOG
    half fogFactor : TEXCOORD1;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

Varyings UnlitVert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionCS = TransformWorldToHClip(positionWS);
    
    output.uv.xy = input.texcoord;
    output.uv.zw = Prop_UseUV2 != 0 ? input.lightmapUV : input.texcoord;

#if _USE_FOG
    //output.fogFactor = ComputeBioumFogFactor(output.positionCS.z, positionWS.y, Prop_FogIntensity);
	output.fogFactor = ComputeXYJFogFactor(ComputeScreenPos(output.positionCS / output.positionCS.w).xy, positionWS.y);
#endif

    return output;
}

half4 UnlitFrag(Varyings input): SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    
    half4 albedo = sampleBaseMap(input.uv.xy);
#if _ALPHATEST_ON
    clip(albedo.a - GetCutoff());
#endif

    half3 color = albedo.rgb;
    half alpha = GetTransparent() * albedo.a;

    half3 emissive = GetEmissiveColor();
#if _EMISSIVE_MAP
    emissive = sampleEmissiveMap(input.uv.zw);
#endif

    color += emissive;

#if _USE_FOG
    //color = MixBioumFogColor(color, input.fogFactor);
	color = MixXYJFogColor(color, input.fogFactor);
#endif
    
    return half4(color, alpha);
}


#endif // BIOUM_SCENE_COMMON_PASS