using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class BeforePostProcessingPass : ScriptableRenderPass
    {
        private CloudShadowSettings cloudShadowSettings = null;
        private WaveSettings waveSettings = null;
        private RenderTargetIdentifier _targetId;
        private RenderTargetHandle _tempNullSrc;

        private Vector4 _mousePosition = Vector4.zero;
        private Vector2 _oldMousePos = Vector2.zero;
        private Vector2 _LineWide = Vector2.zero;
        private float _tempFloat;
        private Vector2 _tempV2 = Vector2.zero;
        private readonly int SHADER_iMouse = Shader.PropertyToID("_iMouse");
        private readonly int SHADER_WideNewOld = Shader.PropertyToID("_WideNewOld");
        private readonly int SHADER_oMouse = Shader.PropertyToID("_oMouse");
        private RenderTargetHandle _rt1 = RenderTargetHandle.CameraTarget;
        private RenderTargetHandle _rt2 = RenderTargetHandle.CameraTarget;
        private RenderTargetHandle _rt3 = RenderTargetHandle.CameraTarget;

        public BeforePostProcessingPass()
        {
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing - 5;
            _tempNullSrc.Init("_DontCareSrcTex");
            _rt1.Init("_waveTempRt1");
            _rt2.Init("_waveTempRt2");
            _rt3.Init("_waveTempRt3");
        }

        public void SetCloudSettings(CloudShadowSettings settings)
        {
            cloudShadowSettings = settings;
        }

        public void SetWaveSettings(WaveSettings settings)
        {
            waveSettings = settings;
        }

        public void SetTarget(RenderTargetIdentifier id)
        {
            _targetId = id;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            cmd.GetTemporaryRT(_tempNullSrc.id, 16, 16);
        }

        private int waveSizeW = 0;
        private int waveSizeH = 0;
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (cloudShadowSettings != null && cloudShadowSettings.IsActive)
            {
                if (cloudShadowSettings.dirty) cloudShadowSettings.UpdateMaterialArg();
                CommandBuffer cmd = CommandBufferPool.Get("Cloud Shadow");
                cmd.Clear();
                //cmd.SetRenderTarget(_targetId);
                //cmd.Blit(_tempNullSrc.Identifier(), BuiltinRenderTextureType.CurrentActive, cloudShadowSettings.material);
                cmd.Blit(_tempNullSrc.Identifier(), _targetId, cloudShadowSettings.material);
                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }
            if (waveSettings != null && !renderingData.cameraData.isSceneViewCamera)
            {
                if (waveSettings.IsActive)
                {
                    _mousePosition.Set(Input.mousePosition.x / 2, Input.mousePosition.y / 2, Input.GetMouseButton(0) ? 1 : -1, 0.0f);
                    waveSettings.drawMat.SetVector(SHADER_iMouse, _mousePosition);
                    _tempV2.Set(_mousePosition.x, _mousePosition.y);
                    _tempFloat = (1.0f - Mathf.Min(Vector2.Distance(_oldMousePos, _tempV2), 200.0f) / 400.0f) * waveSettings.TouchWide;
                    _LineWide.x = _tempFloat * _tempFloat * _tempFloat + 0.1f;
                    waveSettings.drawMat.SetVector(SHADER_WideNewOld, _LineWide);
                    _LineWide.y = _LineWide.x;
                    waveSettings.drawMat.SetVector(SHADER_oMouse, _oldMousePos);
                    _oldMousePos.Set(_mousePosition.x, _mousePosition.y);

                    CommandBuffer cmd = CommandBufferPool.Get("Wave");
                    cmd.Clear();
                    //if(_rt1 == RenderTargetHandle.CameraTarget)
                    if (waveSettings.rt1 == null || waveSizeW != renderingData.cameraData.gameCameraTargetDescriptor.width || waveSizeH != renderingData.cameraData.gameCameraTargetDescriptor.height)
                    {
                        if (waveSettings.rt1 != null)
                        {
                            RenderTexture.ReleaseTemporary(waveSettings.rt1);
                            RenderTexture.ReleaseTemporary(waveSettings.rt2);
                            RenderTexture.ReleaseTemporary(waveSettings.rt3);
                            //cmd.ReleaseTemporaryRT(_rt1.id);
                            //cmd.ReleaseTemporaryRT(_rt2.id);
                            //cmd.ReleaseTemporaryRT(_rt3.id);
                        }
                        System.Action<RenderTexture, string> SetRt = (rt, name) => { 
                            rt.filterMode = FilterMode.Point;
                            rt.wrapMode = TextureWrapMode.Clamp;
                            rt.autoGenerateMips = false;
                            rt.name = name;

                        };
                        var desc = renderingData.cameraData.gameCameraTargetDescriptor;
                        waveSizeW = desc.width;
                        waveSizeH = desc.height;
                        int width = desc.width >> 1;
                        int height = desc.height >> 1;
                        waveSettings.rt1 = RenderTexture.GetTemporary(width, height, 0, UnityEngine.Experimental.Rendering.GraphicsFormat.R32G32B32A32_UInt, 1);
                        waveSettings.rt2 = RenderTexture.GetTemporary(width, height, 0, UnityEngine.Experimental.Rendering.GraphicsFormat.R32G32B32A32_UInt, 1);
                        waveSettings.rt3 = RenderTexture.GetTemporary(width, height, 0, UnityEngine.Experimental.Rendering.GraphicsFormat.R32G32B32A32_SFloat, 1);
                        SetRt(waveSettings.rt1, "Wave_rt1");
                        SetRt(waveSettings.rt2, "Wave_rt2");
                        SetRt(waveSettings.rt3, "Wave_rt3");

                        //cmd.GetTemporaryRT(_rt1.id, desc.width, desc.height, 0, FilterMode.Point, UnityEngine.Experimental.Rendering.GraphicsFormat.R32G32B32A32_UInt);
                        //cmd.GetTemporaryRT(_rt2.id, desc.width, desc.height, 0, FilterMode.Point, UnityEngine.Experimental.Rendering.GraphicsFormat.R32G32B32A32_UInt);
                        //cmd.GetTemporaryRT(_rt3.id, desc.width, desc.height, 0, FilterMode.Point, UnityEngine.Experimental.Rendering.GraphicsFormat.R32G32B32A32_SFloat);
                    }
                    //cmd.SetRenderTarget(waveSettings.rt2, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
                    //cmd.Blit(waveSettings.rt1, BuiltinRenderTextureType.CurrentActive, waveSettings.drawMat);
                    //cmd.SetRenderTarget(waveSettings.rt1, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
                    //cmd.Blit(waveSettings.rt2, BuiltinRenderTextureType.CurrentActive);
                    //cmd.SetRenderTarget(waveSettings.rt3, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
                    //cmd.Blit(waveSettings.rt1, BuiltinRenderTextureType.CurrentActive, waveSettings.waveMat);
                    //cmd.SetRenderTarget(_targetId);
                    //cmd.Blit(waveSettings.rt3, BuiltinRenderTextureType.CurrentActive);
                    cmd.Blit(waveSettings.rt1, waveSettings.rt2, waveSettings.drawMat);
                    cmd.Blit(waveSettings.rt2, waveSettings.rt1);
                    cmd.Blit(waveSettings.rt1, waveSettings.rt3, waveSettings.waveMat);
                    cmd.Blit(waveSettings.rt3, _targetId);
                    //cmd.Blit(_rt1.Identifier(), _rt2.Identifier(), waveSettings.drawMat);
                    //cmd.Blit(_rt2.Identifier(), _rt1.Identifier());
                    //cmd.Blit(_rt1.Identifier(), _rt3.Identifier(), waveSettings.waveMat);
                    //cmd.SetRenderTarget(_targetId);
                    //cmd.Blit(_rt3.Identifier(), BuiltinRenderTextureType.CurrentActive);
                    context.ExecuteCommandBuffer(cmd);
                    CommandBufferPool.Release(cmd);
                }
                else
                {
                    if (waveSettings.rt1 != null)
                    {
                        RenderTexture.ReleaseTemporary(waveSettings.rt1);
                        RenderTexture.ReleaseTemporary(waveSettings.rt2);
                        RenderTexture.ReleaseTemporary(waveSettings.rt3);
                        waveSettings.rt1 = null;
                        waveSettings.rt2 = null;
                        waveSettings.rt3 = null;
                    }
                    //if (_rt1 != RenderTargetHandle.CameraTarget)
                    //{
                    //    CommandBuffer cmd = CommandBufferPool.Get("Wave");
                    //    cmd.Clear();
                    //    cmd.ReleaseTemporaryRT(_rt1.id);
                    //    cmd.ReleaseTemporaryRT(_rt2.id);
                    //    cmd.ReleaseTemporaryRT(_rt3.id);
                    //    _rt1 = RenderTargetHandle.CameraTarget;
                    //    _rt2 = RenderTargetHandle.CameraTarget;
                    //    _rt3 = RenderTargetHandle.CameraTarget;
                    //    context.ExecuteCommandBuffer(cmd);
                    //    CommandBufferPool.Release(cmd);
                    //}
                }
            }
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(_tempNullSrc.id);
        }
    }
}
