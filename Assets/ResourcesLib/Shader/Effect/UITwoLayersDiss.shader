Shader "Bioum/UI/TwoLayerDissovle"
{
    Properties
    {
        [Header(Layer1)]
        [Space]
        _MainTex ("Texture", 2D) = "white" {}
        _Progress ("Progress", range(-1, 1)) = 0
        _Line1Pos ("Line 1 Pos", range(0, 1)) = 0.1
        _Line1Width ("Line 1 Width", range(0, 1)) = 0.9
        [HDR]_Line1Color ("Line 1 Color", Color) = (1,1,1,1)
        _Line1Bri ("Line 1 Brightness", float) = 1 
        
        [Space(20)]
        [Header(Layer2)]
        [Space]
        _ProgressAdd ("Progress Add", range(0, 1)) = 0.1
        [HDR]_Layer2Color ("Layer 2 Color", Color) = (1,1,1,1)
        _Layer2Width ("Layer 2 Width", range(0, 5)) = 0.1
        _Layer2Bri ("Layer 2 Brightness", float) = 0.1
        _Line2Pos ("Line 2 Pos", range(-2, 1)) = 0.1
        _Line2Width ("Line 2 Width", range(0, 1)) = 0.9
        [HDR]_Line2Color ("Line 2 Color", Color) = (1,1,1,1)
        _Line2Bri ("Line 2 Brightness", float) = 1 
        
        [Space(20)]
        _ColorTex ("Color", 2D) = "white" {}
        _Noise ("Noise", float) = 50
        
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
        ZWrite Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "../ShaderLibrary/Common.hlsl"

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

            sampler2D _MainTex;

            sampler2D _ColorTex;

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _Progress;
            float _Line1Pos;
            float _Line1Width;
            float4 _Line1Color;
            float _Line1Bri;

            float _ProgressAdd;
            float4 _Layer2Color;
            float _Layer2Width;
            float _Layer2Bri;
            float _Line2Pos;
            float _Line2Width;
            float4 _Line2Color;
            float _Line2Bri;

            float4 _ColorTex_ST;
            float _Noise;
            CBUFFER_END

            // float remap(float a, float2 InMinMax, float2 OutMinMax)
            // {
            //     float x = OutMinMax.x + (a - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            //     return x;
            // }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float4 albedo = tex2D(_MainTex, i.uv);

                float dis = 1.0 - length(uv - float2(0.5, 0.5));
                float noise1 = SimpleNoise(uv, _Noise);
                noise1 = remap(noise1,float2(0, 1), float2(0.5, 1)) * dis;

                float main_prog = noise1 - _Progress;
                float main_mask = smoothstep(0, 0.01, main_prog) * albedo.a;
                float3 layer1_col = albedo.rgb * main_mask;

                float line1 = 1.0 - length(main_prog - _Line1Pos * 0.1);
                line1 = saturate(smoothstep(0.9 + _Line1Width * 0.1, 1, line1)) * albedo.a;
                //float3 line1Col = line1 * _Line1Color.rgb * _Line1Bri ;

                float noise2 = SimpleNoise(uv, _Noise + _SinTime.x * 10);
                float line2noise = smoothstep(0.4, 1, noise2);
                noise2 = remap(noise2,float2(0, 1), float2(0.5, 1)) * dis;

                float layer2_prog = noise2 - (_Progress + _ProgressAdd * 0.1);
                float layer2_mask = smoothstep(0.5 + _Layer2Width * 0.1, 1.0, 1.0 - length(layer2_prog)) * albedo.a * (1 - main_mask) ;
                float layer2 = max(albedo.r, max(albedo.g, albedo.b)) * layer2_mask;
                layer2 = saturate(remap(layer2, float2(0.2, 1), float2(0, 1)) * layer2_mask * _Layer2Bri);
                float3 layer2_col = layer2  *_Layer2Color.rgb;
                
                float line2 = 1.0 - length(layer2_prog - _Line2Pos * 0.1);
                line2 = saturate(smoothstep(0.9 + _Line2Width * 0.1, 1, line2)) * line2noise  * albedo.a;
                float3 line2_col = line2 * _Line2Color.rgb * _Line2Bri ;
               
                float alpha = max(max(main_mask, line1 * _Line1Bri) ,max(layer2 * _Layer2Bri, line2 * _Line2Bri));
                

                float3 color1 = tex2D(_ColorTex, line1 * _ColorTex_ST.xy + _ColorTex_ST.zw).rgb * line1 * _Line1Bri * _Line1Color.rgb;
                float3 color2 = tex2D(_ColorTex, line2 * _ColorTex_ST.xy + _ColorTex_ST.zw).rgb * line2 * _Line2Bri * _Line2Color.rgb;

                float3 col = layer1_col + color1 + layer2_col + color2;
                
                return half4(col, alpha);
                // apply fog
               
            }
            ENDHLSL
        }
    }
}
