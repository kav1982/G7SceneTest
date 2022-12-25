using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    [Serializable, VolumeComponentMenu("yf7/FogOfWar")]
    public class FogOfWar : VolumeComponent, IPostProcessComponent
    {
        [Label("开启")]
        public BoolParameter isActive = new BoolParameter(false);

        [Header("底色")]
        [Label("底色")]
        public ColorParameter baseColor = new ColorParameter(Color.white);
        [Label("整体高度")]
        public FloatParameter overallHeight = new FloatParameter(0);
        [Label("底色亮度（相乘）")]
        public FloatParameter heightScale = new FloatParameter(0);
        [Label("底色亮度（相加）")]
        public FloatParameter heightOffset = new FloatParameter(0);
        [Label("暗色增亮（水坑河流）")]
        public FloatParameter darkColorAdjust = new FloatParameter(0);

        [Header("边缘")]
        [Label("边缘噪音")]
        public TextureParameter fogEdgeNoiseTex2D = new TextureParameter(null);
        [Label("边缘Tiling")]
        public FloatParameter edgeUVScale = new FloatParameter(0);
        [Label("边缘速度")]
        public FloatParameter edgeUVSpeed = new FloatParameter(0);
        [Label("边缘扰动强度")]
        public ClampedFloatParameter edgeNoiseStrength = new ClampedFloatParameter(0, 0, 1);
        [Label("边缘色")]
        public ColorParameter fogEdgeColor = new ColorParameter(Color.white);
        [Label("边缘色（相乘）")]
        public FloatParameter fogEdgeScale = new FloatParameter(0);

        [Header("深度雾")]
        [Label("深度雾")]
        public BoolParameter enableDepth = new BoolParameter(false);
        [Label("深度雾噪音")]
        public TextureParameter fogUVTex2D = new TextureParameter(null);
        [Label("深度雾颜色")]
        public ColorParameter depthColor = new ColorParameter(Color.white);
        [Label("噪音Tiling")]
        public FloatParameter depthUVScale = new FloatParameter(0);
        [Label("深度雾速度")]
        public FloatParameter depthUVSpeed = new FloatParameter(0);
        [Label("深度雾开始高度")]
        public FloatParameter depthStart = new FloatParameter(0);
        [Label("深度雾结束高度")]
        public FloatParameter depthEnd = new FloatParameter(0);
        [Label("深度雾噪音强度")]
        public FloatParameter depthNoiseAmount = new FloatParameter(0);

        [Header("选中效果")]
        [Label("选中颜色")]
        public ColorParameter selectColor = new ColorParameter(Color.gray);

        public bool IsActive() => isActive.value;

        public bool IsTileCompatible() => false;
    }
}
