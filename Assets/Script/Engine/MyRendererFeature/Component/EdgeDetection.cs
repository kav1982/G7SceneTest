using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    [Serializable, VolumeComponentMenu("yf7/EdgeDetection")]
    public class EdgeDetection : VolumeComponent, IPostProcessComponent
    {
        [Label("开启")]
        public BoolParameter isActive = new BoolParameter(false);
        [Label("强度")]
        public ClampedFloatParameter intensity = new ClampedFloatParameter(0.5f, 0, 3);
        [Label("边缘检测距离")]
        public MinFloatParameter thickness = new MinFloatParameter(1, 0);
        [Label("法线角度差值范围")]
        public FloatRangeParameter normalThreshold = new FloatRangeParameter(new Vector2(1, 2), 0, 360);
        [Label("深度差值范围")]
        public FloatRangeParameter depthThreshold = new FloatRangeParameter(new Vector2(0.1f, 0.11f), 0, 1);
        [Label("描边颜色")]
        public ColorParameter color = new ColorParameter(Color.black, true, false, true);
        public bool IsActive() => isActive.value;
        public bool IsTileCompatible() => false;
    }
}
