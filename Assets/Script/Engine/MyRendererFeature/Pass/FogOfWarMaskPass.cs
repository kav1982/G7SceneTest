using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class FogOfWarMaskPass : ScriptableRenderPass
    {
        private ProfilingSampler m_ProfilingSampler = new ProfilingSampler("FogOfWarMask");
        private RenderTargetHandle fogMaskTarget;
        List<ShaderTagId> m_ShaderTagIdList = new List<ShaderTagId>();
        FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
        private int WorldMaskParamsID = Shader.PropertyToID("_FOWWorldMaskParams");
        private int ExtParamsID = Shader.PropertyToID("_extValue");

        private int fogMaskTexSize = 512;
        private float extSize = 1.0f;
        private int _tempWidth = 128;
        private int _tempHeight = 128;
        private RenderTargetHandle _src;
        private RenderTargetHandle _dest;
        private GraphicsFormat _format = GraphicsFormat.R8G8B8A8_UNorm;
        private Material _blurMat = null;
        [Range(0, 4)]
        public int blurCount = 2;
        [Range(0, 2)]
        public float blurBase = 0.5f;
        [Range(0, 2)]
        public float blurStep = 0.7f;
        private int OFFSET_ID = Shader.PropertyToID("_offsets");
        private Vector4 _offsetH = Vector4.zero;
        private Vector4 _offsetV = Vector4.zero;
        private Matrix4x4 _basicAxis;
        private Matrix4x4 _translate;

        private static bool _needRender = true;
        private static float _needRenderTime = 0;
        private float _lastX = 0;
        private float _lastY = 0;
        private float _lastZ = 0;

        private RenderTexture rt = null;

        public FogOfWarMaskPass(RenderPassEvent evt)
        {
            fogMaskTarget.Init("_FOWWorldMask_temp");
            _src.Init("FogMaskBlur_src");
            _dest.Init("FogMaskBlur_dest");
            m_ShaderTagIdList.Add(new ShaderTagId("FogEye"));
            renderPassEvent = evt;
            _basicAxis = Matrix4x4.identity;
            _basicAxis.SetRow(0, new Vector4(1, 0, 0, 0)); //right
            _basicAxis.SetRow(1, new Vector4(0, 0, 1, 0)); //up
            _basicAxis.SetRow(2, new Vector4(0, 1, 0, 0));//forward
            _translate = Matrix4x4.identity;
        }

        public void SetConfig(WarFogSettings settings)
        {
            fogMaskTexSize = (int)settings.maskTexSize;
            _blurMat = settings.fogBlurMat;
            extSize = settings.extSize;
            blurBase = settings.blurBase;
            blurStep = settings.blurStep;
            _tempWidth = fogMaskTexSize >> 2;
            _tempHeight = fogMaskTexSize >> 2;
            _needRender = true;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            RenderTextureDescriptor descriptor = cameraTextureDescriptor;
            descriptor.msaaSamples = 1;
            descriptor.width = descriptor.height = fogMaskTexSize;
            descriptor.graphicsFormat = _format;

            cmd.GetTemporaryRT(fogMaskTarget.id, descriptor, FilterMode.Bilinear);
            if(rt == null || rt.width!= descriptor.width || rt.height != descriptor.height)
            {
                if (rt != null) RenderTexture.ReleaseTemporary(rt);
                rt = RenderTexture.GetTemporary(descriptor);
                cmd.SetGlobalTexture("_FOWWorldMask", rt);
            }

            ConfigureTarget(fogMaskTarget.id);
            ConfigureClear(ClearFlag.None, Color.black);
        }

        public static void NeedUpdateFog()
        {
            _needRender = true;
        }

        public static void KeepUpdateInTime(float time)
        {
            if (_needRenderTime < Time.timeSinceLevelLoad + time) _needRenderTime = Time.timeSinceLevelLoad + time;
        }

        private Vector3 _pos, _tempV3;
        public Vector2 viewRectSize = Vector2.zero, viewRectOffset = Vector2.zero;
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            Camera mainCamera = renderingData.cameraData.camera;
            _pos = mainCamera.transform.position;
            if (!_needRender)
            {
                if(!(Mathf.Approximately(_pos.x, _lastX) && Mathf.Approximately(_pos.y, _lastY)&& Mathf.Approximately(_pos.z, _lastZ)))
                {
                    _needRender = true;
                }
#if UNITY_EDITOR
                if(!UnityEditor.EditorApplication.isPlaying) _needRender = true;
#endif
                if (_needRenderTime >= Time.timeSinceLevelLoad) _needRender = true;
            }
            if (!_needRender) return;
            _needRender = false;
            MyRendererFeature.Instance.CheckAndUpdateCameraPosArg(mainCamera); 
            _tempV3.Set(_pos.x + viewRectOffset.x, 100, _pos.z + viewRectOffset.y);
            _lastX = _pos.x;
            _lastY = _pos.y;
            _lastZ = _pos.z;

            CommandBuffer cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                cmd.ClearRenderTarget(true, true, Color.black);
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                // translate //
                _translate.SetColumn(3, new Vector4(-_tempV3.x, -100, -_tempV3.z, 1));

                Matrix4x4 view = _basicAxis * _translate;

                Matrix4x4 proj = Matrix4x4.Ortho(-viewRectSize.x - 5, viewRectSize.x + 5, -viewRectSize.y - 5, viewRectSize.y + 5, -100, 300);
                proj = GL.GetGPUProjectionMatrix(proj, true);

                RenderingUtils.SetViewAndProjectionMatrices(cmd, view, proj, false);

                cmd.SetGlobalVector(WorldMaskParamsID,
                    new Vector4(_tempV3.x - viewRectSize.x - 5, _tempV3.z - viewRectSize.y - 5, viewRectSize.x + viewRectSize.x + 10, viewRectSize.y + viewRectSize.y + 10));

                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                DrawingSettings drawingSettings = CreateDrawingSettings(m_ShaderTagIdList, ref renderingData,
                    SortingCriteria.RenderQueue);

                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);

                RenderingUtils.SetViewAndProjectionMatrices(cmd, renderingData.cameraData.GetViewMatrix(), renderingData.cameraData.GetGPUProjectionMatrix(), false);

                cmd.GetTemporaryRT(_src.id, _tempWidth, _tempHeight, 0, FilterMode.Bilinear, _format);
                cmd.GetTemporaryRT(_dest.id, _tempWidth, _tempHeight, 0, FilterMode.Bilinear, _format);

                cmd.SetRenderTarget(_src.Identifier(), RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
                cmd.Blit(fogMaskTarget.id, BuiltinRenderTextureType.CurrentActive);

                _blurMat.SetFloat(ExtParamsID, extSize / viewRectSize.x / 10);
                cmd.SetRenderTarget(_dest.Identifier(), RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
                cmd.Blit(_src.id, BuiltinRenderTextureType.CurrentActive, _blurMat, 1);
                for (int i = 0; i < blurCount; i++)
                {
                    _offsetV.y = blurBase + i * blurStep;
                    cmd.SetGlobalVector(OFFSET_ID, _offsetV);
                    cmd.SetRenderTarget(_src.Identifier(), RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
                    cmd.Blit(_dest.id, BuiltinRenderTextureType.CurrentActive, _blurMat, 0);
                    _offsetH.x = _offsetV.y;
                    cmd.SetGlobalVector(OFFSET_ID, _offsetH);
                    if (i + 1 == blurCount)
                    {
                        cmd.SetRenderTarget(fogMaskTarget.Identifier(), RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
                        cmd.Blit(_src.id, BuiltinRenderTextureType.CurrentActive, _blurMat, 0);
                    }
                    else
                    {
                        cmd.SetRenderTarget(_dest.Identifier(), RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
                        cmd.Blit(_src.id, BuiltinRenderTextureType.CurrentActive, _blurMat, 0);
                    }
                }
                cmd.ReleaseTemporaryRT(_src.id);
                cmd.ReleaseTemporaryRT(_dest.id);
                cmd.Blit(fogMaskTarget.id, rt);
                cmd.ReleaseTemporaryRT(fogMaskTarget.id);
            }
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }
    }
}