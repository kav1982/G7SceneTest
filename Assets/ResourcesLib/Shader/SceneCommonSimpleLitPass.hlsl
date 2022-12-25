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
    
#if _NORMALMAP
    real4 tangentWS: TEXCOORD4;    // xyz: tangent, w: viewDir.x
    real4 bitangentWS: TEXCOORD5;    // xyz: binormal, w: viewDir.y
    real4 normalWS: TEXCOORD3;    // xyz: normal, w: viewDir.z
#else
    real3 normalWS: TEXCOORD3;
    real3 viewDirWS: TEXCOORD4;
#endif
    
    DECLARE_VERTEX_LIGHTING(vertexLighting, 6)
    DECLARE_SHADOWCOORD(shadowCoord, 7)

	float4 positionOSandVertexColR : TEXCOORD8;

/*#if _RIM
    real3 normalVS : TEXCOORD8;
    real4 viewDirVS : TEXCOORD9;
#endif*/
    
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
        positionWS.xz += PlantsAnimationNoise(positionWS, Prop_WindParam, Prop_WindFalloff) * input.positionOS.y;
    }
#endif
    
    output.positionWSAndFog.xyz = positionWS;
    output.positionCS = TransformWorldToHClip(positionWS);
    
    half3 viewDirWS = SafeNormalize(_WorldSpaceCameraPos.xyz - positionWS);
    half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
#if _NORMALMAP
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.tangentWS = half4(normalInput.tangentWS, viewDirWS.x);
    output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.y);
    output.normalWS = half4(normalInput.normalWS, viewDirWS.z);
#else
    output.normalWS = normalWS;
    output.viewDirWS = viewDirWS;
#endif
    
    output.uv.xy = input.texcoord;
    output.uv.zw = Prop_UseUV2 != 0 ? input.lightmapUV : input.texcoord;
    
    OUTPUT_GI_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_GI_SH(normalWS, output.vertexSH);
    OUTPUT_SHADOWCOORD(positionWS, output.positionCS, output.shadowCoord);
    OUTPUT_VERTEX_LIGHTING(normalWS, positionWS, output.vertexLighting);
    
    //output.positionWSAndFog.w = ComputeBioumFogFactor(output.positionCS.z, positionWS.y);
    output.positionWSAndFog.w = ComputeXYJFogFactor(ComputeScreenPos(output.positionCS / output.positionCS.w).xy, positionWS.y);

	output.positionOSandVertexColR.xyz = input.positionOS;
	#if _VERTEXAO_ON
	   output.positionOSandVertexColR.w = 1-saturate((1-input.color.r) * _AOStrength);
    #endif
	
/*#if _RIM
    real3 lightDirVS = TransformWorldToViewDir(MainLightDirection(), false);
    output.viewDirVS.xyz = TransformWorldToViewDir(viewDirWS, false);
    output.viewDirVS.w = lightDirVS.x;
    output.normalVS = TransformWorldToViewDir(output.normalWS.xyz, false);
#endif*/
    //half3 strength = _VertexAOStrength;

    return output;
}

half4 SimpleLitFrag(Varyings input): SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    DitherLOD(unity_LODFade.x, input.positionCS.xy);

    Surface surface = (Surface)0;
    surface.albedo = sampleBaseMap(input.uv.xy);
    sampleMaskMap(input.uv.xy);
#if _ALPHATEST_ON
    clip(surface.albedo.a - GetCutoff());
#endif

//#if _TERRAIN_BLEND_FUNC
//    surface.albedo.rgb = TerrainBlend(surface.albedo.rgb, input.positionWSAndFog.xyz, Prop_TerrainBlendHeight, Prop_TerrainBlendFalloff);
//#endif
    
#if _NORMALMAP
    half3 normalTS = sampleNormalMetalSmoothMap(input.uv.xy);
    half3x3 TBN = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    half3 normalWS = mul(normalTS, TBN);
    half3 viewDirWS = half3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
#else
    half3 normalWS = input.normalWS.xyz;
    half3 viewDirWS = input.viewDirWS;
#endif
    
    //surface.normal = half3(1,1,1);

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
    sss.color = GetSSSColor().rgb;
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

/*#if _RIM
    Rim rimParam;
    rimParam.ColorFront = Prop_RimColorFront.rgb;
    rimParam.ColorBack = Prop_RimColorBack.rgb;
    rimParam.Offset = Prop_RimOffset;
    rimParam.Smooth = Prop_RimSmooth;
    rimParam.Power = Prop_RimPower;
    color = ViewSpaceToneRim(rimParam, color, input.normalVS, input.viewDirVS, input.normalWS.xyz, surface.occlusion);
#endif*/



#if _DARKPART
    DarkPartData darkPartData = GetDarkPartData(surface.albedo,input.positionOSandVertexColR.xyz);
	color = AddDarkPartLight(color,darkPartData);
#endif
    
    color += emissiveAO.rgb;

#if _OUTLINE
    //half edgo_offset = max(0, dot(normalize(surface.view + half3(Prop_EdgeAngle, 1 - saturate(abs(Prop_EdgeAngle)), 0)), surface.normal)) * Prop_EdgeAngleScale;
    half edgo_offset = (1 - max(0, dot(normalize(surface.view + half3(Prop_EdgeAngle, 0, 0)), surface.normal))) * Prop_EdgeAngleScale;
    half edge = 1 - max(0, dot(surface.view, surface.normal));
    edge = saturate(edge + _EdgeMask * Prop_EdgeMaskScale);
    edge = step(Prop_EdgeThred, edge) * edge;
    edge = pow(edge, 1 / max(Prop_EdgePow - edgo_offset, 0.01));
    color.rgb = lerp(color.rgb, Prop_EdgeColor.rgb, edge * Prop_EdgeColor.a);
    //color.rgb = lerp(color.rgb, Prop_EdgeColor.rgb, edge * Prop_EdgeColor.a * (1 - input.positionCS.y / _ScreenParams.y));
#endif



#if _BUTGRADIENT
    color.rgb = AddButGradient(color.rgb,input.positionOSandVertexColR.xyz,input.positionWSAndFog.y);
#endif

    //color = MixBioumFogColor(color, input.positionWSAndFog.w);
	#if _VERTEXAO_ON
	   	half ao = 1-input.positionOSandVertexColR.w;
	    color.rgb = lerp(color.rgb,_VertexAOCol * color.rgb * _AOColStrength,ao);
	#endif

	#if _TERRAIN_BLEND_FUNC
    color.rgb = TerrainBlend(color.rgb, input.positionWSAndFog.xyz, Prop_TerrainBlendHeight, Prop_TerrainBlendFalloff);
    #endif

	color = MixXYJFogColor(color, input.positionWSAndFog.w);
	
    color = ApplySceneDarkness(color);
    
    return half4(color, alpha);
}


#endif // BIOUM_SCENE_COMMON_PASS