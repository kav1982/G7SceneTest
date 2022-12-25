Shader "X7/WarFog/WarEyes_R"
{
    Properties
    {
        [Toggle(FOG_SELECT_ANI)]_SelectAni("Select Ani", Float) = 0
        [Toggle(FOG_SHOW_ANI)]_ShowAni("Show Ani", Float) = 0
        _ShowAniPos("Ani Pos xyz:pos w:maxDis", Vector) = (0, 0, 0, 0)
        _ShowAniPlayed("Ani Played", Range(0, 1)) = 0
        //MASK SUPPORT ADD
        _Stencil("Stencil ID", Float) = 0
        _StencilComp("Stencil Comparison", Float) = 8
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        //End 
    }
    SubShader
    {
        Tags { "Queue" = "Geometry-10" "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
		//ZTest off
		ZWrite off
        LOD 100
		ColorMask RB

        Pass
        {
            Tags{"LightMode" = "FogEye"}
            Stencil
            {
                Ref[_Stencil]
                Comp[_StencilComp]
                Pass[_StencilOp]
                ReadMask[_StencilReadMask]
                WriteMask[_StencilWriteMask]
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_instancing
            #pragma shader_feature_local _ FOG_SELECT_ANI
            #pragma multi_compile _ FOG_SHOW_ANI

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
				float4 vertex : SV_POSITION;
#if FOG_SHOW_ANI
                float3 worldPos : TEXCOORD0;
#endif
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

#if FOG_SHOW_ANI
            float4 _ShowAniPos;
            real _ShowAniPlayed;
#endif
			UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
#if FOG_SHOW_ANI
                o.worldPos.xyz = TransformObjectToWorld(v.vertex.xyz);
#endif
                return o;
            }

            real4 frag (v2f i) : SV_Target
            {
				UNITY_SETUP_INSTANCE_ID(i);
                real4 col = 1;
#if !FOG_SELECT_ANI
                col.b = 0;
#endif
#if FOG_SHOW_ANI
                float l = length(_ShowAniPos.xz - i.worldPos.xz);
                float v = _ShowAniPos.w * _ShowAniPlayed;
                col.r *= 1 - step(l, v) * abs(l - v) * _ShowAniPos.y;
#endif
				return col;
            }
            ENDHLSL
        }
    }
}
