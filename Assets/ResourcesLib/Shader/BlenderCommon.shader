Shader "Bioum/BlenderCommon"
{
    Properties
    {
        _BaseMap("Texture", 2D) = "white" {}
        [HDR]_BaseColor("Background Color", Color) = (1, 1, 1, 1)
        
        [Toggle(_TEXTURE_COLOR_MAPING)] _TEXTURE_COLOR_MAPING("Texture Color Maping", float) = 0
        _Gamma("Gamma", float) = 0.4
        _Bright ("Bright", float) = 0.1
        _Contrast ("Contrast", float) = 1.1

        _Hue ("Hue", Range(0, 1)) = 0.5
        _Saturation ("Saturation", Range(0, 2)) = 0
        _Value ("Value", Range(0, 2)) = 0.5
        _HSVFac ("HSVFac", Range(0, 1)) = 1

        [Toggle(_OUT_LINE)] _OUT_LINE_ON("Out Line", float) = 0
        _OutLineCol("OutLine Color", Color) = (0, 0, 0, 1)
        _OutLineMul("OutLine x", float) = 12.9
        _OutLineAdd("OutLine +", float) = -9.7

        [Toggle(_SET_LIGHT_DIR)] _SET_LIGHT_DIR("Set Light Dir", float) = 0
        [Toggle(_SET_LIGHT_COL)] _SET_LIGHT_COL("Set Light Col", float) = 0
        [HideInInspector]_LightDirH("Light Dir H", Range(-1, 1)) = 0
        [HideInInspector]_LightDirV("Light Dir V", Range(-1, 1)) = 0.5
        _LightDir("Light Dir", Vector) = (0, -1, 1, 1)
        _LightInvert("Light Invert", Range(0, 1)) = 0
        _LightColor1("Light Color1", Color) = (0.6, 0.6, 0.6, 1)
        _LightColor2("Light Color2", Color) = (0.4, 0.4, 0.4, 1)
        _LightDirMul("Light Dir x", float) = 2
        _LightDirAdd("Light Dir +", float) = -0.5

        _reflectionRat("Reflection Rat", Range(1, 3)) = 0.5
        _reflectionPow("Reflection Pow", Range(0, 20)) = 5

        _LightOffset("Light Offset", Range(0, 1)) = 0.5

        _SmoothDiff("Smooth Diff", Range(0.01, 20)) = 1
        _SmoothReflection("Smooth Reflection", Range(0.01, 2)) = 1

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
            #pragma shader_feature_local _ _OUT_LINE
            #pragma shader_feature_local _ _SET_LIGHT_COL
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
                float3 reflectionDir : TEXCOORD3;
            };

            sampler2D _BaseMap;
            float4 _BaseMap_ST;
            half4 _BaseColor;
#if _TEXTURE_COLOR_MAPING
            float _Gamma;
            float _Bright;
            float _Contrast;
            half _Hue;
            half _Saturation;
            half _Value;
            half _HSVFac;
#endif
            real _LightOffset;
#if _OUT_LINE
            float _OutLineMul;
            float _OutLineAdd;
            real3 _OutLineCol;
#endif
            real _reflectionRat;
            half _reflectionPow;

            half _SmoothDiff;
            real _SmoothReflection;
#if _SET_LIGHT_COL
            real3 _LightColor1;
            real3 _LightColor2;
            float _LightDirMul;
            float _LightDirAdd;
            real _LightInvert;
#endif
#if _SET_LIGHT_DIR
            float3 _LightDir;
#endif
            real _Cutoff;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);

                o.viewDirWS = SafeNormalize(_WorldSpaceCameraPos.xyz - TransformObjectToWorld(v.vertex.xyz));
                o.reflectionDir = reflect(o.viewDirWS, normalize(mul(v.normalOS, (float3x3)unity_WorldToObject)));
                return o;
            }

            real4 frag(v2f i) : SV_Target
            {
                real4 col = tex2D(_BaseMap, i.uv);
#if _ALPHATEST_ON
                clip(col.a - _Cutoff);
#endif
#if _TEXTURE_COLOR_MAPING
                col = pow(col, _Gamma);

                float a = 1.0 + _Contrast;
                float b = _Bright - _Contrast * 0.5;
                col.r = saturate(max(a * col.r + b, 0.0));
                col.g = saturate(max(a * col.g + b, 0.0));
                col.b = saturate(max(a * col.b + b, 0.0));

                float3 hsv = RGB2HSV(col.rgb);
                hsv.r = frac(hsv.r + _Hue + 0.5);
                hsv.g = saturate(hsv.g * _Saturation);
                hsv.b = hsv.b * _Value;
                hsv = HSV2RGB(hsv);
                col.rgb = saturate(lerp(col.rgb, hsv, _HSVFac));
#endif
                float3 normalWS = normalize(i.normalWS);
                Light light = GetMainLight();
#if _SET_LIGHT_DIR
                real ndotl = dot(normalWS, normalize(_LightDir));
#else
                real ndotl = dot(normalWS, normalize(light.direction));
#endif
                ndotl = smoothstep(0, _SmoothDiff, ndotl);
                real rat;
#if _SET_LIGHT_COL
                rat = lerp(ndotl, 1 - ndotl, _LightInvert);
                col.rgb *= lerp(_LightColor1, _LightColor2, saturate(rat * _LightDirMul + _LightDirAdd));
#endif
                col.rgb *= (_LightOffset + (1 - _LightOffset) * saturate(ndotl) * light.color * light.distanceAttenuation * light.shadowAttenuation) * _BaseColor.rgb;

                real3 viewDirWS = normalize(i.viewDirWS);
                col.rgb *= (_reflectionRat + (1 - _reflectionRat) * smoothstep(0, _SmoothReflection, pow(1 - saturate(dot(i.reflectionDir, viewDirWS)), _reflectionPow)));
#if _OUT_LINE
                rat = 1 - abs(dot(viewDirWS, normalWS));
                col.rgb = lerp(col.rgb, _OutLineCol, saturate(rat * _OutLineMul + _OutLineAdd));
#endif
                return col;
            }
            ENDHLSL
        }
    }
    
    CustomEditor "BlenderCommonEditor"
}
