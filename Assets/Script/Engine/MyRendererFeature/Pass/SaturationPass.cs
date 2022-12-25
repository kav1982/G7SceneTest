using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class SaturationPass : UberExtendPass<Saturation>
    {
        static class ShaderIDs
        {
            internal static readonly int SaturationArg = Shader.PropertyToID("_MySaturationArg");
        }
        private Vector4 _arg = Vector4.zero;

        protected override void SetMaterial(Material mat)
        {
            mat.EnableKeyword("MY_SATURATION");
            _arg.Set(m_Config.upValue.value, m_Config.midPos.value, m_Config.downValue.value, 0);
            mat.SetVector(ShaderIDs.SaturationArg, _arg);
        }
    }
}