using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class TAAPass : ScriptableRenderPass
    {
        ProfilingSampler m_ProfilingSampler;

        RenderTargetIdentifier cameraColorTarget;
        bool use32Bit;
        Material material;
        Matrix4x4 prevViewProj;
        Vector2 offset;
        float blend;
        bool antiGhosting;
        private float sharpness;
        public bool canCopyTexture;

        Dictionary<int, RenderTexture> TAATextures = new Dictionary<int, RenderTexture>();

        private static readonly int SharpnessID = Shader.PropertyToID("_TAA_Sharpness");
        private static readonly int SourceTexID = Shader.PropertyToID("_SourceTex");
        private static readonly int TAATexID = Shader.PropertyToID("_TAA_Texture");
        private static readonly int TAA_PrevViewProjID = Shader.PropertyToID("_TAA_PrevViewProj");
        private static readonly int TAA_BlendID = Shader.PropertyToID("_TAA_Blend");

        int tempID;
        RenderTargetIdentifier tempTarget;

        public TAAPass(string profilerTag)
        {
            m_ProfilingSampler = new ProfilingSampler(profilerTag);

            tempID = Shader.PropertyToID("_TAA_TempTexture");
            tempTarget = new RenderTargetIdentifier(tempID);
        }

        public void Setup(
            RenderTargetIdentifier cameraColorTarget,
            bool use32Bit,
            Material material,
            Matrix4x4 prevViewProj,
            Vector2 offset,
            float blend,
            bool antiGhosting,
            float sharpness
            )
        {
            this.cameraColorTarget = cameraColorTarget;
            this.use32Bit = use32Bit;
            this.material = material;
            this.prevViewProj = prevViewProj;
            this.offset = offset;
            this.blend = blend;
            this.antiGhosting = antiGhosting;
            this.sharpness = sharpness;
        }

        void allocRT(out RenderTexture rt, RenderTextureDescriptor descriptor)
        {
            rt = new RenderTexture(descriptor);
            rt.filterMode = FilterMode.Bilinear;
        }

        void allocRT(out RenderTexture rt, CommandBuffer cmd, ScriptableRenderContext context, RenderTextureDescriptor descriptor)
        {
            allocRT(out rt, descriptor);
            cmd.Blit(cameraColorTarget, rt);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
        }

        private const string TAAPrevName = "_TAA_PrevTexture";
        void genRT(CommandBuffer cmd, ScriptableRenderContext context, RenderTextureDescriptor descriptor, int hash)
        {
            descriptor.useMipMap = false;
            descriptor.autoGenerateMips = false;
            descriptor.depthBufferBits = 0;
            descriptor.msaaSamples = 1;
            if (use32Bit) descriptor.colorFormat = RenderTextureFormat.ARGBFloat;

            if (TAATextures.ContainsKey(hash))
            {
                if (TAATextures[hash] == null)
                {
                    allocRT(out var TAATexture, cmd, context, descriptor);
                    TAATextures[hash] = TAATexture;
                    return;
                }
            }
            else
            {
                allocRT(out var TAATexture, cmd, context, descriptor);
                TAATextures[hash] = TAATexture;
                return;
            }

            RenderTextureDescriptor desc;
            desc = TAATextures[hash].descriptor;
            if (desc.width != descriptor.width ||
                desc.height != descriptor.height ||
                desc.colorFormat != descriptor.colorFormat)
            {
                TAATextures[hash].Release();
                allocRT(out var TAATexture, cmd, context, descriptor);
                TAATextures[hash] = TAATexture;
            }

            TAATextures[hash].name = TAAPrevName;
        }

        void onCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.useMipMap = false;
            descriptor.autoGenerateMips = false;
            descriptor.depthBufferBits = 16;
            descriptor.msaaSamples = 1;
            if (use32Bit) descriptor.colorFormat = RenderTextureFormat.ARGBFloat;
            cmd.GetTemporaryRT(tempID, descriptor, FilterMode.Bilinear);
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData) => onCameraSetup(cmd, ref renderingData);

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            //    ConfigureClear(ClearFlag.Depth, Color.black);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get();

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                var descriptor = renderingData.cameraData.cameraTargetDescriptor;
                var hash = renderingData.cameraData.camera.GetHashCode();
                genRT(cmd, context, descriptor, hash);

                material.SetMatrix(TAA_PrevViewProjID, prevViewProj);
                cmd.SetGlobalVector("_TAA_Offset", offset);
                material.SetFloat(TAA_BlendID, blend);
                CoreUtils.SetKeyword(material, "_TAA_Anti_Ghosting", antiGhosting);
                material.SetTexture(TAATexID, TAATextures[hash]);
                cmd.SetGlobalTexture(SourceTexID, cameraColorTarget);

                cmd.EnableShaderKeyword("_TAA");

                if (SystemInfo.graphicsShaderLevel >= 45)
                {
                    cmd.EnableShaderKeyword(ShaderKeywordStrings.UseDrawProcedural);
                    cmd.SetRenderTarget(tempTarget, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
                    cmd.DrawProcedural(Matrix4x4.identity, material, 0, MeshTopology.Triangles, 3);
                }
                else
                {
                    cmd.DisableShaderKeyword(ShaderKeywordStrings.UseDrawProcedural);
                    cmd.Blit(cameraColorTarget, tempTarget, material);
                }

                cmd.SetGlobalFloat(SharpnessID, sharpness);
                if (canCopyTexture)
                {
                    cmd.CopyTexture(tempTarget, TAATextures[hash]);
                }

                else
                {
                    cmd.Blit(tempTarget, TAATextures[hash]);
                }
                cmd.DisableShaderKeyword(ShaderKeywordStrings.UseDrawProcedural);

            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(tempID);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.DisableShaderKeyword("_TAA");
        }


        public void Clear(int hash)
        {
            if (TAATextures.ContainsKey(hash))
            {
                TAATextures[hash].Release();
                TAATextures.Remove(hash);
            }
        }
    }
}
