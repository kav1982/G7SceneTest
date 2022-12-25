using System;

namespace UnityEngine.Rendering.Universal.Internal
{
    /// <summary>
    /// Copy the given color buffer to the given destination color buffer.
    ///
    /// You can use this pass to copy a color buffer to the destination,
    /// so you can use it later in rendering. For example, you can copy
    /// the opaque texture to use it for distortion effects.
    /// </summary>
    public class UIMergePass : ScriptableRenderPass
    {
        Material m_Material;
        Material m_blitMaterial;

        bool m_isMerge = false;
        bool m_setBackCameraTarget = false;
        bool m_toLinear;

        private RenderTargetIdentifier source { get; set; }
        private RenderTargetHandle destination { get; set; }

        /// <summary>
        /// Create the CopyColorPass
        /// </summary>
        public UIMergePass(RenderPassEvent evt, Material mergeMaterial, Material blitMaterial)
        {
            base.profilingSampler = new ProfilingSampler(nameof(UIMergePass));

            m_Material = mergeMaterial;
            m_blitMaterial = blitMaterial;
            renderPassEvent = evt;
        }

        /// <summary>
        /// Configure the pass with the source and destination to execute on.
        /// </summary>
        /// <param name="source">Source Render Target</param>
        /// <param name="destination">Destination Render Target</param>
        public void Setup(RenderTargetIdentifier source, RenderTargetHandle destination, bool isMerge, bool toLinear = false)
        {
            this.source = source;
            this.destination = destination;
            m_isMerge = isMerge;
            m_toLinear = toLinear;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.msaaSamples = 1;
            descriptor.depthBufferBits = 0;

            cmd.GetTemporaryRT(destination.id, descriptor, FilterMode.Point);
        }

        /// <inheritdoc/>
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_Material == null)
            {
                Debug.LogErrorFormat("Missing {0}. {1} render pass will not execute. Check for missing reference in the renderer resources.", m_Material, GetType().Name);
                return;
            }

            CommandBuffer cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, ProfilingSampler.Get(URPProfileId.CopyColor)))
            {
                RenderTargetIdentifier opaqueColorRT = destination.Identifier();

                ScriptableRenderer.SetRenderTarget(cmd, opaqueColorRT, BuiltinRenderTextureType.CameraTarget, ClearFlag.All,
                    clearColor);
                if (m_toLinear) cmd.EnableShaderKeyword(ShaderKeywordStrings.SRGBToLinearConversion);
                RenderingUtils.Blit(cmd, source, opaqueColorRT, m_isMerge ? m_Material : m_blitMaterial, 0, renderingData.cameraData.xr.enabled);
                if (m_toLinear) cmd.DisableShaderKeyword(ShaderKeywordStrings.SRGBToLinearConversion);
            }

            if (m_setBackCameraTarget) cmd.SetRenderTarget(RenderTargetHandle.GetCameraTarget(renderingData.cameraData.xr).Identifier());

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        /// <inheritdoc/>
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (cmd == null)
                throw new ArgumentNullException("cmd");

            if (destination != RenderTargetHandle.CameraTarget)
            {
                cmd.ReleaseTemporaryRT(destination.id);
                destination = RenderTargetHandle.CameraTarget;
            }
        }

        public void SetBackCameraTarget(bool needSetBack)
        {
            m_setBackCameraTarget = needSetBack;
        }
    }
}
