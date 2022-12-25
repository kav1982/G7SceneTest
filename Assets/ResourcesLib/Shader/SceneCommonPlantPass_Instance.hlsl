#ifndef BIOUM_SCENE_SIMPLELIT_PASS_INCLUDE
#define BIOUM_SCENE_SIMPLELIT_PASS_INCLUDE

#include "ShaderLibrary/LightingCommon.hlsl"
#include "ShaderLibrary/Fog.hlsl"

struct Attributes
{
    float3 positionOS: POSITION;
    real3 normalOS: NORMAL;
    real4 tangentOS: TANGENT;
    real2 texcoord: TEXCOORD0;
    real2 lightmapUV: TEXCOORD1;
    half4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    real4 uv: TEXCOORD0;
    DECLARE_GI_DATA(lightmapUV, vertexSH, 1);
    float4 positionWSAndFog: TEXCOORD2;
    
    real3 normalWS: TEXCOORD3;
    real3 viewDirWS: TEXCOORD4;
    
    DECLARE_VERTEX_LIGHTING(vertexLighting, 6)
    DECLARE_SHADOWCOORD(shadowCoord, 7)

	float3 positionOS : TEXCOORD8;

    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct 

Varyings SimpleLitVert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

#if defined(_HIGH_QUALITY) || defined(_MEDIUM_QUALITY)
    UNITY_BRANCH
    if(GetWindToggle())
    {
        positionWS.xz += PlantsAnimationNoise(positionWS, Prop_WindParam, input.positionOS.y);
    }
#endif
    
    output.positionWSAndFog.xyz = positionWS;
    output.positionCS = TransformWorldToHClip(positionWS);
    
    half3 viewDirWS = _WorldSpaceCameraPos.xyz - positionWS;
    half3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    output.normalWS = normalWS;
    output.viewDirWS = viewDirWS;
    
    output.uv.xy = input.texcoord;
    output.uv.zw = Prop_UseUV2 != 0 ? input.lightmapUV : input.texcoord;
    
    OUTPUT_GI_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_GI_SH(normalWS, output.vertexSH);
    OUTPUT_SHADOWCOORD(positionWS, output.positionCS, output.shadowCoord);
    OUTPUT_VERTEX_LIGHTING(normalWS, positionWS, output.vertexLighting);
    
    //output.positionWSAndFog.w = ComputeBioumFogFactor(output.positionCS.z, positionWS.y);
    output.positionWSAndFog.w = ComputeXYJFogFactor(ComputeScreenPos(output.positionCS / output.positionCS.w).xy, positionWS.y);

	output.positionOS = input.positionOS;
	
    
    return output;
}

half4 SimpleLitFrag(Varyings input): SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    
    Surface surface = (Surface)0;
    surface.albedo = sampleBaseMap(input.uv.xy);
    //sampleMaskMap(input.uv.xy);
#if _ALPHATEST_ON
    clip(surface.albedo.a - GetCutoff());
#endif

    
	half3 normalWS = input.normalWS.xyz;
    half3 viewDirWS = input.viewDirWS;

    surface.normal = normalize(normalWS);

    surface.view = normalize(viewDirWS);
    
    half4 emissiveAO = half4(GetEmissiveColor(), 1);
#if _EMISSIVE_AO_MAP
    emissiveAO = sampleEmissiveAOMap(input.uv.zw);
#endif
    surface.occlusion = emissiveAO.a;
    
    surface.position = input.positionWSAndFog.xyz;
    surface.penumbraTint = GetPenumbraTintColor();

    SubSurface sss = (SubSurface)0;
    sss.color = 0;
    sss.doToneMapping = false;
    sss.normal = input.normalWS.xyz;

    VertexData vertexData = (VertexData)0;
    vertexData.lighting = GET_VERTEX_LIGHTING(input.vertexLighting);
    vertexData.shadowCoord = GET_SHADOW_COORD(input.shadowCoord, surface.position);
    
    half alpha = GetTransparent() * surface.albedo.a;
    half roughness = 1;
    GI gi = GET_GI(input.lightmapUV, input.vertexSH, surface, roughness);

    Light mainLight = GetMainLight(surface.position, vertexData.shadowCoord, gi);
    half3 color = LightingLambert(surface, sss, vertexData, gi, mainLight);



#if _DARKPART
    DarkPartData darkPartData = GetDarkPartData(surface.albedo,input.positionOS);
	color = AddDarkPartLight(color,darkPartData);
#endif
    
    color += emissiveAO.rgb;

#if _BUTGRADIENT
    color.rgb = AddButGradient(color.rgb,input.positionOS,input.positionWSAndFog.y);
#endif

    //color = MixBioumFogColor(color, input.positionWSAndFog.w);
	color = MixXYJFogColor(color, input.positionWSAndFog.w);
	
    color = ApplySceneDarkness(color);
    
    return half4(color, alpha);
}


#endif // BIOUM_SCENE_COMMON_PASS