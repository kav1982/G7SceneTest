Shader "Bioum/Effect/Common2.0" 
{
	Properties 
	{
		_BaseMap ("Main Tex", 2D) = "white" {}
		_BaseMapContrast("_BaseMapContrast", Float) = 0
		_BaseColorIntensity ("_BaseColorIntensity", Float) = 1
		[HDR]_BaseColor("Color", Color) = (1,1,1,1)  
		[HDR]_BackColor("Color", Color) = (0.5, 0.5, 0.5, 1)  
		[ToggleUI] _UseSubTexture ("贴图2", Float) = 0
		_SubMap ("Secondary Tex", 2D) = "white" {}
		_SubMapContrast("_SubMapContrast", Float) = 0
		_SubColorIntensity ("_SubColorIntensity", Float) = 1
		[HDR]_SubColor("Color", Color) = (1,1,1,1)  
		[HDR]_BackSubColor("Color", Color) = (0.5, 0.5, 0.5, 1)  
		_TextureBlendMode("Tex Blend Mode", float) = 0
		_MainUVAni ("_MainUVAni", Vector) = (0,0,0,0)
		_SubUVAni ("_SubUVAni", Vector) = (0,0,0,0)
		_AlbedoUVAni ("_AlbedoUVAni", Vector) = (0,0,0,0)
		_TextureContrastParam ("_TextureContrastParam", Vector) = (0,0,0,0)
		_ColorIntensityParam ("_ColorIntensityParam", Vector) = (1,1,1,1)
		
		_BaseMapAlphaChannel ("_BaseMapAlphaChannel", Float) = 3
		_SubMapAlphaChannel ("_SubMapAlphaChannel", Float) = 3
		_BaseMapAlphaMask ("_BaseMapAlphaMask", Vector) = (0,0,0,1)
		_SubMapAlphaMask ("_SubMapAlphaMask", Vector) = (0,0,0,1)
		
		[ToggleUI] _UseDistort ("扭曲", Float) = 0
		[ToggleUI] _UseDistort1 ("扭曲", Float) = 0
		_DistortMap0 ("Distort Tex", 2D) = "grey" {}
		_DistortMap1 ("Secondary Dissolve Tex", 2D) = "grey" {}
		_Distort0Factor ("扭曲强度", Range(0,0.5) ) = 0.15
		_Distort1Factor ("扭曲强度", Range(0,0.5) ) = 0.15
		_DistortUVAni ("Distort Ani", Vector) = (0,0,0,0)
		_DistortParam ("_DistortParam", Vector) = (0,0,0,0)
		
		[ToggleUI]_ReceiveFog("_ReceiveFog", Float) = 0
		
		[ToggleUI] _UseMask ("遮罩", Float) = 0
		_MaskMap ("Mask Tex", 2D) = "white" {}
		_MaskRotationAngle("MaskRotationAngle",Float) = 0
		[ToggleUI] _MaskApplyDistort ("_MaskApplyDistort", Float) = 0
		[ToggleUI] _MaskAffectAlpha ("_MaskAffectAlpha", Float) = 0
		[ToggleUI] _MaskAffectDissolve ("_MaskAffectDissolve", Float) = 0
		[ToggleUI] _MaskAffectDisplacement ("_MaskAffectDisplacement", Float) = 0
		_MaskMapParam ("_MaskMapParam", Vector) = (0,0,0,0)
		
		[ToggleUI] _UseDisplacementMap ("置换贴图", Float) = 0
		_DisplacementMap ("_DisplacementMap", 2D) = "black" {}
		_DisplacementStrength ("_DisplacementStrength", float) = 0
		_DisplacementUVAni ("_DisplacementUVAni", Vector) = (0,0,0,0)
		_DisplacementParam ("_DisplacementParam", Vector) = (0,0,0,0)
		
		
        _Cutoff("cutoff", Range(0,1)) = 0.5
		
		
		[ToggleUI] _UseRim ("Rim", Float) = 0
		[ToggleUI] _RimInverse ("_RimInverse", Float) = 0
		_RimColorBlendMode ("_RimColorBlendMode", Float) = 0
		_RimAlphaBlendMode ("_RimAlphaBlendMode", Float) = 0
		_RimAlphaSource ("_RimApplyAlpha", Float) = 0
		_rimPower("Rim Power", Range(0.1,10)) = 5
		_rimEdge("_rimEdge", Range(0.01, 0.49)) = 0.2
		[HDR]_rimColor("rimColor", Color) = (1,1,1,1)  
		_RimParam0("_RimParam", Vector) = (0, 0, 0, 0)
		_RimParam1("_RimParam", Vector) = (0, 0, 0, 0)
		
		
		[ToggleUI] _UseDissolve ("Dissolve", Float) = 0
		_DissolveMap ("Dissolve Tex", 2D) = "white" {}
		_DissolveFactor("dissolve factor", Range(0,1.01)) = 0.5
		_DissolveEdge("dissolve Edge", Range(0,1)) = 0.1
		_DissolveSoft("dissolve Soft", Range(0.01, 0.49)) = 0.2
		_DissolveEdgeSoft("_DissolveEdgeSoft", Range(0.01, 0.49)) = 0.2
		[HDR]_DissolveEdgeColor("dissolve Edge Color", color) = (1,1,1,1)
		_DissolveEdgeMode ("Dissolve Mode", float) = 0
		_DissolveAni ("_DissolveAni", vector) = (0,0,0,0)
		_DissolveParam ("_DissolveParam", vector) = (0,0,0,0)
		
		
		[ToggleUI] _UseParticleCustomData ("is particle", Float) = 0
		[ToggleUI] _UseFog ("_UseFog", Float) = 0
		_FogIntensity ("_FogIntensity", range(0, 1)) = 1
		_FogParam ("_FogIntensity", vector) = (0,0,0,0)
		
		[ToggleUI] _UseEdgeContact ("EdgeContact", Float) = 0
		_EdgeContactFade ("_EdgeContactFar", float) = 1
		_EdgeContactMode ("_EdgeContactMode", float) = 0
		[HDR]_EdgeContactColor ("_EdgeContactColor", color) = (1,1,1,1)
		
		[ToggleUI] _UseLighting ("_UseLighting", Float) = 0

		[ToggleUI] _TowardCamera ("_TowardCamera", Float) = 0
		
		[ToggleUI]_BaseMapUVSource("_BaseMapUVSource", Float) = 0
		[ToggleUI]_BaseMapUVAniSource("_BaseMapUVAniSource", Float) = 0
		[ToggleUI]_SubMapUVSource("_SubMapUVSource", Float) = 0
		[ToggleUI]_DistortMap0UVSource("_DistortMap0UVSource", Float) = 0
		[ToggleUI]_DistortMap1UVSource("_DistortMap1UVSource", Float) = 0
		_UVSourceParam0 ("_UVSourceParam0", Vector) = (0,0,0,0)
		
		[ToggleUI]_MaskMapUVSource("_MaskMapUVSource", Float) = 0
		[ToggleUI]_DisplacementMapUVSource("_DisplacementMapUVSource", Float) = 0
		[ToggleUI]_DissolveMapUVSource("_DissolveMapUVSource", Float) = 0
		_UVSourceParam1 ("_UVSourceParam1", Vector) = (0,0,0,0)
		
		[HideInInspector] _SrcBlend ("__src", Float) = 1
		[HideInInspector] _DstBlend ("__dst", Float) = 10
		[HideInInspector] _CullMode ("__CullMode", Float) = 0
		[HideInInspector] _Cull ("__Cull", Float) = 2
		
		[HideInInspector][ToggleUI] _OverlayRender ("_OverlayRender", Float) = 0
		[HideInInspector] _BlendMode ("__BlendMode", Float) = 0
		[HideInInspector] _ZWrite ("__ZWrite", Float) = 0
		[HideInInspector][ToggleUI] _ZTestAlways ("_ZTestAlways", Float) = 0
		[HideInInspector] _ZTest ("_ZTest", Float) = 4
		[HideInInspector] _CustomQueueOffset ("_CustomQueueOffset", Range(-50, 50)) = 0
		[HideInInspector][ToggleUI] _TransparentZWrite ("_TransparentZWrite", float) = 0
		[HideInInspector][ToggleUI] _IsUIEffect ("_IsUIEffect", float) = 0
		
		_ClipMinMax ("Clip Min Max", vector) = (-1000, 1000, -1000, 1000)
		_ClipToggle ("Clip Toggle", float) = 0

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
	}
	
	HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	    #include "../ShaderLibrary/Fog.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	

		half GetAlpha(half4 t, half4 mask)
		{
			return dot(t, mask);
		}

		half Get2DClipping (float2 position, float4 clipRect)
		{
			half4 clipArea = step(half4(clipRect.xy, position), half4(position, clipRect.zw));
			return min(min(min(clipArea.x, clipArea.y), clipArea.z), clipArea.w);
		}

		float2 rotate(float2 uv, float angle)
		{
			float a = angle / 180 * PI;
			float2 pivot = float2(0.5, 0.5);
			float cosAngle = cos(a);
			float sinAngle = sin(a);
			float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
			uv = mul(rot,uv - pivot) + pivot;
			return uv;
		}
	ENDHLSL
	
	SubShader 
	{
		Tags {"IgnoreProjector"="True" "Queue"="Transparent" "RenderType"="Transparent" "PreviewType"="Plane"}
		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
		}
		Pass 
		{
			Name "EffectCommon"
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite] ZTest[_ZTest]
			Cull [_Cull]
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma target 2.0
			#pragma shader_feature_local _ _SUB_TEXTURE
			#pragma shader_feature_local _ _SINGLE_TEX_DISTORT _DOUBLE_TEX_DISTORT
			#pragma shader_feature_local _ _MASK
			#pragma shader_feature_local _ _RIM
			#pragma shader_feature_local _ _DISSOLVE
			#pragma shader_feature_local _ _EDGE_CONTACT
			#pragma shader_feature_local _ _DISPLACEMENT
			//#pragma shader_feature_local _ _USE_FOG
			#pragma shader_feature_local _ _APPLY_LIGHTING
			#pragma shader_feature_local _ _TOWARDSCAMERA
			#pragma shader_feature_local _ _RECEIVEFOG
			
			#pragma shader_feature_local _ _UI_EFFECT
			#pragma multi_compile _ NEED_GAMMA

			//#pragma multi_compile_fog
			//#pragma multi_compile _ _UI_CLIP
			//#pragma multi_compile _ _DAY_NIGHT_SYSTEM

			TEXTURE2D(_BaseMap);				
            TEXTURE2D(_SubMap);
            TEXTURE2D(_DistortMap0); 
            TEXTURE2D(_DistortMap1);
            TEXTURE2D(_MaskMap);
            TEXTURE2D(_DissolveMap);
			TEXTURE2D(_DisplacementMap);
			// SAMPLER(sampler_BaseMap);
			// SAMPLER(sampler_SubMap);
			// SAMPLER(sampler_DistortMap0);
			// SAMPLER(sampler_DistortMap1);
			// SAMPLER(sampler_MaskMap);
			// SAMPLER(sampler_DissolveMap);
			// SAMPLER(sampler_DisplacementMap);
			SAMPLER(Sampler_LinearRepeat);
			SAMPLER(Sampler_LinearClamp);
			SAMPLER(sampler_MaskMap);
			SAMPLER(sampler_BaseMap);
			SAMPLER(sampler_SubMap);
			
            CBUFFER_START(UnityPerMaterial)
			half4 _BaseColor;
			half4 _BackColor;
			half4 _BaseMap_ST;
			half4 _AlbedoUVAni;

			half4 _BaseMapAlphaMask;
			half4 _SubMapAlphaMask;

			half4 _UVSourceParam0;
			half4 _UVSourceParam1;
			
			half4 _SubMap_ST;
			half4 _SubColor;
			half4 _BackSubColor;

			half4 _rimColor;
			half4 _RimParam0;
			half4 _RimParam1;

            half4 _DistortMap0_ST;
            half4 _DistortMap1_ST;
            half4 _DistortUVAni;
		    // half _Distort0Factor;
		    // half _Distort1Factor;
			// int _MaskApplyDistort;
			half4 _DistortParam;
		
			half4 _MaskMap_ST;

            half4 _DissolveMap_ST;
            half4 _DissolveMaskMap_ST;
            // half _DissolveFactor;
            // half _DissolveEdge;
            // half _DissolveSoft;
			// int _DissolveEdgeMode;
			half4 _DissolveParam;
            half4 _DissolveEdgeColor;
			half4 _DissolveAni;
		
			// half _FogIntensity;
			// half _UseFog;
			// half _Cutoff;
			// int _UseParticleCustomData;
			half4 _FogParam;

			//float4 _ClipRect;
			
			half4 _EdgeContactColor;

			half4 _DisplacementParam;
			half4 _DisplacementMap_ST;

			half _MaskRotationAngle;
			half4 _MaskMapParam;

			float4 _ClipMinMax;
			int _ClipToggle;

			int _BlendMode;
			int _TextureBlendMode;

            CBUFFER_END
			
			#define _DissolveFactor _DissolveParam.x
			#define _DissolveEdge _DissolveParam.y
			#define _DissolveSoft _DissolveParam.z
			#define _DissolveEdgeSoft _DissolveParam.w

			#define _UseFog _FogParam.x
			#define _FogIntensity _FogParam.y
			#define _Cutoff _FogParam.z
			#define _UseParticleCustomData _FogParam.w
			
			#define _Distort0Factor _DistortParam.x
			#define _Distort1Factor _DistortParam.y
			#define _MaskApplyDistort _DistortParam.z

			#define _RimAlphaSource _RimParam0.x
			#define _RimInverse _RimParam0.y
			#define _RimPower _RimParam0.z
			#define _RimEdge _RimParam0.w
			
			#define _RimColorBlendMode _RimParam1.x
			#define _RimAlphaBlendMode _RimParam1.y
			
			#define _EdgeContactFade abs(_EdgeContactColor.a)
			#define _EdgeContactMode _EdgeContactColor.a
			
			#define _DisplacementUVAni _DisplacementParam.xy
			#define _DisplacementStrength _DisplacementParam.z
			
			#define _BaseMapUVSource _UVSourceParam0.x
			#define _SubMapUVSource _UVSourceParam0.y
			#define _DistortMap0UVSource _UVSourceParam0.z
			#define _DistortMap1UVSource _UVSourceParam0.w
			
			#define _MaskMapUVSource _UVSourceParam1.x
			#define _DisplacementMapUVSource _UVSourceParam1.y
			#define _DissolveMapUVSource _UVSourceParam1.z
			#define _BaseMapUVAniSource _UVSourceParam1.w
			
			#define _MaskAffectAlpha _MaskMapParam.x
			#define _MaskAffectDissolve _MaskMapParam.y
			#define _MaskAffectDisplacement _MaskMapParam.z
			
			struct VertexInput 
			{
				float3 positionOS : POSITION;
				half4 texcoord : TEXCOORD0;
				//half4 texcoord1 : TEXCOORD1;
				half4 vertexColor : COLOR;
            	
			#if _RIM || _APPLY_LIGHTING || _DISPLACEMENT
				half3 normalOS : NORMAL;
			#endif
            	
				//粒子系统自定义数据 
				half4 CustomData0 : TEXCOORD1; 
				half4 CustomData1 : TEXCOORD2;
			};
			
			struct v2f 
			{
				float4 positionCS : SV_POSITION;
				float4 mainUV : TEXCOORD0;
			#if _MASK || _DISSOLVE
				half4 maskAndDissolveUV : TEXCOORD1;
			#endif
			#if _SINGLE_TEX_DISTORT || _DOUBLE_TEX_DISTORT
				half4 distortUV : TEXCOORD2;
			#endif
			#if _RIM || _APPLY_LIGHTING
				float3 normalWS :TEXCOORD3;
				float3 viewDirWS :TEXCOORD4;
			#endif
				half4 particleColor : COLOR;
				half4 CustomData1 : TEXCOORD5;
				float4 positionWSAndFog : TEXCOORD6;
			#if _APPLY_LIGHTING
				half3 lighting : TEXCOORD7;
			#endif
			#if _EDGE_CONTACT
				float4 positionNDC : TEXCOORD8;
			#endif
			};
			
			v2f vert (VertexInput input) 
			{
				v2f output = (v2f)0;

			#if _TOWARDSCAMERA
                float3 newZ = TransformWorldToObject(GetCameraPositionWS());
                newZ = -normalize(newZ);
                float3 newX = abs(newZ.y)<0.99?cross(float3(0,1,0),newZ):cross(newZ,float3(0,0,1));
                newX = normalize(newX);
                float3 newY = cross(newZ, newX);
                newY = normalize(newY);
               
                input.positionOS = newX * input.positionOS.x + newY * input.positionOS.y + newZ * input.positionOS.z;
			#endif

				half2 uv0 = input.texcoord.xy;
				half2 uv1 = _UseParticleCustomData != 0 ? input.texcoord.zw : input.CustomData0.xy;
				
				half2 baseUVSource = _BaseMapUVSource == 0 ? uv0 : uv1;
				half2 subUVSource = _SubMapUVSource == 0 ? uv0 : uv1;
				output.mainUV = half4(baseUVSource, subUVSource) * half4(_BaseMap_ST.xy, _SubMap_ST.xy);

				half4 customData2 = 0;
				if(_UseParticleCustomData != 0)
				{
					half4 customData1 = input.CustomData0;
					customData2 = input.CustomData1;
					output.CustomData1 = customData1;

					float2 baseUVAni = _BaseMapUVAniSource == 0 ? _AlbedoUVAni.xy * _Time.y + _BaseMap_ST.zw : customData2.xy;
					output.mainUV += float4(baseUVAni, _AlbedoUVAni.zw * _Time.y);
				}
				else
				{
					customData2.z = _DisplacementStrength;
					output.CustomData1 = half4(_DissolveFactor, _DissolveEdge, _Distort0Factor, _Distort1Factor);
					output.mainUV += half4(_BaseMap_ST.zw, _SubMap_ST.zw);
					output.mainUV += float4(_AlbedoUVAni * _Time.y);
				}

			#if _MASK || _DISSOLVE
				half2 maskUVSource = _MaskMapUVSource == 0 ? uv0 : uv1;
				half2 dissolveUVSource = _DissolveMapUVSource == 0 ? uv0 : uv1;
                output.maskAndDissolveUV = half4(maskUVSource, dissolveUVSource) * half4(_MaskMap_ST.xy, _DissolveMap_ST.xy);
                output.maskAndDissolveUV += half4(_MaskMap_ST.zw, _DissolveMap_ST.zw + frac(_DissolveAni.xy * _Time.y));
			#endif

			
			#if _DISPLACEMENT
				half mask = 1;
				#if _MASK
					mask = _MaskAffectDisplacement != 0 ?
						SAMPLE_TEXTURE2D_LOD(_MaskMap, sampler_MaskMap, output.maskAndDissolveUV.xy, 0).x :
						1;
				#endif
				float2 displacementUV = _DisplacementMapUVSource == 0 ? uv0 : uv1;
				displacementUV = displacementUV * _DisplacementMap_ST.xy + _DisplacementMap_ST.zw;
				displacementUV += frac(_DisplacementUVAni * _Time.y);
				float displacement = SAMPLE_TEXTURE2D_LOD(_DisplacementMap, Sampler_LinearRepeat, displacementUV, 1).x;
				input.positionOS.xyz += displacement * input.normalOS * customData2.z * mask;
			#endif
				
			#if _EDGE_CONTACT
				VertexPositionInputs inputs = GetVertexPositionInputs(input.positionOS);
				output.positionNDC = inputs.positionNDC;
				output.positionNDC.z = -inputs.positionVS.z;
				float3 positionWS = inputs.positionWS;
				output.positionCS = inputs.positionCS;
			#else
				float3 positionWS = TransformObjectToWorld(input.positionOS);
				output.positionCS = TransformWorldToHClip(positionWS);
			#endif

				output.positionWSAndFog.xyz = positionWS;				
								
			#if _SINGLE_TEX_DISTORT || _DOUBLE_TEX_DISTORT
				half2 distort0UVSource = _DistortMap0UVSource == 0 ? uv0 : uv1;
				half2 distort1UVSource = _DistortMap1UVSource == 0 ? uv0 : uv1;
                output.distortUV = half4(distort0UVSource, distort1UVSource) * half4(_DistortMap0_ST.xy, _DistortMap1_ST.xy);
                output.distortUV += half4(_DistortMap0_ST.zw, _DistortMap1_ST.zw);
                output.distortUV += frac(half4(_DistortUVAni * _Time.y));
			#endif
				
			#if _RIM || _APPLY_LIGHTING
				half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
			#endif

			#if _RIM
				output.normalWS = normalWS;
				output.viewDirWS = unity_OrthoParams.w != 0 ? half3(0,0,1) : _WorldSpaceCameraPos.xyz - positionWS.xyz;
			#endif
				
				output.particleColor = input.vertexColor;

			#if _RECEIVEFOG
				output.positionWSAndFog.w = ComputeXYJFogFactor(ComputeScreenPos(output.positionCS / output.positionCS.w).xy, positionWS.y);
			#endif

			#if _APPLY_LIGHTING
				half3 lightDirection = _MainLightPosition.xyz;
				half3 lightColor = _MainLightColor.rgb;
				half3 lambert = max(0, dot(normalWS, lightDirection)) * lightColor;
				half3 sh = 0.4;
				//sh = ApplyDNSEnvColorOverride(sh);
				output.lighting = lambert + sh;
			#endif
				
				return output;
			}
			
			half4 frag(v2f input, FRONT_FACE_TYPE IsFront : FRONT_FACE_SEMANTIC) : SV_Target 
			{
				half distort = 0;
			#if _SINGLE_TEX_DISTORT
				half4 _DistortTex0 = SAMPLE_TEXTURE2D(_DistortMap0, Sampler_LinearRepeat, input.distortUV.xy);
				half _DistortSource0 = min(_DistortTex0.r, _DistortTex0.a) - 0.5;
				distort = _DistortSource0 * input.CustomData1.z;
			#elif _DOUBLE_TEX_DISTORT
				half4 _DistortTex0 = SAMPLE_TEXTURE2D(_DistortMap0, Sampler_LinearRepeat, input.distortUV.xy);
				half4 _DistortTex1 = SAMPLE_TEXTURE2D(_DistortMap1, Sampler_LinearRepeat, input.distortUV.zw);
				half2 _DistortSource = min(half2(_DistortTex0.r, _DistortTex1.r), half2(_DistortTex0.a, _DistortTex1.a)) - 0.5;
				distort = dot(_DistortSource.xy, input.CustomData1.zw);
			#endif

				// base color
				half4 mainUV = input.mainUV + distort;
				half4 _BaseMapTexture = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, mainUV.xy);
				_BaseMapTexture.a = GetAlpha(_BaseMapTexture, _BaseMapAlphaMask);
				
				half4 baseMapColor = _BaseMapTexture;
				baseMapColor *= IS_FRONT_VFACE(IsFront, _BaseColor, _BackColor);
				
			#if _SUB_TEXTURE
				half4 _SubMapTexture = SAMPLE_TEXTURE2D(_SubMap, sampler_SubMap, mainUV.zw);
				_SubMapTexture.a = GetAlpha(_SubMapTexture, _SubMapAlphaMask);
				
				half4 subMapColor = _SubMapTexture;
				subMapColor *= IS_FRONT_VFACE(IsFront, _SubColor, _BackSubColor);

				baseMapColor = _TextureBlendMode == 0 ? baseMapColor * subMapColor : baseMapColor + half4(subMapColor.rgb * _SubMapTexture.a, 0);
			#endif

				half4 outColor = baseMapColor * half4(input.particleColor.rgb, 1);
				
			#if _APPLY_LIGHTING
				outColor.rgb *= input.lighting;
			#endif

			#if _MASK
				half2 uv = _MaskApplyDistort != 0 ? input.maskAndDissolveUV.xy + distort : input.maskAndDissolveUV.xy;
				uv = rotate(uv,_MaskRotationAngle);
				half4 masktex = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv);
				half mask = min(masktex.r, masktex.a);
				outColor.a *= _MaskAffectAlpha != 0 ? mask : 1;
			#endif
				
			#if _DISSOLVE
				half2 dissolveUV = input.maskAndDissolveUV.zw + distort;
				half4 ClipTex = SAMPLE_TEXTURE2D(_DissolveMap, Sampler_LinearRepeat, dissolveUV);
				half clipSource = min(ClipTex.r, ClipTex.a);

				#if _MASK
					clipSource = _MaskAffectDissolve != 0 ? (mask - clipSource) * 0.5 + 0.5 : clipSource;
				#endif

				half2 inputData = input.CustomData1.xy * 2 - 1;
				half ClipArea = clipSource - inputData.x;
                half ClipEdge = saturate(ClipArea - inputData.y);
				/*
                ClipArea = smoothstep(0.5 - _DissolveSoft, 0.5 + _DissolveSoft, ClipArea);
                ClipEdge = 1 - smoothstep(0.5 - _DissolveEdgeSoft, 0.5 + _DissolveEdgeSoft, ClipEdge);
                */
				half2 soft = half2(_DissolveSoft, _DissolveEdgeSoft);
				half2 ClipAreaAndEdge = smoothstep(0.5 - soft, 0.5 + soft, half2(ClipArea, ClipEdge));
				ClipAreaAndEdge.y = 1 - ClipAreaAndEdge.y;

				outColor.rgb += _DissolveEdgeColor.rgb * ClipAreaAndEdge.y;
                outColor.a *= ClipAreaAndEdge.x;
			#endif
				
				
			#if _RIM
                float3 normalWS = normalize(input.normalWS);
                float3 viewDirWS = normalize(input.viewDirWS);
				half rim = abs(dot(normalWS, viewDirWS));
				rim = _RimInverse != 0 ? rim : 1 - rim;
				rim = PositivePow(rim, _RimPower) * _rimColor.a;
				rim = smoothstep(0.5 - _RimEdge, 0.5 + _RimEdge, rim);
				half3 rimColor = rim * _rimColor.rgb;

				//half rimAlphaSource = _RimAlphaSource == 0 ? _BaseMapTexture.a : outColor.a;
				half rimAlphaSource = outColor.a;

				outColor.rgb = _RimColorBlendMode == 0 ? outColor.rgb + rimColor : lerp(outColor.rgb, outColor.rgb * rimColor, rim);
				outColor.a = _RimAlphaBlendMode == 0 ? saturate(rim + rimAlphaSource) :
							_RimAlphaBlendMode > 0 ? rim * rimAlphaSource : rim;
			#endif

			#if _EDGE_CONTACT
				float2 ssUV = input.positionNDC.xy * rcp(input.positionNDC.w);
				float depth = SampleSceneDepth(ssUV);
				float sceneZ = LinearEyeDepth(depth, _ZBufferParams);
		        float thisZ = input.positionNDC.z;//LinearEyeDepth(input.positionNDC.z / input.positionNDC.w, _ZBufferParams);
		        half softParticleFade = saturate(_EdgeContactFade * (sceneZ - thisZ));

				if(_EdgeContactMode < 0)
				{
					softParticleFade = 1 - softParticleFade;
					softParticleFade *= softParticleFade;
					#if _DISSOLVE
						softParticleFade *= ClipAreaAndEdge.x;
					#endif
					outColor.rgb = lerp(outColor.rgb, _EdgeContactColor.rgb, softParticleFade);
					outColor.a = saturate(outColor.a + softParticleFade);
				}
				else
				{
					softParticleFade *= softParticleFade;
					outColor.a *= softParticleFade;
				}
				
				//return half4(softParticleFade.xxx, 1);
			#endif

				if(_ClipToggle != 0)
					outColor.a *= Get2DClipping(input.positionWSAndFog.xy, _ClipMinMax);
				
				outColor.a *= input.particleColor.a;


				if (_BlendMode == 3) // cutout
				{
					clip(outColor.a - _Cutoff);
				}
				else
				{
					outColor.rgb *= outColor.a;
					outColor.a = _BlendMode == 1 ? 0 : outColor.a; //add模式时 设置alpha为0
				}
			#if _RECEIVEFOG
                outColor.rgb = MixXYJFogColor(outColor.rgb, input.positionWSAndFog.w);
			#endif

				
			#if _UI_EFFECT && !NEED_GAMMA
				outColor.rgb = LinearToSRGB(outColor.rgb);
			#endif
				
				return max(0.0, outColor);
			}
			ENDHLSL
		}
	}
	CustomEditor "BioumRP.Effect.EffectCommonGUI_V2"
}
