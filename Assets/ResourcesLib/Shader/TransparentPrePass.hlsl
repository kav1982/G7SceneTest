

struct Attributes
{
    float3 positionOS: POSITION;
    real3 normalOS: NORMAL;
    real2 texcoord: TEXCOORD0;
    half4 color : COLOR;
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    real2 uv: TEXCOORD0;
    real3 normalWS: TEXCOORD1;
    half4 vColor : TEXCOORD2;
};

Varyings TransparentPrePassVert(Attributes input)
{
    Varyings output = (Varyings)0;
    
    float3 positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);

    output.uv.xy = input.texcoord;
    output.vColor = input.color;
    output.vColor.r = LerpWhiteTo(output.vColor.r, GetAOStrength());
    
    return output;
}

half4 DitherFrag(Varyings input): SV_TARGET
{
    half4 tex = sampleBaseMap(input.uv.xy);
    half alpha = tex.a * GetTransparent();
    tex.rgb *= input.vColor.r;

    float dither = GetCheckerBoardDither(input.positionCS.xy);
    clip(PositivePow(alpha, GetCutoff() * 10) - dither);
    
    return half4(tex.rgb, 1);
}
