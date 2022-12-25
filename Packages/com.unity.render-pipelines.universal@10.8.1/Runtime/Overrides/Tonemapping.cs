using System;

namespace UnityEngine.Rendering.Universal
{
    public enum TonemappingMode
    {
        None,
        Neutral, // Neutral tonemapper
        Unity_ACES,    // ACES Filmic reference tonemapper (custom approximation)
        UE4_ACES, // UE4 Filmic Tonemapper
        ACES,    // ACES Filmic reference tonemapper (custom approximation)
    }

    [Serializable, VolumeComponentMenu("Post-processing/Tonemapping")]
    public sealed class Tonemapping : VolumeComponent, IPostProcessComponent
    {
        [Tooltip("Select a tonemapping algorithm to use for the color grading process.")]
        public TonemappingModeParameter mode = new TonemappingModeParameter(TonemappingMode.None);

        [Tooltip("调整基于色调映射的S曲线, 较大值斜率较大,色彩更深")]
        public ClampedFloatParameter filmicSlope = new ClampedFloatParameter(0.88f, 0f, 1f);

        [Tooltip("调整色调映射的深色")]
        public ClampedFloatParameter filmicToe = new ClampedFloatParameter(0.55f, 0f, 1f);

        [Tooltip("调整色调映射的亮度")]
        public ClampedFloatParameter filmicShoulder = new ClampedFloatParameter(0.26f, 0f, 1f);

        [Tooltip("调整色调黑色断点")]
        public ClampedFloatParameter filmicBlackClip = new ClampedFloatParameter(0.00f, 0f, 1f);

        [Tooltip("调整色调白色断点")]
        public ClampedFloatParameter filmicWhiteClip = new ClampedFloatParameter(0.04f, 0f, 1f);

        public bool IsActive() => mode.value != TonemappingMode.None;

        public bool IsTileCompatible() => true;
    }

    [Serializable]
    public sealed class TonemappingModeParameter : VolumeParameter<TonemappingMode> { public TonemappingModeParameter(TonemappingMode value, bool overrideState = false) : base(value, overrideState) { } }
}
