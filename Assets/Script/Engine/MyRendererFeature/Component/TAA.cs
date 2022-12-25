using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    [Serializable, VolumeComponentMenu("yf7/TAA")]
    public class TAA : VolumeComponent, IPostProcessComponent
    {
        [Label("开启")]
        public BoolParameter Enabled = new BoolParameter(false);

        [Label("混合比例")]
        public ClampedFloatParameter Blend = new ClampedFloatParameter(0.9375f, 0.5f, 0.999f);
        [Label("采样点数量")]
        public MinIntParameter SamplePointCount = new MinIntParameter(8, 2);
        [Label("锐化")]
        public ClampedFloatParameter Sharpness = new ClampedFloatParameter(1.5f, 0, 8);
        [Label("抖动大小")]
        public ClampedFloatParameter Fraction = new ClampedFloatParameter(1.0f, 0.01f, 8);

        [HideInInspector] public BoolParameter AntiGhosting = new BoolParameter(true);

        public bool IsActive() => (bool)Enabled;

        public bool IsTileCompatible() => false;
    }
}
