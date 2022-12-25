using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public enum Resolution
    {
        _256 = 256,
        _512 = 512,
        _1024 = 1024,
    }

    [System.Serializable]
    public class WarFogSettings
    {
        public Resolution maskTexSize = Resolution._512;
        [Range(0, 2)]
        public float blurBase = 0.5f;
        [Range(0, 2)]
        public float blurStep = 0.7f;
        [Range(0, 10)]
        public float extSize = 1f;
        public Material fogBlurMat = null;
    }

    [System.Serializable]
    public class TerrainBlendSettings
    {
        public Resolution texSize = Resolution._512;
    }

    [System.Serializable]
    public class RadialBlurSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
        public Material radialBlurMat = null;
    }

    [System.Serializable]
    public class CloudShadowSettings
    {
        public Texture2D cloudTexture;
        public Material material;
        public Vector2 cloudTiling = new Vector2(2, 2);
        public Vector2 cloudWindSpeed = new Vector2(0.05f, 0.05f);
        public Color shadowColor = new Color(0f, 0.04f, 0.23f, 1f);
        [HideInInspector] public bool dirty = false;

        private int ShadowFactorID = Shader.PropertyToID("_ShadowFactor");

        public bool IsActive { get { return cloudTexture != null && material != null; } }

        public void UpdateMaterialArg()
        {
            dirty = false;
            if (material)
            {
                material.SetTexture("_CloudTex", cloudTexture);
                material.SetVector(ShadowFactorID, new Vector4(
                        (1f - shadowColor.r) * shadowColor.a
                        , (1f - shadowColor.g) * shadowColor.a
                        , (1f - shadowColor.b) * shadowColor.a
                        , 1f));
                material.SetVector("_CloudFactor", new Vector4(
                        cloudWindSpeed.x
                        , cloudWindSpeed.y
                        , cloudTiling.x
                        , cloudTiling.y));
            }
        }

        public void UpdateShadowColor(Color color)
        {
            shadowColor = color;
            dirty = true;
        }
    }

    [System.Serializable]
    public class TAASettings
    {
        [SerializeField]
        public bool Use32Bit = false;
        [SerializeField]
        public Shader Shader;

        [HideInInspector]
        public Material material;

        public bool GetMaterial()
        {
            if (material == null)
            {
                material = CoreUtils.CreateEngineMaterial(Shader);
                if (material == null)
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }
            else
            {
                return true;
            }
        }
    }

    [System.Serializable]
    public class WaveSettings
    {
        [SerializeField]
        public bool IsActive = false;
        [SerializeField]
        public Material drawMat;
        [SerializeField]
        public Material waveMat;
        [SerializeField]
        public float TouchWide = 1;
        //[HideInInspector]
        public RenderTexture rt1 = null;
        //[HideInInspector]
        public RenderTexture rt2 = null;
        //[HideInInspector]
        public RenderTexture rt3 = null;
    }


    public class MyRendererFeature : ScriptableRendererFeature
    {
        public static MyRendererFeature Instance = null;

        [Header("战争迷雾")]
        public WarFogSettings warFogSettings = new WarFogSettings();
        [Header("地形融合")]
        public TerrainBlendSettings terrainBlendSettings = new TerrainBlendSettings();
        [Header("径向模糊")]
        public RadialBlurSettings radialBlurSettings = new RadialBlurSettings();
        [Header("云投影")]
        public CloudShadowSettings cloudShadowSettings = new CloudShadowSettings();
        [Header("TAA")]
        public TAASettings tAASettings = new TAASettings();
        [Header("水波纹")]
        public WaveSettings waveSettings = new WaveSettings();

        private FogOfWarPass m_FOWPass;
        private EdgeDetectionPass m_edgeDetectionPass;
        private FogOfWarMaskPass m_fogMaskPass;
        private TerrainBlendPass m_terrainBlendPass;
        private RadialBlurPass m_radialBlurPass;
        private SaturationPass m_saturationPass;

        private BeforePostProcessingPass beforePostProcessingPass;

        private TAACameraPass m_TAACameraPass;
        private TAAPass m_TAAPass;
        private Dictionary<int, HaltonSequence> haltonSequences = new Dictionary<int, HaltonSequence>();
        private TAA taa;

        private ScriptableRenderPassInput input = ScriptableRenderPassInput.None;

        public override void Create()
        {
            Instance = this;
            if (warFogSettings.fogBlurMat == null)
            {
#if UNITY_EDITOR
                warFogSettings.fogBlurMat = CoreUtils.CreateEngineMaterial(Shader.Find("Post/GaussianBlur"));
#else
                warFogSettings.fogBlurMat = CoreUtils.CreateEngineMaterial(ShaderCollector.GetLoadedSharderByName("Post/GaussianBlur"));
#endif
            }
            if (radialBlurSettings.radialBlurMat == null)
            {
#if UNITY_EDITOR
                radialBlurSettings.radialBlurMat = CoreUtils.CreateEngineMaterial(Shader.Find("Post/RenderFeature/RadialBlur"));
//#else
                //radialBlurSettings.radialBlurMat = CoreUtils.CreateEngineMaterial(ShaderCollector.GetLoadedSharderByName("Post/RenderFeature/RadialBlur"));
#endif
            }
            m_FOWPass = new FogOfWarPass();
            m_edgeDetectionPass = new EdgeDetectionPass();
            m_fogMaskPass = new FogOfWarMaskPass(RenderPassEvent.BeforeRenderingOpaques);
            m_terrainBlendPass = new TerrainBlendPass(RenderPassEvent.BeforeRenderingOpaques);
            m_radialBlurPass = new RadialBlurPass();
            m_saturationPass = new SaturationPass();
            beforePostProcessingPass = new BeforePostProcessingPass();
            beforePostProcessingPass.SetCloudSettings(cloudShadowSettings);
            beforePostProcessingPass.SetWaveSettings(waveSettings);

            m_TAACameraPass = new TAACameraPass("TAACameraPass");
            m_TAACameraPass.renderPassEvent = RenderPassEvent.BeforeRenderingOpaques - 1;
            m_TAAPass = new TAAPass("TAA");
            m_TAAPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            m_TAAPass.canCopyTexture = SystemInfo.copyTextureSupport != CopyTextureSupport.None;

            OnValidate();
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (renderingData.cameraData.postProcessEnabled && (renderingData.cameraData.isGameMainCamera || renderingData.cameraData.isSceneViewCamera))
            {
                input = ScriptableRenderPassInput.None;
                if (m_edgeDetectionPass.AddRenderPasses(renderingData))
                    input |= ScriptableRenderPassInput.Normal;
                if (m_FOWPass.AddRenderPasses(renderingData))
                {
                    renderer.EnqueuePass(m_fogMaskPass);
                    input |= ScriptableRenderPassInput.Depth;
                }
                if (GlobalShaderData.IsRadialBlurEnable)
                {
                    renderer.EnqueuePass(m_radialBlurPass);
                }
                renderer.EnqueuePass(m_terrainBlendPass);
                m_saturationPass.AddRenderPasses(renderingData);

                #region TAA
                taa = VolumeManager.instance.stack.GetComponent<TAA>();
                if(taa.IsActive() && tAASettings.GetMaterial())
                {
                    input |= ScriptableRenderPassInput.Depth;
                    var camera = renderingData.cameraData.camera;
                    var proj = camera.projectionMatrix;
                    var view = camera.worldToCameraMatrix;
                    var viewProj = proj * view;
                    var hash = camera.GetHashCode();
                    HaltonSequence haltonSequence;

                    if (haltonSequences.ContainsKey(hash))
                    {
                        haltonSequence = haltonSequences[hash];
                        if(haltonSequence.fraction != taa.Fraction.value)
                            haltonSequence = new HaltonSequence(taa.SamplePointCount.value, taa.Fraction.value);
                    }
                    else
                    {
                        haltonSequence = new HaltonSequence(taa.SamplePointCount.value, taa.Fraction.value);
                    }

                    if (haltonSequence.prevViewProj == Matrix4x4.zero)
                    {
                        haltonSequence.prevViewProj = viewProj;
                    }

                    haltonSequence.Get(out float offsetX, out float offsetY);

                    var matrix = camera.projectionMatrix;
                    var descriptor = renderingData.cameraData.cameraTargetDescriptor;
                    if (camera.orthographic)
                    {
                        matrix[0, 3] -= (offsetX * 2 - 1) / descriptor.width;
                        matrix[1, 3] -= (offsetY * 2 - 1) / descriptor.height;
                    }
                    else
                    {
                        matrix[0, 2] += (offsetX * 2 - 1) / descriptor.width;
                        matrix[1, 2] += (offsetY * 2 - 1) / descriptor.height;
                    }

                    var offset = new Vector2(
                        (offsetX - 0.5f) / descriptor.width,
                        (offsetY - 0.5f) / descriptor.height);

                    Vector4 DitherOffset = new Vector4(offsetX, offsetY, offset.x, offset.y);

                    m_TAACameraPass.Setup(matrix, DitherOffset);
                    renderer.EnqueuePass(m_TAACameraPass);

                    m_TAAPass.Setup(
                        renderer.cameraColorTarget,
                        tAASettings.Use32Bit,
                        tAASettings.material,
                        haltonSequence.prevViewProj,
                        offset,
                        (float)taa.Blend,
                        (bool)taa.AntiGhosting,
                        taa.Sharpness.value
                        );
                    renderer.EnqueuePass(m_TAAPass);

                    haltonSequence.prevViewProj = viewProj;
                    haltonSequence.frameCount = Time.frameCount;
                    haltonSequences[hash] = haltonSequence;
                }
                if (haltonSequences.Count > 0)
                {
                    int[] rmArr = new int[8];
                    int index = 0;
                    foreach (var item in haltonSequences)
                    {
                        var haltonSequence = item.Value;
                        if (Time.frameCount - haltonSequence.frameCount > 10)
                        {
                            rmArr[index] = item.Key;
                            if (++index == 8) break;
                        }
                    }
                    if (index > 0)
                    {
                        for (int i = 0; i < index; i++)
                        {
                            haltonSequences.Remove(rmArr[i]);
                            m_TAAPass.Clear(rmArr[i]);
                        }
                        if (haltonSequences.Count == 0)
                        {
                            CoreUtils.Destroy(tAASettings.material);
                            tAASettings.material = null;
                        }
                    }
                }
                #endregion

                if (cloudShadowSettings.IsActive) input |= ScriptableRenderPassInput.Depth;
                beforePostProcessingPass.ConfigureInput(input);
                beforePostProcessingPass.SetTarget(renderer.cameraColorTarget);
                renderer.EnqueuePass(beforePostProcessingPass);
                if ((input & ScriptableRenderPassInput.Depth) != ScriptableRenderPassInput.None)
                    renderingData.cameraData.requiresDepthTexture = true;
            }
        }

        private void SetFogMaskPass()
        {
            if (m_fogMaskPass != null)
                m_fogMaskPass.SetConfig(warFogSettings);
        }

        private void SetTerrainBlendPass()
        {
            if (m_terrainBlendPass != null)
                m_terrainBlendPass.SetConfig(terrainBlendSettings);
        }

        private void SetRadialBlurPass()
        {
            if (m_radialBlurPass != null)
            {
                m_radialBlurPass.SetConfig(radialBlurSettings);
            }
        }

        private void OnValidate()
        {
            SetFogMaskPass();
            SetTerrainBlendPass();
            SetRadialBlurPass();
            cloudShadowSettings.UpdateMaterialArg();
        }

        private bool _needCalcRect = true;
        private Vector3 _pos, angles, _tempV1, _tempV2, _tempV3, _tempV4;
        private Vector2 _tempMax, _tempMin, _viewRectSize, _viewRectOffset;
        public bool CheckAndUpdateCameraPosArg(Camera mainCamera)
        {
#if UNITY_EDITOR
            if (!Application.isPlaying) _needCalcRect = true; 
#endif
            _pos = mainCamera.transform.position;
            angles = mainCamera.transform.eulerAngles;
            if (_needCalcRect || !_tempV2.Equals(_pos) || !_tempV1.Equals(angles))
            {
                _tempV1.Set(0, 1, 0);
                _tempV2 = GetPosByViewPoint(mainCamera, _tempV1);//左上角
                _tempV1.Set(1, 1, 0);
                _tempV3 = GetPosByViewPoint(mainCamera, _tempV1);//右上角
                _tempV1.Set(1, 0, 0);
                _tempV4 = GetPosByViewPoint(mainCamera, _tempV1);//右下角
                _tempV1 = GetPosByViewPoint(mainCamera, Vector3.zero);//左下角
                _tempMax.Set(Mathf.Max(_tempV1.x, _tempV2.x, _tempV3.x, _tempV4.x), Mathf.Max(_tempV1.z, _tempV2.z, _tempV3.z, _tempV4.z));
                _tempMin.Set(Mathf.Min(_tempV1.x, _tempV2.x, _tempV3.x, _tempV4.x), Mathf.Min(_tempV1.z, _tempV2.z, _tempV3.z, _tempV4.z));
                _viewRectSize.Set((_tempMax.x - _tempMin.x) / 2 + 1, (_tempMax.y - _tempMin.y) / 2 + 1);
                _viewRectOffset.Set((_tempMax.x + _tempMin.x) / 2 - _pos.x, (_tempMax.y + _tempMin.y) / 2 - _pos.z);
                _tempV1.Set(angles.x, angles.y, angles.z);
                _tempV2.Set(_pos.x, _pos.y,_pos.z);
                _needCalcRect = false;
#if UNITY_EDITOR
                if(!Application.isPlaying) _needCalcRect = true;
#endif


                m_terrainBlendPass.viewRectSize.Set(_viewRectSize.x, _viewRectSize.y);
                m_terrainBlendPass.viewRectOffset.Set(_viewRectOffset.x, _viewRectOffset.y);
                m_fogMaskPass.viewRectSize.Set(_viewRectSize.x, _viewRectSize.y);
                m_fogMaskPass.viewRectOffset.Set(_viewRectOffset.x, _viewRectOffset.y);
                return true;
            }
            return false;
        }

        private Ray ray;
        private Vector3 direction;
        public Vector3 GetPosByViewPoint(Camera cam, Vector3 viewPoint)
        {
            ray = cam.ViewportPointToRay(viewPoint);
            direction = ray.direction;
            if (direction.y > -0.02f)
            {//当这个射线朝向天上时，和地面的交点就在相机后面了，所以这时候让它继续朝下吧
                direction.y = -0.02f;
            }
            return ray.origin + direction * (-ray.origin.y / direction.y);
        }
    }

    struct HaltonSequence
    {
        int count;
        int index;
        float[] arrX;
        float[] arrY;

        public Matrix4x4 prevViewProj;
        public int frameCount;
        public float fraction;

        public HaltonSequence(int count, float frac)
        {
            this.count = count;
            fraction = frac;
            index = 0;
            arrX = new float[count];
            arrY = new float[count];
            prevViewProj = Matrix4x4.zero;
            frameCount = 0;
            for (int i = 0; i < arrX.Length; i++)
            {
                arrX[i] = get(i, 2);
            }

            for (int i = 0; i < arrY.Length; i++)
            {
                arrY[i] = get(i, 3);
            }
        }

        float get(int index, int @base)
        {
            float result = 0;
            float fraction = this.fraction; 

            while (index > 0)
            {
                fraction /= @base;
                result += fraction * (index % @base);
                index /= @base;
            }

            return result;
        }

        public void Get(out float x, out float y)
        {
            if (++index == count) index = 1;
            x = arrX[index];
            y = arrY[index];
        }
    }
}
