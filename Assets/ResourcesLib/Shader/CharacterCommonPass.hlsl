#ifndef BIOUM_CHARACTER_COMMON_PASS_INCLUDE
#define BIOUM_CHARACTER_COMMON_PASS_INCLUDE

#include "ShaderLibrary/LightingCommon.hlsl"
#include "ShaderLibrary/Fog.hlsl"

struct Attributes
{
    float4 positionOS: POSITION;
    real3 normalOS: NORMAL;
    real4 tangentOS: TANGENT;
    real2 texcoord: TEXCOORD0;
    real2 texcoord1: TEXCOORD1;
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    real4 uv: TEXCOORD0;
    real4 vertexSH : TEXCOORD1;
    float4 positionWSAndFog: TEXCOORD2;
    
    real3 normalWS: TEXCOORD3;
    real3 viewDirWS: TEXCOORD4;
    
    DECLARE_VERTEX_LIGHTING(vertexLighting, 5)
    DECLARE_SHADOWCOORD(shadowCoord, 6)

    real3 reflectionDir : TEXCOORD7;
#if _USE_DISSOLOVE
    real3 positionOS : TEXCOORD8;
    real3 normalOS : TEXCOORD9;
#endif
};

Varyings CommonLitVert(Attributes input)
{
    Varyings output = (Varyings)0;

#if _USE_DISSOLOVE
    float realY = input.positionOS.y;
    float uparea = smoothstep(_DissolveAmount+_ExpandWidth,_DissolveAmount,realY);
    float downarea = smoothstep(_DissolveAmount-_ExpandWidth,_DissolveAmount,realY);
    float area = uparea*downarea;
    input.positionOS.xz += _DissolveScale * area * input.normalOS.xz;
    output.positionOS = input.positionOS.xyz;
    output.normalOS = input.normalOS;
#endif

    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionWSAndFog.xyz = positionWS;
    output.positionCS = TransformWorldToHClip(positionWS);
    
    half3 viewDirWS = normalize(_WorldSpaceCameraPos - positionWS);

    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.viewDirWS = viewDirWS;
    
    output.uv.xy = input.texcoord;
    output.uv.zw = Prop_UseUV2 != 0 ? input.texcoord1 : input.texcoord;
    
    OUTPUT_GI_SH(output.normalWS.xyz, output.vertexSH.xyz);
    OUTPUT_SHADOWCOORD(positionWS, output.positionCS, output.shadowCoord);
    OUTPUT_VERTEX_LIGHTING(output.normalWS.xyz, positionWS, output.vertexLighting);
    
    output.positionWSAndFog.w = ComputeXYJFogFactor(ComputeScreenPos(output.positionCS / output.positionCS.w).xy, positionWS.y);

    output.reflectionDir = reflect(viewDirWS, normalize(mul(input.normalOS, (float3x3)unity_WorldToObject)));
    
    return output;
}

half4 CommonLitFrag(Varyings input): SV_TARGET
{
    Surface surface = (Surface)0;
    surface.albedo = sampleBaseMap(input.uv.xy);
    

#if _ALPHATEST_ON
    clip(surface.albedo.a - GetCutoff());
#endif
    



    half3 normalWS = input.normalWS;
    half3 viewDirWS = input.viewDirWS;

    surface.normal = normalize(normalWS);
    surface.view = normalize(viewDirWS);
    
    surface.position = input.positionWSAndFog.xyz;
    surface.penumbraTint = GetPenumbraTintColor();

    half4 emissiveAO = half4(GetEmissiveColor(), 1);
#if _EMISSIVE_AO_MAP
    emissiveAO = sampleEmissiveAOMap(input.uv.zw);
#endif
    surface.occlusion = emissiveAO.a;
    surface.emissive = emissiveAO.rgb;
    
    VertexData vertexData = (VertexData)0;
    vertexData.lighting = GET_VERTEX_LIGHTING(input.vertexLighting);
    vertexData.shadowCoord = GET_SHADOW_COORD(input.shadowCoord, surface.position);
    
    half alpha = GetTransparent() * surface.albedo.a;
    //BRDF brdf = GetBRDF(surface, alpha);
    //GI gi = GET_GI(input.lightmapUV, input.vertexSH.rgb, surface, brdf.perceptualRoughness);
    GI gi = GET_GI(input.lightmapUV, input.vertexSH.rgb, surface, 1);

    /*LightingControl lightingControl = InitLightingControl(); 
    lightingControl.intensity = Prop_LightIntensity;
    lightingControl.smoothDiff = Prop_SmoothDiff;
    lightingControl.useCustomLighting = Prop_UseGlobalLightingControl;*/
    
    SubSurface sss;
    sss.color = GetSSSColor().rgb;
    sss.occlusionMode = 0;
    sss.doToneMapping = true;
    sss.normal = input.normalWS.xyz;

    Light mainLight = GetMainLight(surface.position, vertexData.shadowCoord, gi);
    //mainLight.color *= Prop_LightIntensity;
    
    half3 color = LightingLambertX(surface, sss, vertexData, gi, mainLight,_LightControlParam.xyz);

    color += surface.emissive;

    /*half texGrey = (color.r + color.g + color.b) * 0.33;
    //return osz;
    color.rgb -= (color.rgb - texGrey) * saturate(1 - Prop_ColorRat * osz);*/
#if _USE_BRUSHTEX
    half4 brushTex = sampleBrushTex(input.uv.xy);
    half texGrey = (color.r + color.g + color.b) * 0.33;
    texGrey = pow(texGrey, 0.3);
    texGrey *= 1 - cos(texGrey * 3.14);
    half brushGrey = (brushTex.r + brushTex.g + brushTex.b) * 0.33;
    half blend = min(texGrey, brushGrey);
    color.rgb *= blend;
#endif

    //half edge = pow(dot(surface.view, surface.normal), 1) / _EdgeRange;
    //edge = step(_EdgeThred, edge) + step(edge, _EdgeThred) * edge;//edge = edge > _EdgeThred ? 1 : edge;
    //edge = pow(edge, _EdgePow);
    //color.rgb = half3(edge, edge, edge) * (1 - edge) + color.rgb * edge;
    
    //亮度增强特殊处理
    #if _USE_DISSOLOVE
    half dissoloveArea = GetDissoloveArea(input.positionOS);
    color *= lerp(Prop_LightIntensity,1,dissoloveArea);
    #else
    color *= Prop_LightIntensity;
    #endif

    color.rgb *= (_reflectionRat + (1 - _reflectionRat) * smoothstep(0, _SmoothReflection, pow(1-saturate(dot(input.reflectionDir, viewDirWS)), _reflectionPow)));

    #if _OUT_LINE
    float oneMinueNdotV = 1 - abs(dot(viewDirWS, normalWS));
    color.rgb = lerp(color.rgb, _OutLineCol, saturate(oneMinueNdotV * _OutLineMul + _OutLineAdd));
    #endif

    #if _USE_DISSOLOVE
    ApplyDissolove(color.rgb,dissoloveArea,input.positionOS,input.normalOS);
    #endif

    color = MixXYJFogColor(color, input.positionWSAndFog.w);

    //ApplyDissolove(color,input)

    //color = ApplyAttackFlash(color, surface.normal, surface.view);
    
    return half4(color, alpha);
}


#endif // BIOUM_CHARACTER_COMMON_PASS_INCLUDE