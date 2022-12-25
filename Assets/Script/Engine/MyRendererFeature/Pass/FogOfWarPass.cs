using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class FogOfWarPass : UberExtendPass<FogOfWar>
    {
        static class ShaderIDs
        {
            internal static readonly int FogOfWarUVTex = Shader.PropertyToID("_FOWUVTex");
            internal static readonly int FogOfWarEdgeNoiseTex = Shader.PropertyToID("_FOWEdgeNoiseTex");
            internal static readonly int FogOfWarColor = Shader.PropertyToID("_FOWColor");
            internal static readonly int FogOfWarSelectColor = Shader.PropertyToID("_FOWSelectColor");
            internal static readonly int FogOfWarDepthColor = Shader.PropertyToID("_FOWDepthFogColor");
            internal static readonly int FogOfWarEdgeColor = Shader.PropertyToID("_FogOfWarEdgeColor");
            internal static readonly int FogOfWarBaseParams = Shader.PropertyToID("_FOWBaseParams");
            internal static readonly int FogOfWarEdgeParams = Shader.PropertyToID("_FOWEdgeParams");
            internal static readonly int FogOfWarWindParams = Shader.PropertyToID("_FOWWindParams");
            internal static readonly int FogOfWarDepthParams = Shader.PropertyToID("_FOWDepthParams");
        }

        protected override void SetMaterial(Material mat)
        {
            mat.EnableKeyword("FOGOFWAR");
            if (m_Config.enableDepth.value)
                mat.EnableKeyword("FOGOFWAR_DEPTH");
            mat.SetTexture(ShaderIDs.FogOfWarUVTex, m_Config.fogUVTex2D.value);
            mat.SetTexture(ShaderIDs.FogOfWarEdgeNoiseTex, m_Config.fogEdgeNoiseTex2D.value);
            mat.SetColor(ShaderIDs.FogOfWarColor, m_Config.baseColor.value);
            mat.SetColor(ShaderIDs.FogOfWarDepthColor, m_Config.depthColor.value);
            mat.SetColor(ShaderIDs.FogOfWarEdgeColor, m_Config.fogEdgeColor.value);
            mat.SetColor(ShaderIDs.FogOfWarSelectColor, m_Config.selectColor.value);
            var baseParams = new Vector4(m_Config.overallHeight.value, m_Config.heightScale.value, m_Config.heightOffset.value, m_Config.darkColorAdjust.value);
            var edgeParams = new Vector4(m_Config.edgeUVScale.value / 100f, m_Config.edgeUVSpeed.value, m_Config.edgeNoiseStrength.value);
            var windParams = new Vector4(m_Config.fogEdgeScale.value, 0, m_Config.depthUVScale.value, m_Config.depthUVSpeed.value);
            var depthParams = new Vector4(m_Config.depthStart.value, m_Config.depthEnd.value, m_Config.depthNoiseAmount.value);
            mat.SetVector(ShaderIDs.FogOfWarBaseParams, baseParams);
            mat.SetVector(ShaderIDs.FogOfWarEdgeParams, edgeParams);
            mat.SetVector(ShaderIDs.FogOfWarWindParams, windParams);
            mat.SetVector(ShaderIDs.FogOfWarDepthParams, depthParams);
        }
    }
}