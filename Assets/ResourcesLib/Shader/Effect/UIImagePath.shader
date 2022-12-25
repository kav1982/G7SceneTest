Shader "Bioum/UI/UIImagePath"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _Appear ("Appear", Range(0, 1)) = 1
        _Smooth ("Smooth", Range(0, 1)) = 0.1
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
            #pragma target 2.0
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
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MainTex);

            SAMPLER(sampler_MaskTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _MaskTex_ST;
            float _Appear;
            float _Smooth;
            CBUFFER_END

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
                
                // sample the texture
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                half mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv).r * col.a;

                mask = smoothstep(_Appear, _Appear + _Smooth, mask);
                
                return half4(col.rgb,mask);
            }
            ENDHLSL
        }
    }
}
