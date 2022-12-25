Shader "DG/Bloom"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DownTex ("Albedo (RGB)", 2D) = "white" {}

        _SunMergeTex ("_SunMergeTex", 2D) = "white" {}
        _ColorLutTex ("_ColorLutTex", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off
		ZWrite Off ZTest Always
        
        // 0
        Pass
        {
            CGPROGRAM
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
                float4 vertex : POSITION;
                float4 vs_TEXCOORD0 : TEXCOORD0;
                float4 vs_TEXCOORD1 : TEXCOORD1;
            };
			
            sampler2D _MainTex;
			
            float4 _MainTex_TexelSize;      // 1/width, 1/height, width, height
			
            float _BloomThreshold;



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //float2 _MainTex_TexelSize = float2(0.00052, 0.0009259);

                o.vs_TEXCOORD0.xy = v.uv - _MainTex_TexelSize.xy;
                o.vs_TEXCOORD0.zw = v.uv + _MainTex_TexelSize.xy * float2(1.0, -1.0);
                
                o.vs_TEXCOORD1.xy = v.uv + _MainTex_TexelSize.xy * float2(-1.0, 1.0);
                o.vs_TEXCOORD1.zw = v.uv + _MainTex_TexelSize.xy;
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //float _BloomThreshold = -1.0;

				float4 _u_xlat1;
				float3 _u_xlat0;
				float _u_xlat6;

				_u_xlat0.xyz = tex2D(_MainTex, i.vs_TEXCOORD0.xy).xyz;
				
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD0.zw).xyz;
				
				_u_xlat0.xyz = (_u_xlat0.xyz + _u_xlat1.xyz);
				
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD1.xy).xyz;
				
				_u_xlat0.xyz = (_u_xlat0.xyz + _u_xlat1.xyz);
				
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD1.zw).xyz;
				
				_u_xlat0.xyz = (_u_xlat0.xyz + _u_xlat1.xyz);
				
				_u_xlat0.xyz = (_u_xlat0.xyz * float3(0.25, 0.25, 0.25));
				
				_u_xlat0.xyz = max(_u_xlat0.xyz, float3(0.0, 0.0, 0.0));
				
				_u_xlat6 = dot(_u_xlat0.xyz, float3(0.3, 0.59, 0.11));
				
				_u_xlat6 = _u_xlat6 - _BloomThreshold;
				
				_u_xlat1.w = (_u_xlat6 * 0.5);
				
				_u_xlat1.w = clamp(_u_xlat1.w, 0.0, 1.0);
				
				_u_xlat1.xyz = (_u_xlat0.xyz * _u_xlat1.www);

                return _u_xlat1;
            }
            ENDCG
        }

        // 1
        Pass
        {
            CGPROGRAM
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
                float4 vertex : POSITION;
                float4 vs_TEXCOORD0 : TEXCOORD0;
                float4 vs_TEXCOORD1 : TEXCOORD1;
                float4 vs_TEXCOORD2 : TEXCOORD2;
                float4 vs_TEXCOORD3 : TEXCOORD3;
                float4 vs_TEXCOORD4 : TEXCOORD4;
                float4 vs_TEXCOORD5 : TEXCOORD5;
                float4 vs_TEXCOORD6 : TEXCOORD6;
                float4 vs_TEXCOORD7 : TEXCOORD7;
            };
			
            sampler2D _MainTex;

            float4 _MainTex_TexelSize;
			


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //float2 _MainTex_TexelSize = float2(0.00208, 0.0037);

				o.vs_TEXCOORD0.zw = _MainTex_TexelSize.xy * float2(0.16914538, 2.6345758) + v.uv.xy;
				
				o.vs_TEXCOORD0.xy = v.uv.xy;
				
				o.vs_TEXCOORD1.xy = _MainTex_TexelSize.xy * float2(1.2954943, 2.3002815) + v.uv.xy;
				o.vs_TEXCOORD1.zw = _MainTex_TexelSize.xy * float2(2.1652546, 1.5103884) + v.uv.xy;
				o.vs_TEXCOORD2.xy = _MainTex_TexelSize.xy * float2(2.6061599, 0.42134425) + v.uv.xy;
				o.vs_TEXCOORD2.zw = _MainTex_TexelSize.xy * float2(2.5308836, -0.75115216) + v.uv.xy;
				o.vs_TEXCOORD3.xy = _MainTex_TexelSize.xy * float2(1.9543345, -1.7748737) + v.uv.xy;
				o.vs_TEXCOORD3.zw = _MainTex_TexelSize.xy * float2(0.99070585, -2.4470599) + v.uv.xy;
				o.vs_TEXCOORD4.xy = _MainTex_TexelSize.xy * float2(-0.16914426, -2.6345761) + v.uv.xy;
				o.vs_TEXCOORD4.zw = _MainTex_TexelSize.xy * float2(-1.2954937, -2.3002818) + v.uv.xy;
				o.vs_TEXCOORD5.xy = _MainTex_TexelSize.xy * float2(-2.1652544, -1.5103887) + v.uv.xy;
				o.vs_TEXCOORD5.zw = _MainTex_TexelSize.xy * float2(-2.6061597, -0.42134529) + v.uv.xy;
				o.vs_TEXCOORD6.xy = _MainTex_TexelSize.xy * float2(-2.5308836, 0.7511518) + v.uv.xy;
				o.vs_TEXCOORD6.zw = _MainTex_TexelSize.xy * float2(-1.9543352, 1.774873) + v.uv.xy;
				o.vs_TEXCOORD7.xy = _MainTex_TexelSize.xy * float2(-0.99070626, 2.4470599) + v.uv.xy;
				o.vs_TEXCOORD7.zw = float2(0.0, 0.0);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float3 _u_xlat0, _u_xlat1;
				
				_u_xlat0.xyz = tex2D(_MainTex, i.vs_TEXCOORD0.zw).xyz;
				_u_xlat0.xyz = _u_xlat0.xyz * float3(0.06666667, 0.06666667, 0.06666667);
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD0.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD1.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD1.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD2.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD2.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD3.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD3.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD4.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD4.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD5.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD5.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD6.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD6.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD7.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * float3(0.06666667, 0.06666667, 0.06666667)) + _u_xlat0.xyz;
				
                return float4(_u_xlat0.xyz, 0);
            }
            ENDCG
        }

        // 2
        Pass
        {
            CGPROGRAM
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
                float4 vertex : POSITION;
                float4 vs_TEXCOORD0 : TEXCOORD0;
                float4 vs_TEXCOORD1 : TEXCOORD1;
                float4 vs_TEXCOORD2 : TEXCOORD2;
                float4 vs_TEXCOORD3 : TEXCOORD3;
                float4 vs_TEXCOORD4 : TEXCOORD4;
                float4 vs_TEXCOORD5 : TEXCOORD5;
                float4 vs_TEXCOORD6 : TEXCOORD6;
                float4 vs_TEXCOORD7 : TEXCOORD7;
            };
			
            sampler2D _MainTex;
            sampler2D _DownTex;

            float4 _MainTex_TexelSize;
            float4 _DownTex_TexelSize;
			
			float3 _TintA;
			float3 _TintB;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				
                //float2 _MainTex_TexelSize = float2(0.03333, 0.0625);
                //float2 _DownTex_TexelSize = float2(0.016666, 0.030303);

				o.vs_TEXCOORD0 = _DownTex_TexelSize.xyxy * float4(0.33482406, 1.2768292, 1.2070246, 0.53431422) + v.uv.xyxy;
				o.vs_TEXCOORD1 = _DownTex_TexelSize.xyxy * float4(1.1703112, -0.6105504, 0.25232974, -1.2956581) + v.uv.xyxy;
				o.vs_TEXCOORD2 = _DownTex_TexelSize.xyxy * float4(-0.85566092, -1.0051092, -1.3193219, 0.042307131) + v.uv.xyxy;
				o.vs_TEXCOORD3.xy = _DownTex_TexelSize.xy * float2(-0.78950685, 1.0578654) + v.uv.xy;
				
				o.vs_TEXCOORD3.zw = v.uv.xy;
				
				o.vs_TEXCOORD4 = _MainTex_TexelSize.xyxy * float4(0.33482406, 1.2768292, 1.2070246, 0.53431422) + v.uv.xyxy;
				o.vs_TEXCOORD5 = _MainTex_TexelSize.xyxy * float4(1.1703112, -0.6105504, 0.25232974, -1.2956581) + v.uv.xyxy;
				o.vs_TEXCOORD6 = _MainTex_TexelSize.xyxy * float4(-0.85566092, -1.0051092, -1.3193219, 0.042307131) + v.uv.xyxy;
				
				o.vs_TEXCOORD7.xy = _MainTex_TexelSize.xy * float2(-0.78950685, 1.0578654) + v.uv.xy;
				o.vs_TEXCOORD7.zw = float2(0.0, 0.0);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float3 _u_xlat0, _u_xlat1;
				
				//float3 _TintA = float3(0.067217, 0.067217, 0.067217);
				//float3 _TintB = float3(0.00825, 0.00825, 0.00825);

				_u_xlat0.xyz = tex2D(_DownTex, i.vs_TEXCOORD0.zw).xyz;
				_u_xlat0.xyz = _u_xlat0.xyz * _TintA.xyz;
				_u_xlat1.xyz = tex2D(_DownTex, i.vs_TEXCOORD0.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintA.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_DownTex, i.vs_TEXCOORD1.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintA.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_DownTex, i.vs_TEXCOORD1.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintA.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_DownTex, i.vs_TEXCOORD2.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintA.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_DownTex, i.vs_TEXCOORD2.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintA.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_DownTex, i.vs_TEXCOORD3.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintA.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_DownTex, i.vs_TEXCOORD3.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintA.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD3.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintB.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD4.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintB.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD4.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintB.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD5.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintB.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD5.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintB.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD6.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintB.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD6.zw).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintB.xyz) + _u_xlat0.xyz;
				_u_xlat1.xyz = tex2D(_MainTex, i.vs_TEXCOORD7.xy).xyz;
				_u_xlat0.xyz = (_u_xlat1.xyz * _TintB.xyz) + _u_xlat0.xyz;
				
                return float4(_u_xlat0.xyz, 0);
            }
            ENDCG
        }

		// 3
        Pass
        {
            CGPROGRAM
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
                float4 vertex : POSITION;
                float4 vs_TEXCOORD0 : TEXCOORD0;
                float4 vs_TEXCOORD1 : TEXCOORD1;
                float4 vs_TEXCOORD2 : TEXCOORD2;
                float4 vs_TEXCOORD3 : TEXCOORD3;
            };
			
            sampler2D _MainTex;
            sampler2D _DownTex;

            float4 _DownTex_TexelSize;
			
			float3 _BloomColor;
			
			float _VignetteIntensity;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				
				//float2 _DownTex_TexelSize = float2(0.0041667, 0.0074074);
				//float2 _ScreenParams = float2(1600, 900);
				
				float4 _u_xlat0, _u_xlat1;
				float2 _u_xlat4;
				
				_u_xlat4.x = 1.0;
				_u_xlat1.x = 1.0 / _ScreenParams.x;
				_u_xlat4.y = _u_xlat1.x * _ScreenParams.y;
				_u_xlat0.xy = _u_xlat4.xy * o.vertex.xy;
				_u_xlat4.x = (_u_xlat4.y * _u_xlat4.y) + 1.0;
				_u_xlat4.x = sqrt(_u_xlat4.x);
				_u_xlat4.x = 1.4142135 / _u_xlat4.x;
				_u_xlat0.xy = _u_xlat4.xx * _u_xlat0.xy;
				
				o.vs_TEXCOORD0.zw = _u_xlat0.xy;
				o.vs_TEXCOORD0.xy = v.uv.xy;
				
				_u_xlat0 = (_DownTex_TexelSize.xyxy * float4(0.11286663, 0.31009859, 0.32498658, 0.057303991)) + v.uv.xyxy;
				o.vs_TEXCOORD1 = _u_xlat0;
				
				_u_xlat0 = (_DownTex_TexelSize.xyxy * float4(0.21212004, -0.25279456, -0.11286644, -0.31009865)) + v.uv.xyxy;
				o.vs_TEXCOORD2 = _u_xlat0;
				
				_u_xlat0 = (_DownTex_TexelSize.xyxy * float4(-0.32498652, -0.057304196, -0.21212021, 0.25279444)) + v.uv.xyxy;
				o.vs_TEXCOORD3 = _u_xlat0;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				//float3 _BloomColor = float3(0.5, 0.5, 0.5);
				//float _VignetteIntensity = 0.4;
			
				float3 _u_xlat16_0, _u_xlat16_1, _u_xlat16_2;
				float _u_xlat0, _u_xlat16_11;
				
				_u_xlat16_0.xyz = tex2D(_MainTex, i.vs_TEXCOORD0.xy).xyz;
				_u_xlat16_1.xyz = tex2D(_MainTex, i.vs_TEXCOORD1.xy).xyz;

				_u_xlat16_0.xyz = _u_xlat16_0.xyz + _u_xlat16_1.xyz;

				_u_xlat16_1.xyz = tex2D(_MainTex, i.vs_TEXCOORD1.zw).xyz;
				_u_xlat16_0.xyz = _u_xlat16_0.xyz + _u_xlat16_1.xyz;
				_u_xlat16_1.xyz = tex2D(_MainTex, i.vs_TEXCOORD2.xy).xyz;
				_u_xlat16_0.xyz = _u_xlat16_0.xyz + _u_xlat16_1.xyz;
				_u_xlat16_1.xyz = tex2D(_MainTex, i.vs_TEXCOORD2.zw).xyz;
				_u_xlat16_0.xyz = _u_xlat16_0.xyz + _u_xlat16_1.xyz;
				_u_xlat16_1.xyz = tex2D(_MainTex, i.vs_TEXCOORD3.xy).xyz;
				_u_xlat16_0.xyz = _u_xlat16_0.xyz + _u_xlat16_1.xyz;
				_u_xlat16_1.xyz = tex2D(_MainTex, i.vs_TEXCOORD3.zw).xyz;

				_u_xlat16_0.xyz = _u_xlat16_0.xyz + _u_xlat16_1.xyz;
				_u_xlat16_2.xyz = _u_xlat16_0.xyz * 0.14285715;

				_u_xlat16_0.xyz = tex2D(_DownTex, i.vs_TEXCOORD0.xy).xyz;
				
				_u_xlat16_2.xyz = _u_xlat16_2.xyz * _BloomColor.xyz + _u_xlat16_0.xyz;
				_u_xlat16_2.xyz = _u_xlat16_2.xyz * 0.2;
				_u_xlat16_0.xy = i.vs_TEXCOORD0.zw * _VignetteIntensity;
				_u_xlat16_0.x = dot(_u_xlat16_0.xy, _u_xlat16_0.xy);
				_u_xlat0 = _u_xlat16_0.x + 1.0;
				_u_xlat0 = 1.0 / _u_xlat0;
				_u_xlat16_11 = _u_xlat0 * _u_xlat0;
				
                return float4(_u_xlat16_11 * _u_xlat16_2.xyz, _u_xlat16_11);
            }
            ENDCG
        }
		
		// 4
        Pass
        {
            CGPROGRAM
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
                float4 vertex : POSITION;
                float2 vs_TEXCOORD0 : TEXCOORD0;
            };
			
            sampler2D _MainTex;
            sampler2D _SunMergeTex;

            float _ExposureValue;



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.vs_TEXCOORD0 = v.uv;
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {

                float3 mainCol = tex2D(_MainTex, i.vs_TEXCOORD0.xy).xyz;

                //曝光
                mainCol *= _ExposureValue;
                
                float4 sunMerge = tex2D(_SunMergeTex, i.vs_TEXCOORD0.xy);
                
                mainCol = (mainCol * sunMerge.w) + sunMerge.xyz;
                
                mainCol.xyz = clamp(mainCol.xyz, 0.0, 1.0);
                
                return float4(mainCol.xyz, 1.0);
            }
            ENDCG
        }

		// 5
        Pass
        {
            CGPROGRAM
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
                float4 vertex : POSITION;
                float2 vs_TEXCOORD0 : TEXCOORD0;
            };
			
            sampler2D _MainTex;
            sampler2D _SunMergeTex;
            sampler2D _ColorLutTex;

            float _ExposureValue;



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.vs_TEXCOORD0 = v.uv;
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {

                float3 mainCol = tex2D(_MainTex, i.vs_TEXCOORD0.xy).xyz;

                //曝光
                mainCol *= _ExposureValue;
                
                float4 sunMerge = tex2D(_SunMergeTex, i.vs_TEXCOORD0.xy);
                
                mainCol = (mainCol * sunMerge.w) + sunMerge.xyz;
                
                mainCol.xyz = clamp(mainCol.xyz, 0.0, 1.0);
                
                float bScale = mainCol.b * 31.0;
                float bScaleInt = floor(bScale);

                float2 uv0, uv1;

                //0.96875: 31/32;   0.015625: 1/64;     0.03125: 1/32
                uv0.x = ( ( mainCol.r * 0.96875 + 0.015625 ) + bScaleInt ) * 0.03125;
                uv0.y = mainCol.g * 0.96875 + 0.015625;

                uv1.x = uv0.x + 0.03125;
                uv1.y = uv0.y;

                float3 ColorLut0 = tex2D(_ColorLutTex, uv0).xyz;
                float3 ColorLut1 = tex2D(_ColorLutTex, uv1).xyz;
                

                float4 col;
                col.xyz = ( ( bScale - bScaleInt ) * ( ColorLut1 - ColorLut0 ) ) + ColorLut0;
                col.w = 1.0;

                return col;
            }
            ENDCG
        }
        
    }
}
