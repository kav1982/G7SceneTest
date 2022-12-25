			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "ShaderLibrary/Fog.hlsl"
            #include "ShaderLibrary/LightingCommon.hlsl"
			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 lightmapUV : TEXCOORD1;
				float3 color : COLOR;
				
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				
				float4 uv01: TEXCOORD0;
                float4 uv23: TEXCOORD1;
				half3 uvControlandVertexColR : TEXCOORD2;
#if _NORMALMAP
                half4 tangentWS: TEXCOORD3;    // xyz: tangent, w: viewDir.x
                half4 bitangentWS: TEXCOORD4;    // xyz: binormal, w: viewDir.y
                half4 normalWS: TEXCOORD5;    // xyz: normal, w: viewDir.z
#else
                half3 normalWS: TEXCOORD3;
                half3 viewDirWS: TEXCOORD4;
#endif
				DECLARE_GI_DATA(lightmapUV, vertexSH, 6);
				half4 positionWSAndFog : TEXCOORD7;
            #if _MAIN_LIGHT_SHADOWS
				float4 shadowCoord : TEXCOORD8;
			#endif
			    DECLARE_VERTEX_LIGHTING(vertexLighting, 9)
			};
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(half4, _SplatScale)
	UNITY_DEFINE_INSTANCED_PROP(half4, _VertexAOCol)
	UNITY_DEFINE_INSTANCED_PROP(half4, _VertexAOParam)
	UNITY_DEFINE_INSTANCED_PROP(half4, _PenumbraTintColor)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)
			half4 _NormalScale;
            TEXTURE2D(_Control); SAMPLER(sampler_Control);
            TEXTURE2D(_Splat0); SAMPLER(sampler_Splat0);
            TEXTURE2D(_Splat1); SAMPLER(sampler_Splat1);
            TEXTURE2D(_Splat2); SAMPLER(sampler_Splat2);
            TEXTURE2D(_Splat3); SAMPLER(sampler_Splat3);

            #if _NORMALMAP
               sampler2D _Normal0, _Normal1, _Normal2, _Normal3;
            #endif

			#define _AOStrength _VertexAOParam.x
			#define _AOColStrength _VertexAOParam.y

			//half _LightIntensity;

			half3 sampleNormalMap(sampler2D tex, float2 uv, half scale)
            {
                half4 map = tex2D(tex, uv);
                return UnpackNormalScale(map, scale);
            }