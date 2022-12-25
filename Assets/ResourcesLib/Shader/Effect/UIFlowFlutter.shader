Shader "Bioum/UI/FlowFlutter"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _FlowMap ("FlowMap", 2D) = "white" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _LiziTex ("LiziTex", 2D) = "white" {}
        _Progress ("Progress", Float) = 1.0
        _Director ("Director", vector) = (0,0,0,0)
        _Smooth ("Smooth", Float) = 0.1
    }
    SubShader
    {
        Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" "IgnoreProjector" = "True"}
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
             #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _FlowMap;
            float4 _FlowMap_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            sampler2D _LiziTex;
            float4 _LiziTex_ST;
            fixed _Progress;
            fixed4 _Director;
            fixed _Smooth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half remap(half x, half t1, half t2, half s1, half s2)
            {
                return (x - t1)/ (t2 - t1) * (s2 - s1) + s1;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
               
                fixed4 flowmap = tex2D(_FlowMap, i.uv);
                fixed4 noise = tex2D(_NoiseTex, i.uv);

                fixed progress = remap(_Progress, 0.0, 5.0, 0.0, 1.0);

                fixed flow_noise = clamp(0.0, 1.0, progress * 2.0 - (1.0 - flowmap.b));

                fixed flow_noisesmooth = smoothstep(0.0, 0.5, flow_noise) ;
        
                fixed2 dir = fixed2(remap(progress, 0.0, 1.0, _Director.x, _Director.y),
                    remap(progress, 0.0, 1.0, _Director.z, _Director.w));

                fixed2 flowuv = flowmap.rg * dir * flow_noisesmooth * noise.r;

                flowuv = lerp(i.uv, i.uv - flowuv, smoothstep(0.0, _Smooth, flow_noise));

                fixed4 lizi_tex = tex2D(_LiziTex, flowuv);

                fixed liziflow = smoothstep(0.0, 0.2, lizi_tex.r) + pow(smoothstep(0.1, 0.5, lizi_tex.g), 0.2);

                liziflow *= smoothstep(0.05, 0.5,tex2D(_LiziTex, i.uv - progress * 1).g + 0.2);

                fixed4 albedo = tex2D(_MainTex, flowuv);

                albedo.a = albedo.a * ( 1.0 - clamp(0.0, 1.0, flow_noisesmooth));

                fixed4 col = lerp(albedo, albedo * liziflow, smoothstep(0.0, 0.02, flow_noise));

                fixed lizi = pow(tex2D(_LiziTex, i.uv - progress * 1).b, 2.0) * albedo.a;

                lizi = smoothstep(0.0, 0.5, lizi) * tex2D(_MainTex, i.uv).b;

                lizi *= (1.0 - clamp(0.0, 1.0, flow_noisesmooth)) * clamp(0.0, 1.0, smoothstep(0.0, 0.02, flow_noise));

                col += lizi;

                col *= noise.g;

            
                return fixed4(col);
            }
            ENDCG
        }
    }
}
