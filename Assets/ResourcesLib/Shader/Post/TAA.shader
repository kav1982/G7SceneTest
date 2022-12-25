Shader "Post/RenderFeature/TAA"
{
    HLSLINCLUDE

        #pragma multi_compile _ _USE_DRAW_PROCEDURAL
        #define _TAA_TONEMAPPING 1
        #define _HIGH_QUALITY 1

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    
        TEXTURE2D_X(_SourceTex);
        float4 _SourceTex_TexelSize;
        TEXTURE2D_X(_TAA_Texture);

        float4x4 _TAA_PrevViewProj;
        float2 _TAA_Offset;
        float _TAA_Blend;
        float _TAA_Sharpen;

    
    
        struct VaryingsTAA
        {
            float4 positionCS   : SV_POSITION;
            float4 uv           : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };
    

        VaryingsTAA VertTAA(Attributes input)
        {
            VaryingsTAA output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
            
            #if _USE_DRAW_PROCEDURAL
                 output.positionCS = float4(input.vertexID <= 1 ? -1.0 : 3.0, input.vertexID == 1 ? 3.0 : -1.0, 0.0, 1.0);
                 output.uv.xy = float2(input.vertexID <= 1 ? 0.0 : 2.0, input.vertexID == 1 ? 2.0 : 0.0);
                 if (_ProjectionParams.x < 0.0) {
                    output.uv.y = 1.0 - output.uv.y;
                }
            #else
                  output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                  output.uv.xy = input.uv;
            #endif
            
             float4 projPos = output.positionCS * 0.5;
             projPos.xy = projPos.xy + projPos.w;
             output.uv.zw = projPos.xy;
            
             return output;

        }        

        half4 clip_aabb(half4 aabb_min, half4 aabb_max, half4 prevSample)
        {
            half4 p_clip = 0.5 * (aabb_max + aabb_min);
            half4 e_clip = 0.5 * (aabb_max - aabb_min) + HALF_EPS;

            half4 v_clip = prevSample - p_clip;
            half4 v_unit = v_clip / e_clip;
            half4 a_unit = abs(v_unit);
            half ma_unit = max(a_unit.w, max(a_unit.x, max(a_unit.y, a_unit.z)));
            
            if (ma_unit > 1.0)
                return p_clip + v_clip / ma_unit;
            else
                return prevSample;
        }

        void minmax(float2 uv, half4 centerColor, out half4 cmin, out half4 cmax)
        {
            float2 du = float2(_SourceTex_TexelSize.x, 0);
            float2 dv = float2(0, _SourceTex_TexelSize.y);

        #if _HIGH_QUALITY
            //half3 ctl = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv - dv - du).rgb;
            half4 ctc = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv - dv);
            //half3 ctr = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv - dv + du).rgb;
            half4 cml = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv - du);
            half4 cmr = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv + du);
            //half3 cbl = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv + dv - du).rgb;
            half4 cbc = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv + dv);
            //half3 cbr = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv + dv + du).rgb;
        #elif _LOW_QUALITY

            half4 crt = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv + _SourceTex_TexelSize);
            half4 clb = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_LinearClamp, uv - _SourceTex_TexelSize);
        #endif

        #if _TAA_TONEMAPPING
            #if _HIGH_QUALITY
                ctc.rgb = FastTonemap(ctc.rgb);
                cml.rgb = FastTonemap(cml.rgb);
                cmr.rgb = FastTonemap(cmr.rgb);
                cbc.rgb = FastTonemap(cbc.rgb);
            #elif _LOW_QUALITY
                crt.rgb = FastTonemap(crt.rgb);
                clb.rgb = FastTonemap(clb.rgb);
            #endif
        #endif

            // cmin = min(ctl, min(ctc, min(ctr, min(cml, min(centerColor, min(cmr, min(cbl, min(cbc, cbr))))))));
            // cmax = max(ctl, max(ctc, max(ctr, max(cml, max(centerColor, max(cmr, max(cbl, max(cbc, cbr))))))));
            // float3 cmin5 = min(ctc, min(cml, min(centerColor, min(cmr, cbc))));
            // float3 cmax5 = max(ctc, max(cml, max(centerColor, max(cmr, cbc))));
            // cmin = 0.5 * (cmin + cmin5);
            // cmax = 0.5 * (cmax + cmax5);

        #if _HIGH_QUALITY
            cmin = min(centerColor, min(ctc, min(cml, min(cmr, cbc))));
            cmax = max(centerColor, max(ctc, max(cml, max(cmr, cbc))));
        #elif _LOW_QUALITY
            cmin = min(centerColor, min(crt, clb));
            cmax = max(centerColor, max(crt, clb));
        #endif

            // half3 corner = ((ctc + cml + cmr + cbc) - centerColor) * 2;
            // sharpedColor = (centerColor - corner * 0.1667) * 2.71 * _TAA_Sharpen;
            //
            // bluredColor = (centerColor + ctc + cml + cmr + cbc) * 0.2;
        }

        float2 reprojection(float4 uv)
        {
            float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv.xy).r;

        #if UNITY_REVERSED_Z
            depth = 1.0 - depth;
        #endif

            depth = 2.0 * depth - 1.0;

            float3 viewPos = ComputeViewSpacePosition(uv.zw, depth, unity_CameraInvProjection);
            float4 worldPos = float4(mul(unity_CameraToWorld, float4(viewPos, 1.0)).xyz, 1.0);

            float4 prevClipPos = mul(_TAA_PrevViewProj, worldPos);
            float2 prevPosCS = prevClipPos.xy / prevClipPos.w;
            return prevPosCS * 0.5 + 0.5;
        }

        half4 Frag(VaryingsTAA input) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            float2 uv = UnityStereoTransformScreenSpaceTex(input.uv.xy) - _TAA_Offset.xy;
            half4 color = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv);
            color = max(0, color);

            float2 prev_uv = reprojection(float4(uv, input.uv.zw));
            half4 prev_color = SAMPLE_TEXTURE2D_X(_TAA_Texture, sampler_LinearClamp, prev_uv);
            prev_color = max(0, prev_color);
            
        #if _TAA_TONEMAPPING
            color.rgb = FastTonemap(color.rgb);
            prev_color.rgb = FastTonemap(prev_color.rgb);
        #endif
                        
            half4 color_min, color_max;
            minmax(uv, color, color_min, color_max);
            prev_color = clip_aabb(color_min, color_max, prev_color);
            
            half4 c = lerp(color, prev_color, _TAA_Blend);

        #if _TAA_TONEMAPPING
            c.rgb = FastTonemapInvert(c.rgb);
        #endif

            return max(0, c);
        }
    

    ENDHLSL

    SubShader
    {
        Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
            LOD 100
            ZTest Always ZWrite Off Cull Off

            Pass
        {
            Name "TAA"

            HLSLPROGRAM
                #pragma vertex VertTAA
                #pragma fragment Frag
                //#pragma multi_compile_local _ _TAA_Tonemapping
                //#pragma multi_compile_local _HIGH_QUALITY _LOW_QUALITY
            ENDHLSL
        }
        

        
    }
}
