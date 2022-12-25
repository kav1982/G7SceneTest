#ifndef BIOUM_SEA_WATER_PASS_INCLUDE
#define BIOUM_SEA_WATER_PASS_INCLUDE

#include "ShaderLibrary/Common.hlsl"
#include "ShaderLibrary/Fog.hlsl"
#include "ShaderLibrary/Water.hlsl"
#include "ShaderLibrary/SurfaceStruct.hlsl"

struct Attributes
{
    float3 positionOS: POSITION;
    float2 uv: TEXCOORD0;
    float2 uv1: TEXCOORD1;
    float2 uv2: TEXCOORD2; 
    half3 normalOS : NORMAL;
    half4 tangentOS : TANGENT;
    half4 color : COLOR0;
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    float4 uv: TEXCOORD0;
    float4 fuv: TEXCOORD1;
    half4 color : COLOR0;
    float4 positionWSAndFog: TEXCOORD2;
    half4 tangentWS: TEXCOORD3;
    half4 bitangentWS: TEXCOORD4;
    half4 normalWS: TEXCOORD5;
    float4 positionNDC: TEXCOORD6;
    float3 positionWS : TEXCOORD7;
    float3 positionVS : TEXCOORD8;
	//BIOUM_BUILTIN_FOG_COORDS(8)
    half4 vColor : COLOR1; 
};

//#define TWO_PI 6.2832
#define DEG_2_RAD 0.017453


Varyings WaterLitVert(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexPosition;
    vertexPosition.positionWS = TransformObjectToWorld(input.positionOS);

    float3 tangentWS = float3(1,0,0), binormalWS = float3(0,0,1), normalWS = float3(0,1,0);

    
    vertexPosition.positionVS = TransformWorldToView(vertexPosition.positionWS);
    vertexPosition.positionCS = TransformWorldToHClip(vertexPosition.positionWS);

    float4 ndc = vertexPosition.positionCS * 0.5f;
    vertexPosition.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    vertexPosition.positionNDC.zw = vertexPosition.positionCS.zw;
	vertexPosition.positionNDC.z = -vertexPosition.positionVS.z;

	output.positionNDC = vertexPosition.positionNDC;	
    output.positionCS = vertexPosition.positionCS;
    output.positionVS = vertexPosition.positionVS;
    output.positionWS = vertexPosition.positionWS.xyz;
    output.positionWSAndFog.xyz = vertexPosition.positionWS;
    

    //float4 uv = output.positionWSAndFog.xzxz  * float4(1,1,1.3,1.28);
    //output.uv = uv + frac(_Time.x * _WaveSpeed);
    output.uv.xy = input.uv.xy;    
    output.uv.z = _Time.x;
    output.uv.w = 0;

    output.fuv.xy = input.uv1.xy;    
    output.fuv.zw = input.uv2.xy;
    

    half3 viewDirWS = _WorldSpaceCameraPos.xyz - vertexPosition.positionWS;
    output.tangentWS = half4(tangentWS, viewDirWS.x);
    output.bitangentWS = half4(binormalWS, viewDirWS.y);
    output.normalWS = half4(normalWS, viewDirWS.z);
    output.color = input.color.rgba;
	output.vColor = _WaterColor;   
	
    //output.positionWSAndFog.w = output.positionCS.z;
	//BIOUM_TRANSFER_BUILTIN_FOG(output, output.positionCS);
	output.positionWSAndFog.w = ComputeXYJFogFactor(ComputeScreenPos(output.positionCS / output.positionCS.w).xy, output.positionWS.y);
	
    return output;
}



float4 WaterLitFrag(Varyings input): SV_TARGET
{    
    
    //base color and alpha
    half3 color = 1; half alpha = 1; float edge = 1;
    float3 wPos = input.positionWS;
    //half3 viewDirWS = _WorldSpaceCameraPos.xyz - wPos;
    float3 positionSS = input.positionNDC.xyz / input.positionNDC.w;
    float2 uv = GetSourceUV(input.uv.xy, input.positionWS.xz, _WorldSpaceUV);
    float2 uv1 = GetSourceUV(input.fuv.xy, input.positionWS.xz, _WorldSpaceUV);
    float2 uv2 = GetSourceUV(input.fuv.zw, input.positionWS.xz, _WorldSpaceUV);
    float2 flowMap = float2(1, 1);
    float vFace = 1.0;
    half slope = 0;
    //#if _RIVER
    //slope = GetSlopeInverse(input.normalWS);
    //return float4(slope, slope, slope, 1);
    //#endif
    float depth = SampleSceneDepth(positionSS.xy);
	half mask = 1;
#if _CHPFOAM || _RIVER
	float sceneZ = LinearEyeDepth(depth, _ZBufferParams);
	float thisZ = input.positionNDC.z;
	edge = (sceneZ - thisZ);
	float2 nUV = float2(uv.x, uv.y);
	mask = saturate(SAMPLE_TEXTURE2D(_IntersectionNoise, sampler_IntersectionNoise, nUV * _MaskFlow.z*0.01 + _MaskFlow.w).b * _MaskFlow.x + _MaskFlow.y);
#else
    color = input.vColor.rgb;
    edge  = input.vColor.a;
#endif

	#if _DEBUGRIVERMASK
		return half4(mask, mask, mask, 1);
	#endif
    
	color = _WaterColor.rgb;
    
    //float foamEdge = saturate(lerp(0, 10, edge));
	//foamEdge = 1 - foamEdge;
	//foamEdge = step(0.1, foamEdge);

    float3 normalWS = input.normalWS.xyz;
    float3 viewDirWS = normalize(half3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w));
    float3 NormalsCombined = float3(0.5, 0.5, 1);    
    float3 viewDirNorm = normalize(viewDirWS);
    //half VdotN = 1.0 - saturate(dot(viewDirNorm, normalWS));                    
    float3 viewDir = (_WorldSpaceCameraPos - wPos);
    
    Surface surface = (Surface)0;    
    surface.position = input.positionWSAndFog.xyz;   
	
    float fresnel = 1 - max(0, dot(normalWS, viewDirWS));    
    fresnel = PositivePow(fresnel, _FresnelPower);    


        
    //float waterDensity = 1;
    //float opaqueDist = 1;    
    float edgeFade = saturate(edge / (_EdgeFade*0.01));        
    float opaqueDist = length(edge * normalWS);   
    float distanceAttenuation = 1.0 - exp(-edge * _DepthVertical * lerp(0.1, 0.01, _AnimationParams.w));
    float heightAttenuation = saturate(lerp(opaqueDist * _DepthHorizontal, 1.0 - exp(-opaqueDist * _DepthHorizontal), _DepthExp));    
    float waterDensity = max(distanceAttenuation, heightAttenuation);
    half4 baseColor = lerp(_WaterColorNear, _WaterColor, waterDensity);
    color.rgb = baseColor.rgb;
    float temp = smoothstep(0,0.1,edge);
    alpha = baseColor.a * edgeFade * temp;

	//return half4(edge,edge,edge,1);
      
    float intersection = 0;
    float interSecGradient = 1-saturate(exp(edge) / _waveEdgeLength);
    //return float4(interSecGradient,interSecGradient,interSecGradient,1);      
    if (_IntersectionSource == 1) interSecGradient = input.vColor.r;
    if (_IntersectionSource == 2) interSecGradient = saturate(interSecGradient + input.vColor.r);
    
    #if _RIVER
	  
        float intersectionnoise1 = SAMPLE_TEXTURE2D(_IntersectionNoise, sampler_IntersectionNoise, uv1 * _IntersectionTiling*0.01).g;           
        float move = TIME.x * _IntersectionSpeed - interSecGradient;
		//return half4(edge,edge,edge,1);
        float intersectionUV1 = frac(edge +move  + intersectionnoise1 * _IntersectionRippleStrength * 0.5) / _waveFalloff;
        float texintersection = SAMPLE_TEXTURE2D(_IntersectionNoise, sampler_IntersectionNoise, intersectionUV1 * _IntersectionFalloff).r;
        //return float4(texintersection, texintersection, texintersection, 1);

	    float foamV = saturate(1- edge * _IntersectionRippleDist);        
		float foamPart = saturate(1.2 * foamV * _IntersectionRippleStrength );
		half intersectionnoise2 = SAMPLE_TEXTURE2D(_IntersectionNoise, sampler_IntersectionNoise, uv2 * _IntersectionTiling).g;
		half3 bubble = foamPart * intersectionnoise1 * intersectionnoise2;
        _IntersectionColor.rgb = (texintersection * mask + bubble) * _IntersectionColor.rgb;   
        color.rgb = lerp(color.rgb, _IntersectionColor.rgb, foamPart);
        alpha = saturate(alpha + foamPart * _IntersectionColor.a);
        alpha *= edge < 0.1? edge * 10 : 1;
        //return float4(color, alpha);
    #endif


    
    //FOAM
    float foam = 0;
    #if _FOAM
    
    #if _ENABLE_DEPTH_TEXTURE
    float foamMask = lerp(1, 2, _FoamWaveMask);
	foamMask = foamMask * _FoamWaveMaskExp * 0.75;
    #else
    float foamMask = 1;
    #endif
    
    foam = SampleFoam(uv * _FoamTiling, TIME, flowMap, _FoamSize, foamMask);
    foam *= saturate(_FoamColor.a) * edgeFade * temp;
    
    color.rgb = lerp(color.rgb, _FoamColor.rgb, foam);   
    #endif

    alpha = saturate(alpha + intersection + foam);
    
       

#if _CAUSTICS
    float3 caustics = SampleCaustics(wPos.xz + lerp(normalWS.xz, NormalsCombined.xz, _CausticsDistortion), TIME * _CausticsSpeed, _CausticsTiling) * _CausticsBrightness;  
        //return float4(caustics, caustics, caustics, 1);
        //caustics *=_MainColor.rgb;
        float causticsMask = waterDensity;        
        causticsMask = saturate(causticsMask + intersection * temp * edgeFade * edgeFade);              
        color = lerp(color + caustics, color, causticsMask);
#endif
    
#if _EDGEFOAM
    float3 recipObjScale = float3( length(unity_WorldToObject[0].xyz), length(unity_WorldToObject[1].xyz), length(unity_WorldToObject[2].xyz) );
    float3 objScale = 1.0/recipObjScale;
    float2 tilingfloat = float2(0.5,0.5);
    float2 tilingnoise = ((input.uv.xy - tilingfloat.xy) + tilingfloat.xy);
    float2 division = ((objScale.rb*_EdgeFoamTiling)*5);               
    float3 foammove = (float3((_EdgeFoamSpeed / division),0.0) * _Time.x);
    float2 edgemove = ((tilingnoise+foammove.xy) * division);
    float4 edgefoamtexture = SAMPLE_TEXTURE2D(_EdgeFoamTexture, sampler_EdgeFoamTexture, edgemove);               
    float edgefoamdepth = saturate(edge/_EdgeFoamBlend) * -1.0 + 1.0;   
    float3 edgecolor = (edgefoamdepth*(((((dot(edgefoamtexture.rgb,float3(0.3,0.59,0.11)) - _EdgeFoamContrast))) * _EdgeFoamColor.rgb) * (_EdgeFoamIntensity * -1.0)));
    float3 edgefoamarea = lerp(0,edgecolor,_EdgeFoamVisibility);    
    color.rgb = lerp(color.rgb, 2 + edgecolor.rgb, edgefoamarea);
    //alpha += edgecolor;

#endif
    
    //color = saturate(max(0.1, color));
    color = max(0.01, color);
    color =saturate( lerp(color.rgb, _WaterColorFar.rgb, fresnel * _WaterColorFar.a));  
	
#if _CHPFOAM
	half4 finalCol = CHPFoamCol(color.rgb,alpha,edge,input.uv.xy,mask);
	color = finalCol.rgb;
	alpha = finalCol.a;
#endif
    //BIOUM_APPLY_BUILTIN_FOG(input.positionWSAndFog.w, color);  
	color = MixXYJFogColor(color, input.positionWSAndFog.w);
	
    return float4(color, alpha);
    
    
}

#endif // BIOUM_SCENE_WATER_PASS_INCLUDE