using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class EdgeDetectionPass : UberExtendPass<EdgeDetection>
    {
        static class ShaderIDs
        {
            internal readonly static int Input = Shader.PropertyToID("_MainTex");
            internal readonly static int Intensity = Shader.PropertyToID("_Intensity");
            internal readonly static int Threshold = Shader.PropertyToID("_Threshold");
            internal readonly static int Thickness = Shader.PropertyToID("_Thickness");
            internal readonly static int Color = Shader.PropertyToID("_EdgeColor");
        }

        protected override void SetMaterial(Material mat)
        {
            mat.EnableKeyword("EDGE_DETECTION");
            mat.SetFloat(ShaderIDs.Intensity, m_Config.intensity.value);
            mat.SetFloat(ShaderIDs.Thickness, m_Config.thickness.value);
            Vector2 normalThreshold = m_Config.normalThreshold.value;
            Vector2 depthThreshold = m_Config.depthThreshold.value;
            Vector4 threshold = new Vector4(Mathf.Cos(normalThreshold.y * Mathf.Deg2Rad), Mathf.Cos(normalThreshold.x * Mathf.Deg2Rad), depthThreshold.x, depthThreshold.y);
            mat.SetVector(ShaderIDs.Threshold, threshold);
            mat.SetColor(ShaderIDs.Color, m_Config.color.value);
        }
    }
}
