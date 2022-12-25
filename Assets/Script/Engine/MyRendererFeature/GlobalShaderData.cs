using DG.Tweening;
using GameEngine.MyRendererFeature;
using System;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GlobalShaderData : MonoBehaviour
{
    [System.Serializable]
    public class FogData
    {
        /*[Header("启用雾效")]
        public bool Enable;*/

        [Header("屏幕开始有雾的地方 0屏幕下方 100屏幕上方")]
        [Range(-300, 500)]
        public int FogStart;

        [Header("屏幕雾最浓的地方 0屏幕下方 100屏幕上方")]
        [Range(-300, 500)]
        public int FogEnd;

        [Header("屏幕圆弧半径")]
        [Range(0.5f, 5)]
        public float FogRadius;

        [Header("向上雾浓度")]
        [Range(0, 5)]
        public float HeightFogDensity;

        [Header("向上减淡高度")]
        [Range(-1000, 5000)]
        public int HeightFogEnd;

        [Header("地下起雾高度")]
        [Range(-5000, 5000)]
        public int HeightFogStart;

        [Header("向下加深结束高度")]
        [Range(-6000, 5000)]
        public int HeightFogLower;

        [Header("向下加深渐变强度")]
        [Range(0, 3)]
        public float LowerDensity;

        [Header("雾颜色")]
        public Color FogColor;

        [HideInInspector]
        public Vector4 FogInfo, FogDensity;

        public static int _HeightFogDensityId = Shader.PropertyToID("_HeightFogDensity");
        public static int _FogInfoId = Shader.PropertyToID("_FogInfo");
        public static int _FogColorId = Shader.PropertyToID("_FogColor");

        private int _aniFogStart, _aniHeightFogEnd;
        private float _aniHeightFogDensity;
        private Color _aniFogColor;
        private bool _isOnAni;

        public void Init()
        {
            FogStart = 50;
            FogEnd = 100;
            FogRadius = 1;
            HeightFogDensity = 1;
            HeightFogEnd = 300;
            HeightFogStart = -1;
            HeightFogLower = -10;
            LowerDensity = 1;
            FogColor = Color.white;
            _isOnAni = false;
        }
        public void RefreshData()
        {
            if (_isOnAni)
            {
                FogInfo.Set(_aniFogStart / 100f, FogEnd / 100f, _aniHeightFogEnd / 100f, HeightFogStart / 100f);
                FogDensity.Set(_aniHeightFogDensity, HeightFogLower / 100, LowerDensity, FogRadius);
                Shader.SetGlobalColor(_FogColorId, _aniFogColor);
            }
            else
            {
                FogInfo.Set(FogStart / 100f, FogEnd / 100f, HeightFogEnd / 100f, HeightFogStart / 100f);
                FogDensity.Set(HeightFogDensity, HeightFogLower / 100, LowerDensity, FogRadius);
                Shader.SetGlobalColor(_FogColorId, FogColor);
            }
            Shader.SetGlobalVector(_HeightFogDensityId, FogDensity);
            Shader.SetGlobalVector(_FogInfoId, FogInfo);
        }

        public void SetAniData(int aniFogStart, float aniHeightFogDensity, int aniHeightFogEnd, Color aniFogColor)
        {
            _isOnAni = true;
            _aniFogStart = aniFogStart;
            _aniHeightFogDensity = aniHeightFogDensity;
            _aniHeightFogEnd = aniHeightFogEnd;
            _aniFogColor = aniFogColor;
            RefreshData();
        }

        public void EndAni()
        {
            _isOnAni = false;
            RefreshData();
        }
    }
    [System.Serializable]
    public struct RadialBlurData
    {
        [Header("启用径向模糊")]
        public bool Enable;
        [Header("内圈半径")]
        public float CircleMin;
        [Header("外圈半径")]
        public float CircleMax;
        [Header("模糊强度")]
        [Range(0, 20)]
        public float Intensity;
        [Header("亮度增强(负值为减弱)")]
        [Range(-2, 2)]
        public float Bright;
        [Header("采样次数(默认6次)")]
        [Range(1, 12)]
        public int Pow;

        /*public float firstLifeTime;
        public float secondLifeTime;
        public float maxRangeX;*/

        Vector4 blurParam;
        private readonly static int BlurParamID = Shader.PropertyToID("_RadialBlurParam");
        private readonly static int BlurPowID = Shader.PropertyToID("_Pow");
        public void Init()
        {
            Intensity = 1;
            CircleMin = 0.5f;
            CircleMax = 1;
            Bright = 0.5f;
            Pow = 6;
        }

        public void RefreshData()
        {
            blurParam.x = Intensity * 0.01f;
            blurParam.y = CircleMin;
            blurParam.z = CircleMax;
            blurParam.w = Bright;
            Shader.SetGlobalVector(BlurParamID, blurParam);
            Shader.SetGlobalInt(BlurPowID, Pow);
        }
    }

    [System.Serializable]
    public struct DayNightData
    {
        [Header("主方向光")]
        public Light mainLight;
        [Header("太阳升起角度")]
        public Quaternion startAngle;
        //public DirLightData startData;
        [Header("中午角度")]
        public Quaternion midAngle;
        //public DirLightData midData;
        [Header("太阳下山角度")]
        public Quaternion endAngle;
        //public DirLightData endData;
        [Header("光照颜色")]//主干上有重名的类，这里要加上UnityEngine.
        public UnityEngine.Gradient color;
        [Header("光照强度")]
        public AnimationCurve intensity;
        [Header("时间")]
        [Range(0,1)]
        public float lerp;

        public void Init()
        {
            startAngle = Quaternion.Euler(35, 315, 270);
            midAngle = Quaternion.Euler(90, 45, 0);
            endAngle = Quaternion.Euler(35, 135, 90);
            intensity = new AnimationCurve();
            intensity.AddKey(new Keyframe(0, 0.1f));
            intensity.AddKey(new Keyframe(0.5f, 1f));
            intensity.AddKey(new Keyframe(1, 0.1f));
            lerp = 0.3f;
        }

        public void UpdateLightArg()
        {
            if (mainLight != null)
            {
                if (lerp <= 0.5f)
                {
                    mainLight.transform.rotation = Quaternion.LerpUnclamped(startAngle, midAngle, lerp / 0.5f);
                }
                else
                {
                    mainLight.transform.rotation = Quaternion.LerpUnclamped(midAngle, endAngle, (lerp - 0.5f) / 0.5f);
                }
                mainLight.color = color.Evaluate(lerp);
                mainLight.intensity = intensity.Evaluate(lerp);
            }
        }
    }

    [System.Serializable]
    public struct FogAniData
    {
        public int aniFogStart;
        public float aniHeightFogDensity;
        public int aniHeightFogEnd;
        public Color aniFogColor;
        [Space]
        public AnimationCurve open_FogStart;
        public AnimationCurve open_HeightFogDensity;
        public AnimationCurve open_HeightFogEnd;
        public AnimationCurve open_FogColor;
        [Space]
        public AnimationCurve close_FogStart;
        public AnimationCurve close_HeightFogDensity;
        public AnimationCurve close_HeightFogEnd;
        public AnimationCurve close_FogColor;

        public void Init()
        {
            aniFogStart = -50;
            aniHeightFogDensity = 3;
            aniHeightFogEnd = 500;
            aniFogColor = Color.white;
            open_FogStart = new AnimationCurve(new Keyframe[] { new Keyframe(0, 0, 2, 2), new Keyframe(1, 1, 0, 0) });
            open_HeightFogDensity = new AnimationCurve(new Keyframe[] { new Keyframe(0, 0, 0, 0), new Keyframe(1, 1, 2, 2) });
            open_HeightFogEnd = new AnimationCurve(new Keyframe[] { new Keyframe(0, 0, 0, 0), new Keyframe(1, 1, 2, 2) });
            open_FogColor = new AnimationCurve(new Keyframe[] { new Keyframe(0, 0, 2, 2), new Keyframe(1, 1, 0, 0) });
            close_FogStart = new AnimationCurve(new Keyframe[] { new Keyframe(0, 0, 2, 2), new Keyframe(1, 1, 0, 0) });
            close_HeightFogDensity = new AnimationCurve(new Keyframe[] { new Keyframe(0, 0, 0, 0), new Keyframe(1, 1, 2, 2) });
            close_HeightFogEnd = new AnimationCurve(new Keyframe[] { new Keyframe(0, 0, 0, 0), new Keyframe(1, 1, 2, 2) });
            close_FogColor = new AnimationCurve(new Keyframe[] { new Keyframe(0, 0, 2, 2), new Keyframe(1, 1, 0, 0) });
        }

        public void SetOpenAniValue(float v, FogData fogData)
        {
            fogData.SetAniData(
                fogData.FogStart + (int)(open_FogStart.Evaluate(v) * (aniFogStart - fogData.FogStart)),
                Mathf.Lerp(fogData.HeightFogDensity, aniHeightFogDensity, open_HeightFogDensity.Evaluate(v)),
                fogData.HeightFogEnd + (int)(open_HeightFogEnd.Evaluate(v) * (aniHeightFogEnd - fogData.HeightFogEnd)),
                Color.Lerp(fogData.FogColor, aniFogColor, v)
            );
        }

        public void SetCloseAniValue(float v, FogData fogData)
        {
            fogData.SetAniData(
                aniFogStart + (int)(close_FogStart.Evaluate(v) * (fogData.FogStart - aniFogStart)),
                Mathf.Lerp(aniHeightFogDensity, fogData.HeightFogDensity, close_HeightFogDensity.Evaluate(v)),
                aniHeightFogEnd + (int)(close_HeightFogEnd.Evaluate(v) * (fogData.HeightFogEnd - aniHeightFogEnd)),
                Color.Lerp(aniFogColor, fogData.FogColor, v)
            );
        }
    }
    
    static GlobalShaderData _instance = null;
    public static GlobalShaderData Instance => _instance;
    [Header("全局雾效参数")]
    public FogData fogData;
    [Header("径向模糊参数")]
    public RadialBlurData radialBlurData;
    [Header("昼夜变化参数")]
    public DayNightData dayNightData;
    [Header("迷雾动画参数")]
    public FogAniData fogAniData;

    public static bool IsRadialBlurEnable
    {
        get
        {
            if (_instance) return _instance.radialBlurData.Enable;
            return false;
        }
    }

    [HideInInspector]
    public bool dirty = true;

    private void Awake()
    {
        if(_instance == null)
        {
            _instance = this;
        }
        else
        {
            //Debug.LogError("已经有一个全局的GlobalShaderData代码了，绑定在：" + _instance.gameObject.name);
            //GameObject.DestroyImmediate(this);
            return;
        }
        SetAllValue();
    }

    public GlobalShaderData()
    {
        //fogData.Init();
        radialBlurData.Init();
        dayNightData.Init();
        fogAniData.Init();
        radialBlurEff = new RadialBlurEff();
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        dirty = true;

        ClampValueInInspector();
        //if (!Application.isPlaying && isActiveAndEnabled)
        //    SetAllValue(); 
    }
    void ClampValueInInspector()
    {
        if (fogData.FogEnd <= fogData.FogStart) fogData.FogEnd = fogData.FogStart + 1;
        if (fogData.HeightFogEnd <= fogData.HeightFogStart) fogData.HeightFogEnd = fogData.HeightFogStart + 1;
        if (fogData.HeightFogStart <= fogData.HeightFogLower) fogData.HeightFogLower = fogData.HeightFogStart - 1;
    }

#endif
    public void SetAllValue()
    {
        dirty = false;
#if UNITY_EDITOR
        if (_instance != this && _instance != null)
        {
            Debug.LogError("已经有一个全局的GlobalShaderData代码了，绑定在：" + _instance.gameObject.name);
            return;
        }
#endif
        fogData.RefreshData();
        radialBlurData.RefreshData();
        dayNightData.UpdateLightArg();
    }

    public void EnableRadialBlur(bool enable)
    {
        radialBlurData.Enable = enable;
    }

    private void Reset()
    {
        fogData.Init();
        radialBlurData.Init();
        dayNightData.Init();
        fogAniData.Init();
    }

    private void Update()
    {
#if UNITY_EDITOR//编辑器下修改这个代码的时候重新编译后_instance会为空
        if (_instance == null)
            _instance = this; 
#endif
        if (dirty)
            SetAllValue();
        
        radialBlurEff.UpdateEff();
    }

    #region 迷雾开关动画
    private static bool _isOnOpenAni = false;
    private static Queue<Action> _onAniOpenEnds = new Queue<Action>();
    private static bool _isOnCloseAni = false;
    private static Queue<Action> _onAniCloseEnds = new Queue<Action>();
    private static Tweener tweener;
    private CloudShadowSettings _cloudShadowSettings = null;
    private Color _aniCacheCloudColor = Color.gray;
    private Color _aniCloudColor = Color.gray;

    public void AniOpenView(float time, Action onEnd = null)
    {
        if(MyRendererFeature.Instance!= null)
        {
            _cloudShadowSettings = MyRendererFeature.Instance.cloudShadowSettings;
        }
        if (onEnd != null)
            _onAniOpenEnds.Enqueue(onEnd);
        if (_isOnOpenAni) return;
        _isOnOpenAni = true;
        if (_isOnCloseAni)//正在关闭的时候调用了打开
        {
            _isOnCloseAni = false;//停掉关闭
            while (_onAniCloseEnds.Count > 0) _onAniCloseEnds.Dequeue()();//调用关闭完成回调
        }
        else
        {
            //_aniCacheFogStart = fogData.FogStart;
            //_aniCacheHeightFogDensity = fogData.HeightFogDensity;
            //_aniCacheHeightFogEnd = fogData.HeightFogEnd;
            if (_cloudShadowSettings != null)
            {
                _aniCacheCloudColor = _cloudShadowSettings.shadowColor;
                _aniCloudColor.r = _aniCacheCloudColor.r;
                _aniCloudColor.g = _aniCacheCloudColor.g;
                _aniCloudColor.b = _aniCacheCloudColor.b;
                _aniCloudColor.a = 0;
            }
        }
        if (tweener != null) tweener.Kill(true);
        float value = 0;
        tweener = DOTween.To(() => value, v =>
        {
            value = v; 
            fogAniData.SetOpenAniValue(v, fogData);
            if (_cloudShadowSettings != null)
            {
                _cloudShadowSettings.UpdateShadowColor(Color.Lerp(_aniCacheCloudColor, _aniCloudColor, v));
            }
        }, 1f, time);
        tweener.SetTarget(this);
        tweener.onComplete = () =>
        {
            tweener = null;
            _isOnOpenAni = false;
            while (_onAniOpenEnds.Count > 0) _onAniOpenEnds.Dequeue()();
        };
    }

    public void AniCloseView(float time, Action onEnd = null)
    {
        if (onEnd != null)
            _onAniCloseEnds.Enqueue(onEnd);
        if (_isOnCloseAni) return;
        _isOnCloseAni = true;
        if (_isOnOpenAni)
        {
            _isOnOpenAni = false;
            while (_onAniOpenEnds.Count > 0) _onAniOpenEnds.Dequeue()();
        }
        if (tweener != null) tweener.Kill(true);
        float value = 0;
        tweener = DOTween.To(() => value, v =>
        {
            value = v; 
            fogAniData.SetCloseAniValue(v, fogData);
            if (_cloudShadowSettings != null)
            {
                _cloudShadowSettings.UpdateShadowColor(Color.Lerp(_aniCloudColor, _aniCacheCloudColor, v));
            }
        }, 1f, time);
        tweener.SetTarget(this);
        tweener.onComplete = () =>
        {
            tweener = null;
            _isOnCloseAni = false;
            while (_onAniCloseEnds.Count > 0) _onAniCloseEnds.Dequeue()();
            fogData.EndAni();
        };
    }
    #endregion

    public class RadialBlurEff
    {
        bool enable = false;
        bool _isCameraUp = true;

        //径向模糊第一段动画时间
        public float firstBlurTime = 0.4f;
        //径向模糊第二段动画时间
        public float secondBlurTime = 0.1f;
        //低镜头外圈初始半径
        public float lowCircle = 2;
        //高镜头外圈初始半径
        public float highCircle = 1;
        //高镜头后外圈初始半径
        public float highAfterCircle = 3;
        //低镜头初始模糊强度
        public float lowIntensity = 0.5f;
        //高镜头初始模糊强度
        public float highIntensity = 1.7f;
        //高镜头后初始模糊强度
        public float highAfterIntensity = 1;
        

        private float _blurMoveTime = 0;
        private float _blurChangeTime1;
        private float _blurChangeTime2;
        
        public void EnableEff(bool _isCameraUp)
        {
            this.enable = true;
            _blurMoveTime = 0;
            _blurChangeTime2 = 0;
            this._isCameraUp = _isCameraUp;
            _blurChangeTime1 = firstBlurTime;
            _instance.EnableRadialBlur(true);
        }
        public void DisableEff()
        {
            this.enable = false;
            _blurChangeTime1 = 0;
            _blurMoveTime = 0;
            _blurChangeTime2 = 0;
            _instance.EnableRadialBlur(false);
        }

        //Update
        public void UpdateEff()
        {
            if (!enable)
                return;

            if (_blurChangeTime1 > 0)
            {
                _blurMoveTime += Time.deltaTime;
                if (_isCameraUp)
                {
                    _instance.radialBlurData.CircleMax = Mathf.Lerp(lowCircle, highCircle, _blurMoveTime / _blurChangeTime1);
                    _instance.radialBlurData.Intensity = Mathf.Lerp(lowIntensity, highIntensity, _blurMoveTime / _blurChangeTime1);
                }
                else
                {
                    _instance.radialBlurData.CircleMax = Mathf.Lerp(highCircle, lowCircle, _blurMoveTime / _blurChangeTime1);
                    _instance.radialBlurData.Intensity = Mathf.Lerp(highIntensity, lowIntensity, _blurMoveTime / _blurChangeTime1);
                }

                if (_blurMoveTime >= _blurChangeTime1)
                {
                    _blurChangeTime1 = 0;
                    _blurMoveTime = 0;
                    if (_isCameraUp)
                    {
                        _blurChangeTime2 = secondBlurTime;
                    }
                    else
                    {
                        _instance.EnableRadialBlur(false);
                        enable = false;
                    }
                }

                _instance.radialBlurData.RefreshData();

            }

            if (_blurChangeTime2 > 0)
            {
                _blurMoveTime += Time.deltaTime;
                _instance.radialBlurData.CircleMax = Mathf.Lerp(highCircle, highAfterCircle, _blurMoveTime / _blurChangeTime2);
                _instance.radialBlurData.Intensity = Mathf.Lerp(highIntensity, highAfterIntensity, _blurMoveTime / _blurChangeTime2);
                if (_blurMoveTime >= _blurChangeTime2)
                {
                    _blurChangeTime2 = 0;
                    _blurMoveTime = 0;
                    _instance.EnableRadialBlur(false);
                    enable = false;
                    _instance.radialBlurData.CircleMax = highCircle;
                    _instance.radialBlurData.Intensity = highIntensity;
                }

                _instance.radialBlurData.RefreshData();
            }

        }
    }
    public RadialBlurEff radialBlurEff;

}
