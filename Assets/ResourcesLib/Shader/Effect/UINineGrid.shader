Shader "Bioum/UI/NineGrid"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	_MaskTex ("Mask Tex", 2D) = "white" {}
    	_Color ("Gray Color", Color) = (1,1,1,1)
    	
    	[Space(20)]
        [Header(Scale)]
    	[Space(10)]
    	_ImageSizeX ("Image Size X", float) = 1
    	_ImageSizeY ("Image Size Y", float) = 1
        _Size ("Tex Size", float) = 5
        _PositionX ("Position X", float) = 0.5
    	_PositionY ("Position Y", float) = 0.5
        _ScaleX ("Scale X", float) = 1
    	_ScaleY ("Scale Y", float) = 1
    	
    	[Header(Flow Light)]
    	[Space(10)]
        _NoiseTex ("Noise Tex", 2D) = "white" {}
    	_SpeedX ("Flow SpeedX", float) = 0.2
    	_SpeedY ("Flow SpeedY", float) = 0.2
    	_Lightness ("Flow Lightness", float) = 2
    	_FlowColor ("Flow Color", Color) = (1,1,1,1)
        
    	[Space(20)]
        [Header(Nine Grid)]
    	[Space(10)]
        _LineX_1 ("LineX 1", range(0, 1)) = 0.1 
        _LineX_2 ("LineX 2", range(0, 1)) = 0.9 
        _LineY_1 ("LineY 1", range(0, 1)) = 0.1
        _LineY_2 ("LineY 2", range(0, 1)) = 0.9 
        
    	
    }
    SubShader
    {
        Tags
    	{ 
    		"RenderType" = "Transparent"  
    		"Queue" = "Transparent" 
    		"IgnoreProjector" = "True"
    		"PreviewType"="Plane"
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

            TEXTURE2D(_MainTex);
            TEXTURE2D(_MaskTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_MaskTex);
            SAMPLER(sampler_NoiseTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NoiseTex_ST;
            float _SpeedX;
            float _SpeedY;
            float _Lightness;
    		float4 _Color;
            float4 _FlowColor;
            float _LineX_1; 
			float _LineX_2;
			float _LineY_1;
			float _LineY_2;
			float _ScaleX;
            float _ScaleY;
            float _Size;
            float _PositionX;
            float _PositionY;
            float _ImageSizeX;
            float _ImageSizeY;
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

            //九宫格切割
            float nine_grid(float uv, float line1, float line2, float scale)
            {
				float sxl = step(line1, uv);
				float sxr = step(line2, uv);
				
				float lx = uv * scale * (1 - sxl) + sxl * max(line1, uv);
				float rx = (uv * scale - (scale - 1)) * sxr + (1 - sxr) * min(line2, uv);
				
				if (uv < line1)
				{
					uv = uv > line1 / scale ? line1 : lx;	
				}
				else if (uv > line2) 
				{
					uv = uv < (1 - (1-line2) / scale) ? line2 : rx;
				}
			
				return uv;
			}

            float scalecenter(float2 uv)
            {
            	float x = max(step(-0.01, uv.x), step(uv.x, 1.01));
            	float y = max(step(-0.01, uv.y), step(uv.y, 1.01));
            	float alpha = max(x, y);
	            return alpha;
            }

            half4 frag (v2f i) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(i);
            	
				float2 uv = i.uv;

            	float2 scaleuv = float2(0,0);
            	float2 griduv = float2(0,0);
            	float2 centerpos = float2(_PositionX, _PositionY);
            	float2 gv = (uv - centerpos) * float2(_ScaleX, _ScaleY)  + centerpos;

            	float albedo_area = scalecenter(gv);
            	scaleuv.xy = gv * albedo_area;
	
            	float x_y = _ImageSizeX / _ImageSizeY;
            	griduv.x = nine_grid(scaleuv.x, _LineX_1, _LineX_2, 1/_ScaleX * _Size * x_y);
            	griduv.y = nine_grid(scaleuv.y, _LineY_1, _LineY_2, 1/_ScaleY * _Size);
            	
                half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, griduv);

            	float2 polar_uv;
            	polar_uv.x = atan2(scaleuv.x - 0.5, scaleuv.y - 0.5) / 6.28301 + 0.5;
            	polar_uv.y = distance(scaleuv.xy, float2(0.5, 0.5));

            	polar_uv = polar_uv * _NoiseTex_ST.xy + float2(_SpeedX, _SpeedY) * _Time.y;
            	
				float light = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, polar_uv).r * _Lightness;

            	half mask = smoothstep(0.01, 0.95, max(1 - SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, griduv).r, 1 - albedo_area));

            	albedo.rgb = light * albedo.rgb * _FlowColor.rgb + albedo.rgb;

            	float alpha = max( albedo.a, mask * _Color.a);

            	half3 col = lerp(albedo.rgb, _Color.rgb, mask);
                
                return half4(col, alpha);
            }
            ENDHLSL
        }
    }
}
