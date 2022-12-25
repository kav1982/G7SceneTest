using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class TerrainBlendPass : ScriptableRenderPass
    {
        public TerrainBlendPass(RenderPassEvent evt)
        {
            renderPassEvent = evt;
            terrainBlendTarget.Init("_TerrainBlendTarget");
            m_ShaderTagIdList.Add(new ShaderTagId("TerrainBlend"));
        }

        private ProfilingSampler m_ProfilingSampler = new ProfilingSampler("TerrainBlend");
        private RenderTargetHandle terrainBlendTarget;
        List<ShaderTagId> m_ShaderTagIdList = new List<ShaderTagId>();
        FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
        public int resolution = 512;
        private static readonly int _TerrainBlendPositionMinMaxID = Shader.PropertyToID("_TerrainBlendPositionMinMax");
        private bool _needCalcRect = true;

        public void SetConfig(TerrainBlendSettings settings)
        {
            resolution = (int)settings.texSize;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            RenderTextureDescriptor descriptor = cameraTextureDescriptor;
            descriptor.msaaSamples = 1;
            descriptor.width = descriptor.height = resolution;
            descriptor.graphicsFormat = GraphicsFormat.R8G8B8A8_UNorm;

            cmd.GetTemporaryRT(terrainBlendTarget.id, descriptor, FilterMode.Bilinear);

            ConfigureTarget(terrainBlendTarget.id);
            ConfigureClear(ClearFlag.All, Color.black);
        }

        private Vector3 _pos, _tempV3;
        public Vector2 viewRectSize = Vector2.zero, viewRectOffset = Vector2.zero;

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            Camera mainCamera = renderingData.cameraData.camera;
            MyRendererFeature.Instance.CheckAndUpdateCameraPosArg(mainCamera);
            _pos = mainCamera.transform.position;
            _tempV3.Set(_pos.x + viewRectOffset.x, 100, _pos.z + viewRectOffset.y);

            CommandBuffer cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                //cmd.SetViewport(new Rect(0,0,resolution, resolution));

                Matrix4x4 basicAxis = Matrix4x4.identity;
                basicAxis.SetRow(0, new Vector4(1, 0, 0, 0)); //right
                basicAxis.SetRow(1, new Vector4(0, 0, 1, 0)); //up
                basicAxis.SetRow(2, new Vector4(0, 1, 0, 0));//forward

                // translate //
                Matrix4x4 translate = Matrix4x4.identity;
                translate.SetColumn(3, new Vector4(-_tempV3.x, -100, -_tempV3.z, 1));

                Matrix4x4 view = basicAxis * translate;

                Matrix4x4 proj = Matrix4x4.Ortho(-viewRectSize.x, viewRectSize.x, -viewRectSize.y, viewRectSize.y, -100, 1000);
                proj = GL.GetGPUProjectionMatrix(proj, true);

                RenderingUtils.SetViewAndProjectionMatrices(cmd, view, proj, false);

                cmd.SetGlobalVector(_TerrainBlendPositionMinMaxID,
                    new Vector4(_tempV3.x - viewRectSize.x, _tempV3.z - viewRectSize.y, _tempV3.x + viewRectSize.x, _tempV3.z + viewRectSize.y));

                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                DrawingSettings drawingSettings = CreateDrawingSettings(m_ShaderTagIdList, ref renderingData,
                    SortingCriteria.OptimizeStateChanges);

                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);

                RenderingUtils.SetViewAndProjectionMatrices(cmd, renderingData.cameraData.GetViewMatrix(), renderingData.cameraData.GetGPUProjectionMatrix(), false);
            }

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
        }

        public override void OnFinishCameraStackRendering(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(terrainBlendTarget.id);
        }
        
    }
}