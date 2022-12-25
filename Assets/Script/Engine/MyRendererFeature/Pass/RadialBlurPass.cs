using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class RadialBlurPass : ScriptableRenderPass
    {
        private Material blurMaterial;
        string profilerTag = "Radial Blur";

        //private static readonly int BlurParamID = Shader.PropertyToID("_RadialBlurParam");
        //private static readonly int BlurPowID = Shader.PropertyToID("_Pow");
        private static readonly int BlurSourceID = Shader.PropertyToID("_RadialBlurSource");

        private RenderTargetHandle tmpRT1;
        private RenderTargetHandle tmpRT2;
        private RenderTargetHandle sourceTmp;

        private RenderTargetIdentifier source;
        public RadialBlurPass()
        {
            source = new RenderTargetIdentifier("_GameCameraColorTexture");
        }

        public void SetConfig(RadialBlurSettings settings)
        {
            blurMaterial = settings.radialBlurMat;
            this.renderPassEvent = settings.renderPassEvent;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            tmpRT1.Init("RadialBlurTmp1");
            tmpRT2.Init("RadialBlurTmp2");
            sourceTmp.Init("_RadialBlurSource");

            CommandBuffer cmd = CommandBufferPool.Get(profilerTag);

            RenderTextureDescriptor descriptor = renderingData.cameraData.gameCameraTargetDescriptor;
            descriptor.depthBufferBits = 0;

            cmd.GetTemporaryRT(sourceTmp.id, descriptor, FilterMode.Bilinear);

            descriptor.width /= 4;
            descriptor.height /= 4;
            cmd.GetTemporaryRT(tmpRT1.id, descriptor, FilterMode.Bilinear);

            /*descriptor.width /= 2;
            descriptor.height /= 2;
            cmd.GetTemporaryRT(tmpRT2.id, descriptor, FilterMode.Bilinear);*/

            /*blurParam.x = playInstance.Intensity * 0.01f;
            blurParam.y = playInstance.RangeX;
            blurParam.z = playInstance.RangeY;
            blurParam.w = playInstance.Bright;
            blurMaterial.SetVector(BlurParamID, blurParam);
            blurMaterial.SetFloat(BlurPowID, playInstance.Pow);*/

            cmd.SetGlobalTexture(BlurSourceID, sourceTmp.id);

            Blit(cmd, source, sourceTmp.id, blurMaterial, 0);
            //模糊
            Blit(cmd, sourceTmp.id, tmpRT1.id, blurMaterial, 1);
            Blit(cmd, tmpRT1.id, source, blurMaterial, 1);
            //Blit(cmd, tmpRT2.id, tmpRT1.id, blurMaterial, 0);

            //混合
            //Blit(cmd, tmpRT1.id, source, blurMaterial, 1);


            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
        }
    }
}


