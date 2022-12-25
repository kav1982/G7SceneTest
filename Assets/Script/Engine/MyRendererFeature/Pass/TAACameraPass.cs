using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class TAACameraPass : ScriptableRenderPass
    {
        ProfilingSampler m_ProfilingSampler;

        Matrix4x4 matrix;
        private Vector4 offset;

        public TAACameraPass(string profilerTag)
        {
            m_ProfilingSampler = new ProfilingSampler(profilerTag);
        }

        public void Setup(Matrix4x4 matrix, Vector4 offset)
        {
            this.matrix = matrix;
            this.offset = offset;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get();

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                var camera = renderingData.cameraData.camera;
                cmd.SetViewProjectionMatrices(camera.worldToCameraMatrix, matrix);
                cmd.SetGlobalVector("_DitherTAA_Offset", offset);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }
}
