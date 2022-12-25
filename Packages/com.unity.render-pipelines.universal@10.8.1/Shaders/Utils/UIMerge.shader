Shader "Hidden/Universal Render Pipeline/UIMerge"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            Name "UIMerge"
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex FullscreenVert
            #pragma fragment Fragment
            //#pragma multi_compile_fragment _ _LINEAR_TO_SRGB_CONVERSION
            #pragma multi_compile _ _USE_DRAW_PROCEDURAL

            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Fullscreen.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            TEXTURE2D_X(_GameCameraColorTexture);//场景图
            SAMPLER(sampler_GameCameraColorTexture);
            TEXTURE2D_X(_SourceTex);//UI图
            SAMPLER(sampler_SourceTex);

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half4 col = SAMPLE_TEXTURE2D_X(_GameCameraColorTexture, sampler_GameCameraColorTexture, input.uv);
                half4 col2 = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_SourceTex, input.uv);

                col2.rgb = SRGBToLinear(col2.rgb);
                col2.a = LinearToSRGB(col2.a);
                col.rgb = col2.rgb * col2.a + col.rgb * (1 - col2.a);

                return col;
            }
            ENDHLSL
        }
    }
}
