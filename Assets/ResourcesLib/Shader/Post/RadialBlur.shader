Shader "Post/RenderFeature/RadialBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        TEXTURE2D(_MainTex);
        TEXTURE2D(_RadialBlurSource);
        SAMPLER(Sampler_LinearClamp);
        
        half4 _RadialBlurParam;
		int _Pow;
        #define blurIntensity _RadialBlurParam.x
        #define AreaRange _RadialBlurParam.yz
		#define _Bright _RadialBlurParam.w;

        v2f vert (appdata input)
        {
            v2f output;
            output.vertex = TransformObjectToHClip(input.vertex.xyz);
            output.uv = input.texcoord;
            return output;
        }

		half4 fragBlurFirst (v2f input) : SV_Target
        {
            float2 center = 0.5;
			half2 direction = input.uv - center;
			half dist = length(direction);
			direction /= dist;

			half4 sum = SAMPLE_TEXTURE2D(_MainTex, Sampler_LinearClamp,input.uv + direction * 0.01);
			sum += SAMPLE_TEXTURE2D(_MainTex, Sampler_LinearClamp,input.uv + direction * 0.02);
			sum += SAMPLE_TEXTURE2D(_MainTex, Sampler_LinearClamp,input.uv + direction * 0.012);
			sum += SAMPLE_TEXTURE2D(_MainTex, Sampler_LinearClamp,input.uv + direction * 0.027);

			sum += SAMPLE_TEXTURE2D(_MainTex, Sampler_LinearClamp,input.uv + direction * 0.02);
			sum += SAMPLE_TEXTURE2D(_MainTex, Sampler_LinearClamp,input.uv + direction * 0.03);
			sum += SAMPLE_TEXTURE2D(_MainTex, Sampler_LinearClamp,input.uv + direction * 0.01);
			sum += SAMPLE_TEXTURE2D(_MainTex, Sampler_LinearClamp,input.uv + direction * 0.025);

			sum /= 8;

			half4 srcCol = SAMPLE_TEXTURE2D(_MainTex, Sampler_LinearClamp,input.uv);

			float mask = length((input.uv * 2 - 1));
            mask = smoothstep(AreaRange.x, AreaRange.y, mask);

			sum = lerp(srcCol, sum, mask);
            
            return sum;
        }

        half4 fragBlurAndBlend (v2f input) : SV_Target
        {
            float2 center = 0.5;
            float2 direction = (center - input.uv) * blurIntensity;

            half4 color = 0;                

            UNITY_UNROLL
			half imax = max(2,_Pow);

            for (int i = 1; i < imax; i++)
            {
                float2 uv = input.uv + direction * i;
                color += SAMPLE_TEXTURE2D( _MainTex, Sampler_LinearClamp, uv );
            }

            color /= imax-1;

			half br = max(color.x, max(color.y, color.z));
			half4 brColor = color * max(0, br) * _Bright;
			color += brColor;

			//float2 center = 0.5;
            float mask = length((input.uv * 2 - 1));
            mask = smoothstep(AreaRange.x, AreaRange.y, mask);
            
            half4 source = SAMPLE_TEXTURE2D(_RadialBlurSource, Sampler_LinearClamp, input.uv );
            
            return lerp(source, color, mask);
            
            return half4(color);
        }
        ENDHLSL
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment fragBlurFirst
            ENDHLSL
        }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment fragBlurAndBlend
            ENDHLSL
        }
    }
}
