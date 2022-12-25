#ifndef BIOUM_OUTLINE_PASS_INCLUDE
#define BIOUM_OUTLINE_PASS_INCLUDE

struct Attributes
{
    float4 positionOS: POSITION;
    float3 normalOS: NORMAL;
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
};

Varyings OutlineVert(Attributes input)
{
    Varyings output = (Varyings)0;

    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    positionWS += normalWS * _OutlineColor.a;
    output.positionCS = TransformWorldToHClip(positionWS);
    
    return output;
}

half4 OutlineFrag(Varyings input): SV_TARGET
{
    return half4(_OutlineColor.rgb,1);
}


#endif // BIOUM_OUTLINE_PASS_INCLUDE