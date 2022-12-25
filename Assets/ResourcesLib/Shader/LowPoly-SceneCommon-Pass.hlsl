#ifndef LOWPOLY_SCENE_COMMON_PASS_INCLUDE
#define LOWPOLY_SCENE_COMMON_PASS_INCLUDE

#include "ShaderLibrary/SurfaceStruct.hlsl"
#include "ShaderLibrary/LightingCommon.hlsl"
#include "ShaderLibrary/Fog.hlsl"

struct appdata
{
	float4 positionOS : POSITION;
	half3 normalOS : NORMAL;
	half4 tangentOS : TANGENT;
	half2 texcoord : TEXCOORD0;
	half2 lightmapUV : TEXCOORD1;
	half4 VColor : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2fBase
{
	float4 VertexColor : COLOR0;
	float4 positionCS : SV_POSITION;
    half4 baseAndLMUV : TEXCOORD0;
    half4 positionWSAndFog : TEXCOORD1;

#if defined(ENABLE_NORMALMAP)
	// xyz: tbn  www: viewDir
	half4 tangentWS : TEXCOORD2;
	half4 binormalWS : TEXCOORD3;
	half4 normalWS : TEXCOORD4;
#else
	half3 normalWS : TEXCOORD2;
	half3 viewDirWS : TEXCOORD3;
#endif
	float4 diffuseUVAndMatCapCoords : TEXCOORD5;
	float3 worldSpaceReflectionVector : TEXCOORD6;
	float4 screenPos : TEXCOORD7;
	BIOUM_BUILTIN_FOG_COORDS(8)	
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

half4 _WindParam;

v2fBase ForwardBaseVert (appdata v)
{
	v2fBase o = (v2fBase)0;
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);
	o.VertexColor = v.VColor;
	float4 positionWS = mul(UNITY_MATRIX_M, v.positionOS);
#if _MATCAP	
	o.diffuseUVAndMatCapCoords.z = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(v.normalOS));
	o.diffuseUVAndMatCapCoords.w = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(v.normalOS));	
	o.diffuseUVAndMatCapCoords.zw = o.diffuseUVAndMatCapCoords.zw * 0.5 + 0.5;
#endif
	o.positionWSAndFog.xyz = positionWS.xyz;
#if _WIND
	float2 direction = _WindParam.xy/6;
	float scale = _WindParam.z/6;
	float speed = _WindParam.w/6;
	float2 wave = PlantsAnimationNoise(positionWS.xyz, direction, scale, speed);
	positionWS.xyz.xz += wave * o.VertexColor.r;
#endif
	o.positionCS = mul(UNITY_MATRIX_VP, positionWS);
	o.screenPos.xyzw = ComputeScreenPos(o.positionCS);
    half2 baseUV = GetBaseUV(v.texcoord);
    o.baseAndLMUV = half4(baseUV, v.lightmapUV);
	
	half3 viewDirWS = _WorldSpaceCameraPos - positionWS.xyz;
	#if defined(ENABLE_NORMALMAP)
		TBN tbn = GetTBN(v.normalOS, v.tangentOS);
		o.tangentWS = half4(tbn.tangentWS, viewDirWS.x);
		o.binormalWS = half4(tbn.binormalWS, viewDirWS.y);
		o.normalWS = half4(tbn.normalWS, viewDirWS.z);
	#else
		o.normalWS = TransformObjectToWorldNormal(v.normalOS);
		o.viewDirWS = viewDirWS;
		o.worldSpaceReflectionVector = reflect(normalize(positionWS.xyz - _WorldSpaceCameraPos.xyz), o.normalWS);
		//float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.positionWS.xyz);
	#endif
		//o.VertexColor = v.VColor;

	float fogFactor = o.positionCS.z;
    o.positionWSAndFog.w = fogFactor;
    // URP UPGRADE COMMENT: COMPUTE_SHADOWCOORD(o.shadowCoord, positionWS, o.positionCS);
	return o;
}
	
half4 ForwardBaseFrag (v2fBase i) : SV_TARGET
{
	UNITY_SETUP_INSTANCE_ID(i);
	// URP UPGRADE COMMENT: ClipLOD(i.positionCS.xy, unity_LODFade.x);

	
	half4 baseMap = sampleBaseMap(i.baseAndLMUV.xy);
 	#if ENABLE_ALPHATEST
        half cutout = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff);
		clip(baseMap.a - cutout);
	#endif

	half3 normalWS, viewDirWS;
	#if defined(ENABLE_NORMALMAP)
		half3 normalMap = GetNormalMap(i.baseAndLMUV.xy);
		half3x3 TBN = half3x3(i.tangentWS.xyz, i.binormalWS.xyz, i.normalWS.xyz);
		normalWS = TransformTangentToWorld(normalMap, TBN);
		viewDirWS = half3(i.tangentWS.w, i.binormalWS.w, i.normalWS.w);
	#else
		normalWS = i.normalWS;
		viewDirWS = i.viewDirWS;
	#endif

	half4 maes = GetMAES(i.baseAndLMUV.zw);
    half4 lightmap = GetLightMap(i.baseAndLMUV.zw);
	half4 addtiontex = GetAddtionTex(i.baseAndLMUV.zw);
	half3 addtioncolor = GetAddtionColor();
	Surface surface = (Surface)0;
	//surface.color.rgb = baseMap.rgb * (_MainColor*1.1);
	surface.albedo.rgb = lerp(baseMap.rgb, addtioncolor.rgb, saturate(addtiontex.r*UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _AddtionStrength)));
	surface.normal = normalize(normalWS);	
	surface.view = normalize(viewDirWS);
	surface.position = i.positionWSAndFog.xyz;
	surface.occlusion = lightmap.a;	

	surface.albedo.a = baseMap.a;
    half alpha = surface.albedo.a * i.VertexColor.a;
	//BRDF brdf = GetBRDF(surface, alpha);
    GI gi = (GI)0;
    half lum = dot(lightmap.rgb, half3(0.213, 0.715, 0.072));
    lum = pow(abs(lum), 0.75);
    lum *= 4.59;
    gi.diffuse = lightmap.rgb *lum;
	float emiFactor = 1; 	
	#if _EMI
			
		half3 emiColor = GetEmission() * maes.r * baseMap.rgb;	
		half3 color = GetLightingWithLightmap(surface, gi, lerp(0, emiColor, emiFactor));
	#else
		half3 color = GetLightingWithLightmap(surface, gi);
	#endif

	half4 masktex = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, i.baseAndLMUV.xy);
#if _MATCAP	
	half mixLerp = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MixLerp);
	half matStrength = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MatStrength);
	float3 matCapColor = SAMPLE_TEXTURE2D(_MatCap, sampler_MatCap, i.diffuseUVAndMatCapCoords.zw).rgb * matStrength;
	//float3 matcolor = color * matCapColor * 4 + color;
	float3 matcolor = lerp(color.rgb, color.rgb * matCapColor * 4,  mixLerp);		
	color = lerp(color, matcolor, masktex.r);
#endif

	half4 timeColor = _MainColor;
#if _REFSKY
	half skyTile = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SkyTile);
	half cloudSpeed = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CloudSpeed);
	half skyDistort = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SkyDistort);
	half skyStrength = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SkyStrength) * min(timeColor.x, min(timeColor.y, timeColor.z));
	
	i.screenPos.xy *= half2(1, 1.778) * skyTile;
	i.screenPos.xy /= i.screenPos.w;
	i.baseAndLMUV.zw = i.screenPos.xy;
	i.baseAndLMUV.z += frac(_Time.x * cloudSpeed);
#if defined(ENABLE_NORMALMAP)
	i.baseAndLMUV.zw += normalWS.xz * skyDistort;
#endif
	i.baseAndLMUV.zw += skyDistort;
	float4 sky = GetSKY(i.baseAndLMUV.zw);
#if _MATCAP	
	sky.a *= masktex.r * surface.normal.y;
	color = lerp(color, matcolor + sky.rgb*2, sky.a * skyStrength);	
#else
	sky.a *= surface.normal.y;
	color = lerp(color, color + sky.rgb*2, sky.a * skyStrength);
#endif
#endif
	
	BIOUM_APPLY_BUILTIN_FOG(i.positionWSAndFog.w, color);	
	return half4(color, alpha);
}
#endif // BIOUM_SCENE_COMMON_PASS_INCLUDE
