Shader "Bioum/Effect/LavaX"
{
    Properties
    {
         [Space]
        _MainTex ("Texture", 2D) = "white" {}
        _MainTexSpeedX ("MainTex Speed X", float) = 0.1
        _MainTexSpeedY ("MainTex Speed Y", float) = 0.1
        
        [Space]
        [Header(FlowMap)]
        [Space]
        _FlowMap ("Flow Map", 2D) = "white" {}
        _FlowTiling ("Flow Tiling", float) = 8
        _FlowSpeedX ("Flow Speed X", float) = 0.1
        _FlowSpeedY ("Flow Speed Y", float) = 0.1
        _FlowPower ("Flow Power", float) = 0.1
        
        [Space]
        [Header(FlowLight)]
        [Space]
        _LightMask ("Light Mask", 2D) = "white" {}
        _LightNoise ("Light Noise", 2D) = "white" {}
        _NoiseTilingAndSpeed ("Noise Tiling And Speed", vector) = (1,1,0,0)
        
        _EdgeColor("EdgeColor",Color) = (1,1,1,1)
        _EdgePow("EdgePow",float) = 0.5
        _EdgeAtten("EdgeAtten",range(0,1)) = 0.5
        
        [Space(20)]
        [HDR]_BaseColor ("Base Color", color) = (1,1,1,1)
        [HDR]_LightColor ("Light Color", color) = (0,0,0,0)
         
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"
        }
        Name "ForwardBase"
        Tags{"LightMode" = "UniversalForward"}

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
        	ZTest LEqual
			ColorMask RGBA
            
            HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

            #pragma shader_feature_local _ _NORMALMAP
            #pragma shader_feature_local __ HEIGHT
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "ShaderLibrary/Common.hlsl"
            #include "ShaderLibrary/SurfaceStruct.hlsl"
            #include "ShaderLibrary/lightingCommon.hlsl"
            #pragma multi_compile_fog

           struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 color : COLOR;
                half2 lightmapUV: TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS: SV_POSITION;
                half4 uv: TEXCOORD0;
                DECLARE_GI_DATA(lightmapUV, vertexSH, 1);
                float4 positionWSAndFog: TEXCOORD2;
                float4 tangentWS: TEXCOORD4;    // xyz: tangent, w: viewDir.x
                float4 bitangentWS: TEXCOORD5;    // xyz: binormal, w: viewDir.y
                float4 normalWS: TEXCOORD3;    // xyz: normal, w: viewDir.z
                float4 positionNDC : TEXCOORD6;
                float4 positionOS : TEXCOORD7;
                DECLARE_SHADOWCOORD(shadowCoord, 8)	
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_MainTex);     SAMPLER(sampler_MainTex);
            TEXTURE2D(_FlowMap);     SAMPLER(sampler_FlowMap);
            TEXTURE2D(_LightMask);     SAMPLER(sampler_LightMask);
            TEXTURE2D(_LightNoise);     SAMPLER(sampler_LightNoise);
            
           
            float4 _MainTex_ST;
            float4 _NormalTex_ST;
            float _MainTexSpeedX;
            float _MainTexSpeedY;

            float _FlowTiling;
            float _FlowSpeedX;
            float _FlowSpeedY;
            float _FlowPower;

            float4 _BaseColor;
            float4 _LightColor;

            float4 _NoiseTilingAndSpeed;

            half4 _EdgeColor;
            half _EdgePow;
            half _EdgeAtten;

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.uv.xy = TRANSFORM_TEX(input.uv, _MainTex);
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

                float3 tangentWS = float3(1,0,0), binormalWS = float3(0,0,1), normalWS = float3(0,1,0);

                output.positionWSAndFog.xyz = positionWS;
                
                output.positionCS = TransformWorldToHClip(output.positionWSAndFog.xyz);
                
                half3 viewDirWS = _WorldSpaceCameraPos - output.positionWSAndFog.xyz;
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);
                output.tangentWS = float4(normalInput.tangentWS, viewDirWS.x);
                output.bitangentWS = float4(normalInput.bitangentWS, viewDirWS.y);
                output.normalWS = float4(normalInput.normalWS, viewDirWS.z);
                
               
                float4 ndc = output.positionCS * 0.5f;
                output.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
                output.positionNDC.zw = output.positionCS.zw;
                output.positionNDC.z = -TransformWorldToView(output.positionWSAndFog.xyz).z;
                
                OUTPUT_GI_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                OUTPUT_GI_SH(output.normalWS.xyz, output.vertexSH);
                OUTPUT_SHADOWCOORD(positionWS, output.positionCS, output.shadowCoord);
                output.positionOS = input.positionOS;

                return output;
            }
            
           

            half4 frag(Varyings input): SV_TARGET
            {
                Surface surface = (Surface)0;

                //DepthEdge
                float3 positionSS = input.positionNDC.xyz / input.positionNDC.w;
                float depth = SampleSceneDepth(positionSS.xy); 
	            float sceneZ = LinearEyeDepth(depth, _ZBufferParams);
	            float thisZ = input.positionNDC.z;
	            float edge = 1-saturate(sceneZ - thisZ - _EdgePow);
                //edge = 1-saturate(pow((sceneZ - thisZ),_EdgePow));
                edge = smoothstep(_EdgeAtten,1,edge);
                float3 edgeCol = edge * _EdgeColor.rgb;
                //return edge*_EdgeColor;
                //float3  edgeCol = saturate(_EdgeColor.rgb * (1 - edge));
                

                //UV Flow
                float2 noise_uv = input.uv.xy * _FlowTiling + _Time.y * float2(_FlowSpeedX, _FlowSpeedY);                
                float2 noise = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, noise_uv).rg * _FlowPower;

                //Albedo
                float2 uv = input.uv.xy + _Time.y * float2(_MainTexSpeedX, _MainTexSpeedY) + noise;
                half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) + _BaseColor;
                albedo.rgb += edgeCol;
                //half heighLight = (albedo.r + albedo.g+ albedo.b)*0.33f;

                float colorlerp = smoothstep(0, 0.05, SAMPLE_TEXTURE2D(_LightMask, sampler_LightMask, uv).r);
                float2 light_uv = input.uv.xy * _NoiseTilingAndSpeed.xy + _Time.y * _NoiseTilingAndSpeed.zw;
                float3 flow = SAMPLE_TEXTURE2D(_LightNoise, sampler_LightNoise, light_uv).r * _LightColor.rgb *  colorlerp;
                //return half4(flow,1);
                albedo.rgb += flow;
                
                half alpha = albedo.a * (1-edge);
                return half4(albedo.rgb,alpha);
                
            }
            ENDHLSL
        }
    }
}