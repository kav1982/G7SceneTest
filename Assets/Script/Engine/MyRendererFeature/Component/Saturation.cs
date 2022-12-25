using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    [Serializable, VolumeComponentMenu("yf7/Saturation")]
    public class Saturation : VolumeComponent, IPostProcessComponent
    {
        [Label("开启")]
        public BoolParameter isActive = new BoolParameter(false);
        [Label("屏幕上方饱和度")]
        public ClampedFloatParameter upValue = new ClampedFloatParameter(0.5f, 0, 3f);
        [Label("饱和度1位置")]
        public ClampedFloatParameter midPos = new ClampedFloatParameter(0.5f, 0.01f, 0.99f);
        [Label("屏幕下方饱和度")]
        public ClampedFloatParameter downValue = new ClampedFloatParameter(1f, 0, 3f);

        public bool IsActive() => isActive.value;
        public bool IsTileCompatible() => false;
    }

}