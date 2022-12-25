		
Varyings vert( Attributes input)
{
	Varyings output = (Varyings)0;
				
	//setting value to unused interpolator channels and avoid initialization warnings

	#if TERRAIN_2TEX
		output.uv01.xy = input.texcoord.xy * _SplatScale.x;
		output.uv01.zw = input.texcoord.xy * _SplatScale.y;
	#elif TERRAIN_3TEX
		output.uv01.xy = input.texcoord.xy * _SplatScale.x;
		output.uv01.zw = input.texcoord.xy * _SplatScale.y;
		output.uv23.xy = input.texcoord.xy * _SplatScale.z;
	#elif TERRAIN_4TEX
		output.uv01.xy = input.texcoord.xy * _SplatScale.x;
		output.uv01.zw = input.texcoord.xy * _SplatScale.y;
		output.uv23.xy = input.texcoord.xy * _SplatScale.z;
		output.uv23.zw = input.texcoord.xy * _SplatScale.w;
	#endif
	output.uvControlandVertexColR.xy = input.texcoord.xy;

	half3 viewDirWS = _WorldSpaceCameraPos.xyz - output.positionWSAndFog.xyz;
	#if _NORMALMAP
		VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
		output.tangentWS = half4(normalInput.tangentWS, viewDirWS.x);
		output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.y);
		output.normalWS = half4(normalInput.normalWS, viewDirWS.z);
	#else
		output.normalWS = TransformObjectToWorldNormal(input.normalOS);
		output.viewDirWS = viewDirWS;
	#endif

	output.positionWSAndFog.xyz = TransformObjectToWorld(input.positionOS.xyz);


    OUTPUT_GI_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_GI_SH(output.normalWS.xyz, output.vertexSH);
	OUTPUT_VERTEX_LIGHTING(output.normalWS.xyz, output.positionWSAndFog.xyz, output.vertexLighting);


	#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
	output.screenPos = ComputeScreenPos(positionCS);
	#endif

	output.positionCS = TransformWorldToHClip(output.positionWSAndFog.xyz);

	output.positionWSAndFog.w = ComputeXYJFogFactor(ComputeScreenPos(output.positionCS / output.positionCS.w).xy, output.positionWSAndFog.y);
	#if _MAIN_LIGHT_SHADOWS
		output.shadowCoord = TransformWorldToShadowCoord(output.positionWSAndFog.xyz);
	#endif

	#if _VERTEXAO_ON
	   output.uvControlandVertexColR.z = 1-saturate((1-input.color.r) * _AOStrength);
    #endif

	return output;
}
			

half4 frag ( Varyings input ) : SV_Target
{
	half4 control = SAMPLE_TEXTURE2D(_Control, sampler_Control,input.uvControlandVertexColR.xy);
	half4 albedo = 0;
	#if TERRAIN_2TEX
		half4 splat0 = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, input.uv01.xy);
		half4 splat1 = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat1, input.uv01.zw);
		albedo = splat0 * control.r + splat1 * control.g;
	#elif TERRAIN_2TEX
		half4 splat0 = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, input.uv01.xy);
		half4 splat1 = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat1, input.uv01.zw);
		half4 splat2 = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat2, input.uv23.xy);
		albedo = splat0 * control.r + splat1 * control.g + splat2 * control.b;
	#else
		half4 splat0 = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, input.uv01.xy);
		half4 splat1 = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat1, input.uv01.zw);
		half4 splat2 = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat2, input.uv23.xy);
		half4 splat3 = SAMPLE_TEXTURE2D(_Splat3, sampler_Splat3, input.uv23.zw);
		albedo = splat0 * control.r + splat1 * control.g + splat2 * control.b + splat3 * control.a;
	#endif
	albedo.rgb = ColorSpaceConvertInput(albedo.rgb);
#ifdef _TERRAIN_BLEND
	//return half4(albedo.rgb, 1);
#endif
#if _NORMALMAP
    half3 normalTS = 0;

    #if TERRAIN_2TEX
        normalTS += sampleNormalMap(_Normal0, input.uv01.xy, _NormalScale.x) * control.r;
        normalTS += sampleNormalMap(_Normal1, input.uv01.zw, _NormalScale.y) * control.g;
    #elif TERRAIN_3TEX
        normalTS += sampleNormalMap(_Normal0, input.uv01.xy, _NormalScale.x) * control.r;
        normalTS += sampleNormalMap(_Normal1, input.uv01.zw, _NormalScale.y) * control.g;
        normalTS += sampleNormalMap(_Normal2, input.uv23.xy, _NormalScale.z) * control.b;
    #elif TERRAIN_4TEX
        normalTS += sampleNormalMap(_Normal0, input.uv01.xy, _NormalScale.x) * control.r;
        normalTS += sampleNormalMap(_Normal1, input.uv01.zw, _NormalScale.y) * control.g;
        normalTS += sampleNormalMap(_Normal2, input.uv23.xy, _NormalScale.z) * control.b;
        normalTS += sampleNormalMap(_Normal3, input.uv23.zw, _NormalScale.w) * control.a;
    #endif
    normalTS = SafeNormalize(normalTS);
    half3x3 TBN = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    half3 normalWS = mul(normalTS, TBN);
    half3 viewDirWS = half3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
#else
    half3 normalWS = input.normalWS;
    half3 viewDirWS = input.viewDirWS;
#endif
				  
	//half4 emissiveAO = half4(GetEmissiveColor(), 1);
	//surface.occlusion = emissiveAO.a;

	Surface surface = (Surface)0;
    surface.albedo.rgb = albedo.rgb;
    surface.normal = SafeNormalize(normalWS);
    surface.view = SafeNormalize(viewDirWS);
    surface.occlusion = 1;
    surface.position = input.positionWSAndFog.xyz;
	surface.penumbraTint = _PenumbraTintColor.xyz;


	SubSurface sss = (SubSurface)0;
    sss.color = half3(0,0,0);
    sss.doToneMapping = false;
    sss.normal = input.normalWS.xyz;


	#if LIGHTMODEL_LAMBERT
		GI gi = GET_SIMPLE_GI(input.lightmapUV, input.vertexSH);
	#if _MAIN_LIGHT_SHADOWS
		float4 shadowCoord = input.shadowCoord;
	#else
		float4 shadowCoord = 0;
	#endif
		VertexData vertexData = (VertexData)0;
        vertexData.lighting = GET_VERTEX_LIGHTING(input.vertexLighting);
        vertexData.shadowCoord = GET_SHADOW_COORD(input.shadowCoord, surface.position);

		Light mainLight = GetMainLight(surface.position, vertexData.shadowCoord, gi);
		//mainLight.shadowAttenuation = saturate(dot(surface.normal,mainLight.direction));
        half3 color = LightingLambert(surface, sss,vertexData, gi, mainLight);
	#else
		half3 color = surface.albedo.rgb;
	#endif


	#if _VERTEXAO_ON
	    half ao = 1-input.uvControlandVertexColR.z;
	    color.rgb = lerp(color.rgb, _VertexAOCol.rgb * color.rgb * _AOColStrength, ao);
	#endif

	#ifdef _TERRAIN_BLEND
		return half4(color.rgb, 1);
	#endif
	color = MixXYJFogColor(color, input.positionWSAndFog.w);


	return half4(color.rgb,1);
}