#ifndef BIOUM_SSS_INCLUDE
#define BIOUM_SSS_INCLUDE


// 球面高斯SSS
// https://therealmjp.github.io/posts/sss-sg/
// https://cuihongzhi1991.github.io/blog/2020/05/11/sgsss/#more
// https://cuihongzhi1991.github.io/blog/2020/05/03/sg03/
// SphericalGaussian.ush
struct FSphericalGausian
{
    half3 Sharpness;
    half3 color;
    half nonClampNdotL;
};

half3 DotCosineLobe(FSphericalGausian SG)
{
    half muDotN = SG.nonClampNdotL;
    const half c0 = 0.36, c1 = 0.25 / c0;

    half3 eml = exp(-SG.Sharpness);
    half3 em2l = eml * eml;
    half3 rl = rcp(SG.Sharpness);

    half3 scale = 1 + 2 * em2l - rl;
    half3 bias = (eml - em2l) * rl - em2l;

    half3 x = sqrt(1 - scale);
    half3 x0 = c0 * muDotN;
    half3 x1 = c1 * x;

    half3 n = x0 + x1;
    half3 y = (abs(x0) <= x1) ? n * n / x : saturate(muDotN);

    half3 result = scale * y + bias;
    return (result);
}
half3 SGDiffuseLighting(half nonClampNdotL, half3 SSSColor)
{
    SSSColor *= SSSColor; //降低tonemapping后的颜色亮度
    
    FSphericalGausian rgbKernel;
    rgbKernel.Sharpness = rcp(max(SSSColor, 0.001));
    rgbKernel.color = SSSColor;
    rgbKernel.nonClampNdotL = nonClampNdotL;
    
    half3 diffuse = DotCosineLobe(rgbKernel);
    
    half3 x = max(0, diffuse - 0.004);
    half3 a = x * 6.2;
    half3 b = rcp(x * (a + 1.7) + 0.06);
    diffuse = x * (a + 0.5) * b;
    
    return diffuse;
}

half3 SimpleSSS(Surface surface, half3 sssColor, half3 lightDirWS, half dirDistort)
{
    half3 backLightDir = surface.normal * dirDistort + lightDirWS;
    half sss = saturate(dot(surface.view, -backLightDir) * 0.5 + 0.5);
    return sss * sss * sssColor;
}

// SSS term


#endif