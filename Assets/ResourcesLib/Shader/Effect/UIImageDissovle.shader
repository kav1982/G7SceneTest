Shader "Bioum/UI/UIImageDissovle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Mask Tex", 2D) = "white" {}
        _DirTex ("Director Tex", 2D) = "white" {}
        _RotateAngle ("Rotate Angle", float) = 0
        _NoiseTex ("Noise Tex", 2D) = "white" {}
        _NoiseTilingAndSpeed ("Noise Tiling(XY) & Speed(ZW)", vector) = (2, 2, 0, 0.2)
        _NoiseStrength ("Noise Strength", range(0, 3)) = 1.9
        _ColorTex ("Color Tex", 2D) = "white" {}
        [Space(20)]
        _Dissovle ("Dissovle", range(-1, 1)) = 0.1
        _DissSmooth ("Dissovle Smooth", range(0,2)) = 0.5
        [Space(20)]
        _EdgeWidth ("Edge Width", range(0, 1.5)) = 1.6
        _EdgeIntensity ("Edge Intensity", range(0, 5)) = 1.3
        
    }
    
    SubShader
    {
        Tags{ 
            "RenderType" = "Transparent"  
            "Queue" = "Transparent" 
            "IgnoreProjector" = "True" 
            "PreviewType"="Plane"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma instancing_options forcemaxcount:127

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_MainTex);
            TEXTURE2D(_NoiseTex);
            TEXTURE2D(_MaskTex);
            TEXTURE2D(_DirTex);
            TEXTURE2D(_ColorTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_NoiseTex);
            SAMPLER(sampler_MaskTex);
            SAMPLER(sampler_DirTex);
            SAMPLER(sampler_ColorTex);            

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NoiseTilingAndSpeed;
            float _NoiseStrength;
            float _Dissovle;
            float _RotateAngle;
            float _DissSmooth;
            float _EdgeWidth;
            float _EdgeIntensity;
            CBUFFER_END

            float2 rotate(float2 uv, float angle)
            {
                angle = angle / 180 * 3.1415926;
                
                float2 pivot = float2(0.5, 0.5);
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);
                float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
                uv = mul(rot, uv - pivot) + pivot;
                return uv;  
            }

            float remap(float x, float oldMin, float oldMax, float newMin, float newMax)
            {
                return (x - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
            }

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID (v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                
                half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                half mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv).r;
                

                float2 uv = rotate(i.uv, _RotateAngle);
                half dir = pow(SAMPLE_TEXTURE2D(_DirTex, sampler_DirTex, uv).r, 0.5);
                dir = clamp(smoothstep(_Dissovle, _Dissovle + _DissSmooth, dir), 0, 1);
                float noise_mask = pow(min(1.0 - dir, dir), 0.5);
                dir = remap(dir, 0.0, 1.0, -1.0, 2.0);

                float2 noise_uv = i.uv * _NoiseTilingAndSpeed.xy + _NoiseTilingAndSpeed.zw * _Time.y;
                half noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noise_uv).r;
                noise = (noise * 2 - 1) * _NoiseStrength * noise_mask;

                float dis = dir - noise;

                float edge = clamp(1 - distance(dis, 0.5) / _EdgeWidth, 0.0, 1.0);
                float2 colo_uv = pow(float2(1.0 - edge, 0.5), 1);
                float3 edgecolol = SAMPLE_TEXTURE2D(_ColorTex, sampler_ColorTex, colo_uv).rgb * _EdgeIntensity;

                float dissovle = clamp(smoothstep(0.0, 0.1, dis), 0.0, 1.0);

                
                float3 finalcol = lerp(albedo.rgb, edgecolol, edge);
                finalcol = lerp(albedo.rgb, finalcol, mask);

                float alpha = dissovle * mask + (1 - mask);

                
                return half4(finalcol, alpha * albedo.a);
            }
            ENDHLSL
        }
    }
}
