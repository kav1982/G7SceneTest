Shader "Bioum/UI/Page"
{
    Properties
    {
        // required for UI.Mask
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15
        // end
        
        [Space(40)]
        _MainTex ("Texture", 2D) = "white" {}
        _BackTex ("BackTex", 2D) = "white" {}
        _MaskTex ("MaskTex", 2D) = "white" {}
        _Radius ("Radius", Range(0,1)) = 0.1
        _DirX ("Direction X", Float) = 0 
        _DirY ("Direction Y", Float) = 0 
        _Progress ("Progress", Float) = 0 
        _ShadowColor ("Shadow Color", color) = (0,0,0,0)
        _ShadowRange ("Shadow Range(XY ZW))", vector) = (0.3,2.0,0,1.5)
  
    }
    SubShader
    {
        Tags{ 
            "RenderType" = "Transparent"  
            "Queue" = "Transparent" 
            "IgnoreProjector" = "True" 
            "PreviewType"="Plane"
        }

         // required for UI.Mask
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        // end

		Cull Off
		Lighting Off
		ZWrite Off
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
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_MainTex);
            TEXTURE2D(_BackTex);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_BackTex);
            SAMPLER(sampler_MaskTex);

            CBUFFER_START(UnityPerMaterial)
            half _Radius;
            half4 _ShadowColor;
            half4 _ShadowRange;
            half _DirX;
            half _DirY;
            half _Progress;
            CBUFFER_END
            
            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID (v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                
                half2 uv = i.uv;

                //卷页方向
                half2 direction = half2(_DirX * 0.1 ,_DirY * 0.1);
                half radius = _Radius * 0.1;
                half t = distance(mul(clamp(radius, 0.0, 1.0) * 4.0 + 1.0, direction), radius * 2.0);
                
                half dir = dot(uv + _Progress, normalize(direction));
                half2 divide =  (1 - uv) / normalize(direction);
                half curve_divi = min(divide.x, divide.y) + dir;
                 if(_DirY <= 0)
                {
                    dir = 1 -  dot( 1 - uv - _Progress, normalize(direction));
                    divide = abs( half2(1 - uv.x, uv.y) / normalize(direction));
                    curve_divi =  min(divide.x, divide.y) + dir;
                }      

                half shadow = 0.0;
                half2 gv = half2(0.0, 0.0);
                half isback = 0.0;

                //卷页正面
                if(dir < t - radius)
                {
                    gv = half2(dir, 1.0);
              
                }
                //卷页后面
                else if(dir > t + radius)
                {
                    gv = half2(-1.0, -1.0);
                   
                }
                //卷起部分
                else
                {
                    half eage = asin((dir - t) / radius);
                    half ceage = -eage + 3.141592;
                    gv.x = t + ceage * radius;
                    gv.y = cos(ceage);
                    
                    //卷页前面阴影
                    if(gv.x < curve_divi)
                    {
                        isback = 1.0;
                        shadow = clamp(0.0, 1.0,smoothstep(_ShadowRange.x, _ShadowRange.y, abs(eage)));
                     
                    }
                    
                    if(gv.x >= curve_divi)
                    {
                        
                        if(dir < t)
                        {
                            gv = half2(dir, 1.0);
                        }
                        else
                        {
                            
                            gv.y = cos(eage);
                            gv.x = t + eage * radius;

                            shadow = clamp(0.0, 1.0,smoothstep(_ShadowRange.z, _ShadowRange.w, 1.0 - gv.y));                      
  
                            if(gv.x >= curve_divi)
                            {
                                gv = half2(-1.0, -1.0);         
                            }
                        }
                    }
                }

                half front_curve = clamp(max(gv.x, gv.y) * 2.0, 0.0, 1.0);           
                half2 front_uv = front_curve * uv ;          
                half2 curve_uv = front_uv + (gv.x - dir) * normalize(direction);
                
                half2  front_curve_uv = front_uv + (gv.x - dir) * normalize(direction) * (1 - isback);     
                half4 front_curve_col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, front_curve_uv);
                half4 back_curve_col = SAMPLE_TEXTURE2D(_BackTex, sampler_BackTex, curve_uv);
    
                half mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, curve_uv).r;
                half3 finalcol = lerp(front_curve_col.rgb, back_curve_col.rgb, isback * mask);

                shadow *= mask;
               
                mask = front_curve * max(front_curve_col.a, back_curve_col.a) * i.color.a;
                
                finalcol = lerp(finalcol, _ShadowColor.xyz * mask, shadow) * i.color.rgb;
             
                return half4(finalcol,mask);
            }
            ENDHLSL
        }
    }
}
