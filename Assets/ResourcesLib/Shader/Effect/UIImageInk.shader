Shader "Bioum/UI/Ink"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,0,1)
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Mask Tex", 2D) = "white" {}
        
        [Space(20)]
        _MainScale ("Main Scale", range(0, 1.5)) = 1.1
        _MaskScale ("Mask Scale", range(0, 1.5)) = 1.1
        _InkGrow ("Ink Grow", range(0, 1)) = 1
        _InkSmooth ("Ink Smooth", range(0, 1)) = 0.18
        
        _Layer2Later ("Layer2 Grow Later", range(-1, 1)) = 0
        _Layer3Later ("Layer3 Grow Later", range(-1, 1)) = 0.3
        
        [Space(20)]
        _Layey1Alpha ("Layey1 Alpha", range(0, 1)) = 1
        _Layey2Alpha ("Layey2 Alpha", range(0, 1)) = 0.7
        _Layey3Alpha ("Layey3 Alpha", range(0, 1)) = 0.3
        _AlphaForAll ("Alpha For All", range(0.05, 2)) = 0.3
        
        [Space(20)]
        _NoiseTex ("Noise Tex", 2D) = "white" {}
        _WaveSpeed ("Wave Speed", range(0,1)) = 0.2
        _WavePower ("Wave Power", range(0,1)) = 0.5
    }
    
    SubShader
    {
        Tags
        { 
            "RenderType" = "Transparent"  
            "Queue" = "Transparent" 
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
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

            #define PIVOT float2(0.5, 0.5)

            float2 Rotate(float2 uv, float2 pivot, float angle)
            {
                float a = angle / 180 * PI;
                float cosAngle = cos(a);
                float sinAngle = sin(a);
                
                float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
                
                return mul(rot, uv - pivot) + pivot;
            }

            float2 ScaleWithCenter(float2 uv, float2 scale)
            {
                float2 gv = (uv - PIVOT) * scale + PIVOT;
                float alpha = min( min(step(-0.05, gv.x), step(gv.x, 1.05)), min(step(-0.05, gv.y), step(gv.y, 1.05)) );

                return gv * alpha;
            }

            float2 Fisheye(float2 uv, float power)
            {
                float2 gv = uv - PIVOT;
                float2 fisheye_uv = tan(sqrt(dot(gv, gv)) * power) * normalize(gv);

                float strength = sqrt(dot(PIVOT, PIVOT));
                fisheye_uv = fisheye_uv * strength / tan(strength * power) + PIVOT;

                return fisheye_uv;     
            }
            
            TEXTURE2D(_MainTex);
            TEXTURE2D(_MaskTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_MaskTex);
            SAMPLER(sampler_NoiseTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;            
            float4 _MaskTex_ST;
            float4 _NoiseTex_ST;
            float _MainScale;
            float _MaskScale;
            float _InkGrow;
            float _InkSmooth;
            float _Layer2Later;
            float _Layer3Later;
            float _Layey1Alpha;
            float _Layey2Alpha;
            float _Layey3Alpha;
            float _AlphaForAll;
            float  _WaveSpeed;
            float _WavePower;
            float4 _Color;
            CBUFFER_END
            

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID (v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv - PIVOT;
                float2 polar_uv;
                polar_uv.x = length(uv) * 2;
                polar_uv.y = atan2(uv.x, uv.y) / TWO_PI;
                float2 wave = float2(-_WaveSpeed, _WaveSpeed);
                half polar_noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex,  polar_uv + wave * _Time.y).g * smoothstep(0, 4, polar_uv.x);

                float2 main_uv = Fisheye(i.uv, _MainScale) + polar_noise * _WavePower;
                float2 main_uv_rot = ScaleWithCenter(Rotate(main_uv, PIVOT, 90), float2(1.5, 1));

                float main = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, main_uv).r;
                float noise = pow(abs(clamp(0, 1, 1 - SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, i.uv).r)), 1.5);

                float growsmooth = clamp(0, 1, _InkGrow + _InkSmooth);
                float layer1 = smoothstep(_InkGrow, growsmooth, SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, main_uv_rot).r) * _Layey1Alpha;
                float layer2 = smoothstep(clamp(0, 1, _InkGrow - _Layer2Later), clamp(0, 1, growsmooth - _Layer2Later), main) * _Layey2Alpha;
                float layer3 = smoothstep(clamp(0, 1, _InkGrow - _Layer3Later), clamp(0, 1, growsmooth - _Layer3Later), main * noise) * _Layey3Alpha;

                float albedo = max(max(layer1, layer2), layer3);
                float2 mask_uv = Fisheye(i.uv, _MaskScale);
                float mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, mask_uv).r;
                mask = pow(abs(min(mask, albedo)), _AlphaForAll);
                
                half3 col = albedo * _Color.rgb;

                return half4(col, mask);
            }
            ENDHLSL
        }
    }
}
