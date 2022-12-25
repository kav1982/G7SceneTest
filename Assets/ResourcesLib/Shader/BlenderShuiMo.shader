Shader "Bioum/BlenderShuiMo"
{
    Properties
    {
        _BaseMap("Texture", 2D) = "white" {}
        
        _Hue("Hue", Range(0, 1)) = 0.5
        _Saturation("Saturation", Range(0, 2)) = 1
        _ValueMul("Value x", float) = 2.74
        _ValueAdd("Value +", float) = -1.58
        _HSVFac("HSVFac", Range(0, 1)) = 1

        [Toggle]_ZWrite("ZWrite", float) = 0
    }
    SubShader
    {
        Tags { "IgnoreProjector" = "True" "Queue" = "Transparent" "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite [_ZWrite]
        Cull off
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "ShaderLibrary/Color.hlsl"

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

            sampler2D _BaseMap;
            float4 _BaseMap_ST;
            half _Hue;
            half _Saturation;
            half _HSVFac;
            float _ValueMul;
            float _ValueAdd;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_BaseMap, i.uv);

                float3 hsv = RGB2HSV(col.rgb);
                hsv.r = frac(hsv.r + _Hue + 0.5);
                hsv.g = saturate(hsv.g * _Saturation);
                hsv.b = hsv.b * saturate(i.uv.x * _ValueMul + _ValueAdd);
                hsv = HSV2RGB(hsv);
                col.rgb = saturate(lerp(col.rgb, hsv, _HSVFac));

                clip(col.a - 0.1f);
                return col;
            }
            ENDHLSL
        }
    }
    CustomEditor "BlenderShuiMoEditor"
}
