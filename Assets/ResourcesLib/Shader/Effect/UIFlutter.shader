Shader "Bioum/UI/Flutter"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _PacticalTex ("Pactical Tex", 2D) = "white" {}
        _DissTex ("Dissovle Tex", 2D) = "white" {}
        _DissRotate ("Dissovle Rotate", float) = 0
        
        [Space(20)]
        _Appear ("Appear", range(0, 1.5)) = 0.0
        _Disappear ("Disappear", range(0, 1.5)) = 0.0
        _ProgressSmooth ("Progress Smooth", range(0, 1)) = 0.2
        
        [Space(20)]
        _BlurPow ("Blur Strength", float) = 0.1
        _BlurTilingOffset ("Blur Tiling and Offset", vector) = (1.0, 0.5, 0, 0)
        
        [Space(20)]
        _ParticalWidth ("Partical Width", float) = 0.1
        _ParticalTilingSpeed1 ("Partical Tiling and Speed 1", vector) = (1.0, 1.0, 0.1, 0.1)
        _ParticalLight1 ("Partical Light 1", float) = 2.0
        _ParticalTilingSpeed2 ("Partical Tiling and Speed 2", vector) = (1.0, 1.0, 0.1, 0.1)
        _ParticalLight2 ("Partical Light 2", float) = 2.0
        _ParticalTilingSpeed3 ("Partical Tiling and Speed 3", vector) = (1.0, 1.0, 0.1, 0.1)
        _ParticalLight3 ("Partical Light 3", float) = 2.0
        _ParcticalColor ("Parctical Color", color) = (1,1,1,1)
        
    }
    SubShader
    {
        Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" "IgnoreProjector" = "True"}
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
            TEXTURE2D(_PacticalTex);
            TEXTURE2D(_DissTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_PacticalTex);
            SAMPLER(sampler_DissTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST; 
            float4 _PacticalTex_ST;   
            float4 _DissTex_ST;
            float _BlurPow;
            float _Appear;
            float _ProgressSmooth;
            float _Disappear;
            float4 _BlurTilingOffset;
            float _ParticalWidth;
            float4 _ParticalTilingSpeed1;
            float4 _ParticalTilingSpeed2;
            float4 _ParticalTilingSpeed3;
            float _ParticalLight1;
            float _ParticalLight2;
            float _ParticalLight3;
            float4 _ParcticalColor;
            float _DissRotate;
            CBUFFER_END
            
            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID (v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
                
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float2 rotate(float2 uv, float angle)
			{
				float a = angle / 180 * 3.1415926;
				float2 pivot = float2(0.5, 0.5);
				float cosAngle = cos(a);
				float sinAngle = sin(a);
				float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
				uv = mul(rot,uv - pivot) + pivot;
				return uv;
			}

            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                
                float2 uv = i.uv;
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                half mask = SAMPLE_TEXTURE2D(_DissTex, sampler_DissTex, rotate(uv, _DissRotate)).r;

                //扩大mask
                float2 amplify = 1 - _BlurTilingOffset.xy * float2(0.01, 0.01);
                float2 anchor = _BlurTilingOffset.zw;
                float2 blur_uv = (uv - anchor) * amplify + anchor;

                float scale = 0.01 * _BlurPow;
                float3 blurcol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).xyz;
                for(float i=0.5; i<4; i++)
                {
                    blurcol += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).xyz;         
                }

                blurcol /= 5.0;

                //lizi
                float2 partical_uv = uv * _ParticalTilingSpeed1.xy + _Time.y * _ParticalTilingSpeed1.zw;
                half partical = SAMPLE_TEXTURE2D(_PacticalTex, sampler_PacticalTex, partical_uv).r * _ParticalLight1;
                
                partical_uv = uv * _ParticalTilingSpeed2.xy + _Time.y * _ParticalTilingSpeed2.zw;
                partical = (partical +  SAMPLE_TEXTURE2D(_PacticalTex, sampler_PacticalTex, partical_uv).g) * _ParticalLight2;
                
                partical_uv = uv * _ParticalTilingSpeed3.xy + _Time.y * _ParticalTilingSpeed3.zw;
                partical = (partical +  SAMPLE_TEXTURE2D(_PacticalTex, sampler_PacticalTex, partical_uv).b) * _ParticalLight2;
       
                
                //dissapear
                float dissapear = smoothstep(_Disappear, _Disappear - _ProgressSmooth, mask);
                float partical_dis = smoothstep(_Disappear - _ParticalWidth, _Disappear - _ParticalWidth - _ProgressSmooth, mask);
                partical_dis = (dissapear - partical_dis) * blurcol.r * partical;

                //appear  
                half appear = smoothstep(1 - _Appear, 1 - _Appear  - _ProgressSmooth, mask);
                half partical_app = smoothstep( 1 - _Appear - _ParticalWidth,  1 - _Appear - _ParticalWidth - _ProgressSmooth, mask);
                partical_app = (appear - partical_app) * blurcol.r * partical;

                half3 text_dis = col.rgb * col.a * (1 - dissapear);
                half3 text_app = col.rgb * col.a * appear;
                half3 particalcol = half3(0,0,0);
                half alpha = col.a;

                half3 finalcol = half3(0,0,0);

                if(_Appear>0)
                {
                    particalcol = partical_app * _ParcticalColor.rgb;
                    finalcol = text_app + particalcol;
                    alpha = alpha * appear + partical_app;
                }
                else
                {
                    particalcol = partical_dis * _ParcticalColor.rgb;
                    finalcol = text_dis + particalcol;
                    alpha = alpha * (1 - dissapear) + partical_dis;
                }

                return half4(finalcol, alpha * col.a);
            }
            ENDHLSL
        }
    }
}
