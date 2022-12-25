Shader "Bioum/BlenderSkin"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        [HDR]_BaseColor("Background Color", Color) = (1, 1, 1, 1)

        [Toggle(_TEXTURE_COLOR_MAPING)] _TEXTURE_COLOR_MAPING("Texture Color Maping", float) = 0
        _GammaTex("Gamma", float) = 1
        _Bright("Bright", float) = 0
        _Contrast("Contrast", float) = 0
        _Hue("Hue", Range(0, 1)) = 0.5
        _Saturation("Saturation", Range(0, 2)) = 1
        _Value("Value", Range(0, 2)) = 1
        _HSVFac("HSVFac", Range(0, 1)) = 1
        
        [Toggle(_SET_LIGHT_DIR)] _SET_LIGHT_DIR("Set Light Dir", float) = 0
        [HideInInspector]_LightDirH("Light Dir H", Range(-1, 1)) = 0
        [HideInInspector]_LightDirV("Light Dir V", Range(-1, 1)) = 0.5
        _LightDir("Light Dir", Vector) = (0, -1, 1, 1)
        _LightInvert ("Light Invert", Range(0, 1)) = 0.767
        _LightColor1 ("Light Color1", Color) = (1, 0.85, 0.81, 1)
        _LightColor2 ("Light Color2", Color) = (0.71, 0.562, 0.503, 1)
        _LightDirMul ("Light Dir x", float) = 55
        _LightDirAdd ("Light Dir +", float) = -45

        _OutLineMul ("OutLine x", float) = 12.9
        _OutLineAdd ("OutLine +", float) = -9.7

        _Gamma ("Gamma", float) = 0.8

        _Color1("Color1", Color) = (0.5, 0.4, 0.4, 1)
        _Color2("Color2", Color) = (0.5, 0.2, 0.4, 1)
        _ColorMul("Color x", float) = 32.258
        _ColorAdd("Color +", float) = -19.516
        _ColorLerp ("Color Lerp", Range(0, 1)) = 0.525

        _LightOffset ("Light Offset", Range(0, 1)) = 0.5

        [HideInInspector] _BlendMode("_BlendMode", float) = 0
        [HideInInspector] _SrcBlend("_SrcBlend", float) = 1
        [HideInInspector] _DstBlend("_DstBlend", float) = 0
        [HideInInspector] _Cutoff("透贴强度", Range(0.0, 1.0)) = 0.5

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Blend[_SrcBlend][_DstBlend]
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _ _SET_LIGHT_DIR
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _TEXTURE_COLOR_MAPING

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "ShaderLibrary/LightingCommon.hlsl"
            #include "ShaderLibrary/Color.hlsl"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                real3 normalOS : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                real3 normalWS : TEXCOORD1;
                real3 viewDirWS : TEXCOORD2;
            };

            sampler2D _BaseMap;
            half4 _BaseColor;
            float4 _BaseMap_ST;
#if _TEXTURE_COLOR_MAPING
            float _GammaTex;
            float _Bright;
            float _Contrast;
            half _Hue;
            half _Saturation;
            half _Value;
            half _HSVFac;
#endif
            real4 _LightColor1;
            real4 _LightColor2;
            float _LightDirMul;
            float _LightDirAdd;
            real _LightInvert;
            real _LightOffset;
            float _OutLineMul;
            float _OutLineAdd;
            float _Gamma;
            half4 _Color1;
            half4 _Color2;
            real _ColorLerp;
            float _ColorMul;
            float _ColorAdd;
            real _Cutoff;
#if _SET_LIGHT_DIR
            float3 _LightDir;
#endif

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.viewDirWS = SafeNormalize(_WorldSpaceCameraPos.xyz - TransformObjectToWorld(v.vertex.xyz));
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                real4 colTex = tex2D(_BaseMap, i.uv);
#if _ALPHATEST_ON
                clip(colTex.a - _Cutoff);
#endif
#if _TEXTURE_COLOR_MAPING
                colTex.rgb = pow(colTex.rgb, _GammaTex);

                float a = 1.0 + _Contrast;
                float b = _Bright - _Contrast * 0.5;
                colTex.r = saturate(a * colTex.r + b);
                colTex.g = saturate(a * colTex.g + b);
                colTex.b = saturate(a * colTex.b + b);

                float3 hsv = RGB2HSV(colTex.rgb);
                hsv.r = frac(hsv.r + _Hue + 0.5);
                hsv.g = saturate(hsv.g * _Saturation);
                hsv.b = hsv.b * _Value;
                hsv = HSV2RGB(hsv);
                colTex.rgb = saturate(lerp(colTex.rgb, hsv, _HSVFac));
#endif
                Light light = GetMainLight();
                real3 normalWS = normalize(i.normalWS);
#if _SET_LIGHT_DIR
                real ndotl = dot(normalWS, normalize(_LightDir));
#else
                real ndotl = dot(normalWS, normalize(light.direction));
#endif
                real rat = lerp(ndotl, 1 - ndotl, _LightInvert);
                real3 viewDirWS = normalize(i.viewDirWS);
                half4 col = lerp(_LightColor1, _LightColor2, saturate(rat * _LightDirMul + _LightDirAdd));
                rat = 1 - abs(dot(viewDirWS, normalWS));
                col.rgb *= 1 - saturate(rat * _OutLineMul + _OutLineAdd);
                col.rgb = pow(abs(col.rgb), _Gamma);

                colTex.rgb *= (_LightOffset + (1 - _LightOffset) * saturate(ndotl) * light.color * light.distanceAttenuation) * light.shadowAttenuation;
                real3 col2 = lerp(_Color1.rgb, _Color2.rgb, saturate(rat * _ColorMul + _ColorAdd));
                col2 = lerp(colTex.rgb, col2, _ColorLerp);
                col.rgb *= col2 * _BaseColor.rgb;
                col.a = colTex.a;
                return col;
            }
            ENDHLSL
        }
    }

    CustomEditor "BlenderSkinEditor"
}
