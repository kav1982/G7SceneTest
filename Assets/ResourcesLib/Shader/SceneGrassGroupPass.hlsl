#ifndef BIOUM_SCENE_COMMON_PASS_INCLUDE
#define BIOUM_SCENE_COMMON_PASS_INCLUDE


#include "ShaderLibrary/Common.hlsl"
#include "ShaderLibrary/Fog.hlsl"
#include "ShaderLibrary/Noise.hlsl"
#include "ShaderLibrary/LightingCommon.hlsl"

struct Attributes
{
    float3 positionOS: POSITION;
    float3 normalOS: NORMAL;
    float4 tangentOS: TANGENT;
    half2 texcoord: TEXCOORD0;
    half2 lightmapUV: TEXCOORD1;
    half4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    half4 uv: TEXCOORD0;    
    DECLARE_GI_DATA(lightmapUV, vertexSH, 1);
    float4 positionWSAndFog: TEXCOORD2;
    
    float4 normalWS: TEXCOORD3;
    float3 sphereNormalWS: TEXCOORD4;
    half3 viewDirWS: TEXCOORD5;
    
#if _MAIN_LIGHT_SHADOWS
    float4 shadowCoord : TEXCOORD6;
#endif

    float2 pigmentUV : TEXCOORD8;
    BIOUM_BUILTIN_FOG_COORDS(9)	
    UNITY_VERTEX_INPUT_INSTANCE_ID
};



Varyings CommonLitVert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    
    
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

    half2 falloff = input.positionOS.y * rcp(half2(GetWindFalloff(), GetColorFalloff()))*6;
    
    //_WIND_GRASS
    half2 direction = GetWindDirection();
    half scale = GetWindScale();
    half speed = GetWindSpeed();

    half4 windParam = half4(direction,scale,speed);
    positionWS.xz += PlantsAnimationNoise(positionWS, windParam, falloff.y)/6;

    output.positionWSAndFog.xyz = positionWS;
    output.positionCS = TransformWorldToHClip(positionWS);
    
    float3 viewDirWS = normalize(_WorldSpaceCameraPos - positionWS);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    float3 sphereNormalWS = TransformObjectToWorldDir(half3(0,1,0));
    output.normalWS.xyz = normalWS;
    output.sphereNormalWS = sphereNormalWS;
    output.normalWS.w = falloff.y;
    output.viewDirWS = viewDirWS;
        
    output.uv.xy = input.texcoord * _BASEMAP_ST.xy + _BASEMAP_ST.zw;
    output.uv.zw = input.lightmapUV;
    output.pigmentUV = (positionWS.xz - float2(_XOffset,_YOffset) - _PigmentTrans.xy) / _PigmentTrans.zw;
    
    float3 normal = lerp(sphereNormalWS, normalWS, GetNormalWarp());
    normal = normalize(normal);
    OUTPUT_GI_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_GI_SH(sphereNormalWS, output.vertexSH);        
    //output.positionWSAndFog.w = ComputeFogFactor(output.positionCS.z, positionWS.xyz, 1);

#if _MAIN_LIGHT_SHADOWS
    output.shadowCoord = TransformWorldToShadowCoord(positionWS);
#endif
    BIOUM_TRANSFER_BUILTIN_FOG(output, output.positionCS);   
    return output;
}

half4 CommonLitFrag(Varyings input, half isFront : VFACE): SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    
    Surface surface = (Surface)0;
    surface.albedo = sampleBaseMap(input.uv.xy);
    //clip(GetCutoff());
    //sampleMaskMap(input.uv.xy);
    //#if _ALPHATEST_ON
    clip(surface.albedo.a - GetCutoff());
    //#endif

    
    float3 normalWS = isFront > 0 ? input.normalWS.xyz : -input.normalWS.xyz;
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
    vertexData.shadowCoord = GET_SHADOW_COORD(input.shadowCoord, surfa+ce.position);
    
    half alpha = surface.albedo.a;
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
	
    //color = ApplySceneDarkness(color);
    
    return half4(color, alpha);
}



#endif 