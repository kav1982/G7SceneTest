using UnityEditor;
using UnityEngine;
using BioumRP;
//using ShaderStandard;

public class SceneSimpleLitGUI : ShaderGUI
{
    public enum BlendMode
    {
        Opaque,
        Cutout,
        Transparent,
    }
    public enum CullMode
    {
        Back,
        Double,
    }

    private static class Styles
    {
        public static string renderingMode = "混合模式";
        public static string cullingMode = "裁剪模式";
        public static readonly string[] blendNames = { "不透明", "透贴", "半透明"};
        public static readonly string[] RenderQueueType = { "默认", "自定义" };
        public static readonly string[] cullNames = { "正面显示", "双面显示" };
        public static GUIContent baseMapText = new GUIContent("颜色贴图");
        public static GUIContent normalMapText = new GUIContent("法线(AG)");
        public static GUIContent emissiveAOMapText = new GUIContent("自发光(RGB) AO(A)");
        public static GUIContent maskMapText = new GUIContent("Mask R:描边");
    }

    MaterialProperty _BlendMode = null;
    MaterialProperty _CullMode = null;

    MaterialProperty _BaseMap = null;
    MaterialProperty _BaseColor = null;
    MaterialProperty _PenumbraTintColor = null;
    MaterialProperty _MaskMap = null;

    MaterialProperty _NormalMetalSmoothMap = null;
    MaterialProperty _NormalScale = null;
    MaterialProperty _NormalAOParam = null;
    
    MaterialProperty _EmissiveColor = null;
    MaterialProperty _EmissiveBake = null;
    MaterialProperty _EmissiveBakeBoost = null;
    MaterialProperty _EmissiveAOMap = null;
    MaterialProperty _EmissiveAOMapUseUV2 = null;
    
    MaterialProperty _AOStrength = null;
    
    MaterialProperty _Transparent = null;
    MaterialProperty _Cutoff = null;
    MaterialProperty _TransparentZWrite = null;
    MaterialProperty _TransparentShadowCaster = null;
    MaterialProperty _TransparentParam = null;
    
    MaterialProperty _WindToggle = null;
    MaterialProperty _WindScale = null;
    MaterialProperty _WindSpeed = null;
    MaterialProperty _WindDirection = null;
    MaterialProperty _WindIntensity = null;
    MaterialProperty _WindParam = null;

    MaterialProperty _TerrainBlendToggle = null;
    MaterialProperty _TerrainBlendHeight = null;
    MaterialProperty _TerrainBlendFalloff = null;
    MaterialProperty _TerrainBlendParam = null;

    MaterialProperty _OutlineToggle = null;
    MaterialProperty _EdgeMaskScale = null;
    MaterialProperty _EdgeThred = null;
    MaterialProperty _EdgePow = null;
    MaterialProperty _EdgeColor = null;
    MaterialProperty _EdgeAngle = null;
    MaterialProperty _EdgeAngleScale = null;
    MaterialProperty _EdgeParam = null;

    MaterialProperty _DarkPartToggle = null;
    MaterialProperty _DarkPartColor = null;
    MaterialProperty _Contrast = null;
    MaterialProperty _DarkLigthIntensity = null;
    MaterialProperty _YClip = null;
    MaterialProperty _YAtten = null;
    MaterialProperty _DarkParam = null;
    MaterialProperty _AddColorToggle = null;

    MaterialProperty _Stencil = null;
    MaterialProperty _StencilComp = null;

    MaterialProperty _ButGradientToggle = null;
    MaterialProperty _ButGradientCol = null;
    MaterialProperty _ButGradientIntensity = null;
    MaterialProperty _YClipBut = null;
    MaterialProperty _YAttenBut = null;
    MaterialProperty _ButGradientParam = null;
    MaterialProperty _RenderQueue = null;

    MaterialProperty _TestValue = null;
    MaterialProperty _VertexAO = null;
    MaterialProperty _VertexAOStrength = null;
    MaterialProperty _VertexAOCol = null;
    MaterialProperty _AOColStrength = null;
    MaterialProperty _VertexAOParam = null;
    int CustomRenderQueue;
    int RenderQueueOffset = 0;

    MaterialEditor m_MaterialEditor;

    public void FindProperties(MaterialProperty[] props)
    {
        _BlendMode = FindProperty("_BlendMode", props);
        _CullMode = FindProperty("_CullMode", props);
        
        _BaseMap = FindProperty("_BaseMap", props);
        _BaseColor = FindProperty("_BaseColor", props);
        _PenumbraTintColor = FindProperty("_PenumbraTintColor", props);
        _MaskMap = FindProperty("_MaskMap", props);

        _NormalMetalSmoothMap = FindProperty("_NormalMetalSmoothMap", props);
        _NormalScale = FindProperty("_NormalScale", props);
        _NormalAOParam = FindProperty("_NormalAOParam", props);
        
        _EmissiveColor = FindProperty("_EmissiveColor", props);
        _EmissiveBake = FindProperty("_EmissiveBake", props);
        _EmissiveBakeBoost = FindProperty("_EmissiveBakeBoost", props);
        _EmissiveAOMap = FindProperty("_EmissiveAOMap", props);
        _EmissiveAOMapUseUV2 = FindProperty("_EmissiveAOMapUseUV2", props);
        
        _AOStrength = FindProperty("_AOStrength", props);
        _Transparent = FindProperty("_Transparent", props);
        _Cutoff = FindProperty("_Cutoff", props);
        _TransparentZWrite = FindProperty("_TransparentZWrite", props);
        _TransparentShadowCaster = FindProperty("_TransparentShadowCaster", props);
        _TransparentParam = FindProperty("_TransparentParam", props);
        
        _WindToggle = FindProperty("_WindToggle", props);
        _WindScale = FindProperty("_WindScale", props);
        _WindSpeed = FindProperty("_WindSpeed", props);
        _WindDirection = FindProperty("_WindDirection", props);
        _WindIntensity = FindProperty("_WindIntensity", props);
        _WindParam = FindProperty("_WindParam", props);

        _TerrainBlendToggle = FindProperty("_TerrainBlendToggle", props);
        _TerrainBlendHeight = FindProperty("_TerrainBlendHeight", props);
        _TerrainBlendFalloff = FindProperty("_TerrainBlendFalloff", props);
        _TerrainBlendParam = FindProperty("_TerrainBlendParam", props);

        _OutlineToggle = FindProperty("_OutlineToggle", props);
        _EdgeMaskScale = FindProperty("_EdgeMaskScale", props);
        _EdgeThred = FindProperty("_EdgeThred", props);
        _EdgePow = FindProperty("_EdgePow", props);
        _EdgeAngle = FindProperty("_EdgeAngle", props);
        _EdgeAngleScale = FindProperty("_EdgeAngleScale", props);
        _EdgeColor = FindProperty("_EdgeColor", props);
        _EdgeParam = FindProperty("_EdgeParam", props);

        _DarkPartToggle = FindProperty("_DarkPartToggle", props);
        _DarkPartColor = FindProperty("_DarkPartColor", props);
        _Contrast = FindProperty("_Contrast", props);
        _DarkLigthIntensity = FindProperty("_DarkLigthIntensity", props);
        _YClip = FindProperty("_YClip", props);
        _YAtten = FindProperty("_YAtten", props); 
        _DarkParam = FindProperty("_DarkParam", props);
        _AddColorToggle = FindProperty("_AddColorToggle", props);

        _Stencil = FindProperty("_Stencil", props);
        _StencilComp = FindProperty("_StencilComp", props);

        _ButGradientToggle = FindProperty("_ButGradientToggle", props);
        _ButGradientCol = FindProperty("_ButGradientCol", props);
        _ButGradientIntensity = FindProperty("_ButGradientIntensity", props);
        _YClipBut = FindProperty("_YClipBut", props);
        _YAttenBut = FindProperty("_YAttenBut", props);
        _ButGradientParam = FindProperty("_ButGradientParam", props);
        _RenderQueue = FindProperty("_RenderQueue", props);

        _TestValue = FindProperty("_TestValue", props);
        _VertexAO = FindProperty("_VertexAO", props);
        _VertexAOStrength = FindProperty("_VertexAOStrength", props);
        _VertexAOCol = FindProperty("_VertexAOCol", props);
        _AOColStrength = FindProperty("_AOColStrength", props);
        _VertexAOParam = FindProperty("_VertexAOParam", props);    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        material.doubleSidedGI = true;

        FindProperties(props);
        RenderMode(material);
        ShaderPropertiesGUI(material);

        EditorGUILayout.Space();
        //m_MaterialEditor.RenderQueueField();
        m_MaterialEditor.EnableInstancingField();
        //m_MaterialEditor.DoubleSidedGIField();
    }

    void RenderMode(Material material)
    {
        SetupMaterialWithBlendMode(material, (BlendMode) _BlendMode.floatValue);
        SetupMaterialWithCullMode(material, (CullMode) _CullMode.floatValue);
    }

    private int _renderQueueMin;
    private int _renderQueueMax;
    public void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        bool top = material.renderQueue >= 2200;//是否在行军线上面
        top = EditorGUILayout.Toggle("在行军线上面", top);
        switch (blendMode)
        {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "Opaque");
                material.SetKeyword("_ALPHATEST_ON", false);
                material.SetInt("_ZWrite", 1);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                if (_RenderQueue.floatValue == 0)
                    material.renderQueue = top ? 2200 : (int)UnityEngine.Rendering.RenderQueue.Geometry;
                else
                    CustomRenderQueue = top ? 2200 : (int)UnityEngine.Rendering.RenderQueue.Geometry;
                if (top)
                {
                    _renderQueueMin = 0;
                    _renderQueueMax = 50;
                }
                else
                {
                    _renderQueueMin = -5;
                    _renderQueueMax = 45;
                }
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetKeyword("_ALPHATEST_ON", true);
                material.SetInt("_ZWrite", 1);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                if (_RenderQueue.floatValue == 0)
                    material.renderQueue = top ? (int)UnityEngine.Rendering.RenderQueue.AlphaTest : (int)UnityEngine.Rendering.RenderQueue.Geometry + 1;
                else
                    CustomRenderQueue = top ? (int)UnityEngine.Rendering.RenderQueue.AlphaTest : (int)UnityEngine.Rendering.RenderQueue.Geometry + 1;
                _renderQueueMin = 0;
                _renderQueueMax = 50;
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetKeyword("_ALPHATEST_ON", false);
                material.SetInt("_ZWrite", (int)_TransparentZWrite.floatValue);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                if (_RenderQueue.floatValue == 0)
                    material.renderQueue = top ? (int)UnityEngine.Rendering.RenderQueue.Transparent : (int)UnityEngine.Rendering.RenderQueue.Geometry + 1;
                else
                    CustomRenderQueue = top ? (int)UnityEngine.Rendering.RenderQueue.Transparent : (int)UnityEngine.Rendering.RenderQueue.Geometry + 1;
                _renderQueueMin = 0;
                _renderQueueMax = 50;
                break;
        }
    }
    public void SetupMaterialWithCullMode(Material material, CullMode cullMode)
    {
        switch (cullMode)
        {
            case CullMode.Back:
                material.SetInt("_Cull", (int) UnityEngine.Rendering.CullMode.Back);
                break;
            case CullMode.Double:
                material.SetInt("_Cull", (int) UnityEngine.Rendering.CullMode.Off);
                break;
        }
    }

    const int indent = 1;
    public void ShaderPropertiesGUI(Material material)
    {
        EditorGUILayout.HelpBox("当前渲染队列:" + material.renderQueue.ToString(), MessageType.Info);
        Popup(_BlendMode, Styles.renderingMode, Styles.blendNames);
        Popup(_RenderQueue, "渲染队列设置", Styles.RenderQueueType);

        Color mainColor = _BaseColor.colorValue;
        if (_RenderQueue.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            //CustomRenderQueue = material.renderQueue;
            //EditorGUILayout.HelpBox(RenderQueueStandard.RenderQueueInfo(), MessageType.Info);
            RenderQueueOffset = Mathf.Clamp(material.renderQueue - CustomRenderQueue, _renderQueueMin, _renderQueueMax);
            RenderQueueOffset = EditorGUILayout.IntSlider("渲染队列排序调整",RenderQueueOffset, _renderQueueMin, _renderQueueMax);
            material.renderQueue = CustomRenderQueue + RenderQueueOffset;
            EditorGUI.indentLevel--;
        }
        switch ((BlendMode) _BlendMode.floatValue)
        {
            case BlendMode.Cutout:
                material.SetKeyword("_DITHER_CLIP", false);
                m_MaterialEditor.ShaderProperty(_Cutoff, "透贴强度", indent);
                mainColor.a = 1;
                break;
            case BlendMode.Transparent:
                m_MaterialEditor.ShaderProperty(_Transparent, "透明度", indent);
                m_MaterialEditor.ShaderProperty(_TransparentZWrite, "Z写入", indent);
                m_MaterialEditor.ShaderProperty(_TransparentShadowCaster, "半透明阴影", indent);
                material.SetKeyword("_DITHER_CLIP", _TransparentShadowCaster.floatValue != 0);
                mainColor.a = _Transparent.floatValue;
                break;
            case BlendMode.Opaque:
                material.SetKeyword("_DITHER_CLIP", false);
                mainColor.a = 1;
                break;
        }

        Popup(_CullMode, Styles.cullingMode, Styles.cullNames);
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_PenumbraTintColor, "暗部颜色");

        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.baseMapText, _BaseMap, _BaseColor);
        // 烘焙需要的颜色参数
        material.SetTexture("_MainTex", _BaseMap.textureValue);
        material.SetColor("_Color", mainColor);
        m_MaterialEditor.TexturePropertySingleLine(Styles.maskMapText, _MaskMap);

        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, _NormalMetalSmoothMap);
        if (_NormalMetalSmoothMap.textureValue != null)
            m_MaterialEditor.ShaderProperty(_NormalScale, "法线强度", indent);
        //m_MaterialEditor.ShaderProperty(_PaperToggle, "扁平化");
        
        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.emissiveAOMapText, _EmissiveAOMap);
        if (_EmissiveAOMap.textureValue != null)
        {
            m_MaterialEditor.ShaderProperty(_EmissiveAOMapUseUV2, "使用2U", indent);
            m_MaterialEditor.ShaderProperty(_AOStrength, "AO强度", indent);
        }
        m_MaterialEditor.ShaderProperty(_EmissiveColor, "自发光", indent);
        m_MaterialEditor.ShaderProperty(_EmissiveBake, "自发光参与烘焙", indent);
        m_MaterialEditor.ShaderProperty(_EmissiveBakeBoost, "烘焙亮度增强", indent);
        Color emi = _EmissiveColor.colorValue;
        emi.a = _EmissiveBakeBoost.floatValue;
        _EmissiveColor.colorValue = emi;
        material.globalIlluminationFlags = _EmissiveBake.floatValue != 0
            ? MaterialGlobalIlluminationFlags.BakedEmissive
            : MaterialGlobalIlluminationFlags.None;
        
        _NormalAOParam.vectorValue = new Vector4(
            _NormalScale.floatValue, _AOStrength.floatValue, _EmissiveAOMapUseUV2.floatValue);
       

        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_VertexAO, "顶点色AO开关");
        if(_VertexAO.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_VertexAOStrength, "顶点色AO强度");
            m_MaterialEditor.ShaderProperty(_VertexAOCol, "AO颜色");
            m_MaterialEditor.ShaderProperty(_AOColStrength, "AO颜色强度");
            _VertexAOParam.vectorValue = new Vector4(_VertexAOStrength.floatValue, _AOColStrength.floatValue, 0, 0);
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.Space();

        m_MaterialEditor.ShaderProperty(_OutlineToggle, "描边");
        if (_OutlineToggle.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_EdgeMaskScale, "Mask强度");
            m_MaterialEditor.ShaderProperty(_EdgeThred, "边缘阈值");
            m_MaterialEditor.ShaderProperty(_EdgePow, "边缘过渡");
            //m_MaterialEditor.ShaderProperty(_EdgeAngle, "角度偏移 -左 +右");
            //m_MaterialEditor.ShaderProperty(_EdgeAngleScale, "偏移影响强度");
            m_MaterialEditor.ShaderProperty(_EdgeColor, "颜色");
            _EdgeParam.vectorValue = new Vector4(
                _EdgeMaskScale.floatValue, _EdgeThred.floatValue, _EdgePow.floatValue, _EdgeAngle.floatValue);
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_DarkPartToggle, "顶部上色");
        if (_DarkPartToggle.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_AddColorToggle, "添加颜色");
            if (_AddColorToggle.floatValue != 0)
            {
                m_MaterialEditor.ShaderProperty(_DarkPartColor, "顶部添加色");
                m_MaterialEditor.ShaderProperty(_DarkLigthIntensity, "添加色强度");
            }
            else
            {
                m_MaterialEditor.ShaderProperty(_DarkPartColor, "顶部替换色");
                m_MaterialEditor.ShaderProperty(_DarkLigthIntensity, "替换色强度");
            }
            m_MaterialEditor.ShaderProperty(_Contrast, "对比度");
            m_MaterialEditor.ShaderProperty(_YClip, "Y轴剔除");
            m_MaterialEditor.ShaderProperty(_YAtten, "Y轴颜色过渡");
            _DarkParam.vectorValue = new Vector4(
                _Contrast.floatValue, _DarkLigthIntensity.floatValue, _YClip.floatValue, _YAtten.floatValue);
            EditorGUI.indentLevel--;
        }
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_ButGradientToggle, "底部上色");
        if(_ButGradientToggle.floatValue != 0)
        {
            m_MaterialEditor.ShaderProperty(_ButGradientCol, "底部渐变色");
            m_MaterialEditor.ShaderProperty(_ButGradientIntensity, "渐变色强度");
            m_MaterialEditor.ShaderProperty(_YClipBut, "Y轴剔除");
            m_MaterialEditor.ShaderProperty(_YAttenBut, "Y轴颜色过渡");
            _ButGradientParam.vectorValue = new Vector4(_ButGradientIntensity.floatValue, _YClipBut.floatValue, _YAttenBut.floatValue, 1);
        }


        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_WindToggle, "风");
        if(_WindToggle.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_WindScale, "紊乱");
            m_MaterialEditor.ShaderProperty(_WindSpeed, "速度");
            m_MaterialEditor.ShaderProperty(_WindIntensity, "强度");
            m_MaterialEditor.ShaderProperty(_WindDirection, "方向");
            float radian = _WindDirection.floatValue * Mathf.Deg2Rad;
            float x = Mathf.Cos(radian) * _WindIntensity.floatValue;
            float y = Mathf.Sin(radian) * _WindIntensity.floatValue;
            _WindParam.vectorValue = new Vector4(x, y, _WindScale.floatValue, _WindSpeed.floatValue);
            EditorGUI.indentLevel--;
        }
        else
        {
            _WindParam.vectorValue = Vector4.zero;
        }

        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_TerrainBlendToggle, "地形混合");
        if (_TerrainBlendToggle.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_TerrainBlendHeight, "混合高度");
            m_MaterialEditor.ShaderProperty(_TerrainBlendFalloff, "衰减过度");
            _TerrainBlendParam.vectorValue = new Vector4(_TerrainBlendHeight.floatValue, _TerrainBlendFalloff.floatValue, _EdgeAngleScale.floatValue);
            EditorGUI.indentLevel--;
        }

        _TransparentParam.vectorValue = new Vector4(_Transparent.floatValue, _Cutoff.floatValue, _WindToggle.floatValue);

        //EditorGUILayout.Space(20);
        //m_MaterialEditor.ShaderProperty(_Stencil, "蒙版值");
        //m_MaterialEditor.ShaderProperty(_StencilComp, "通过条件");

        //m_MaterialEditor.ShaderProperty(_TestValue, "测试值");


        UpdateKeyword(material);
    }

    
    void Popup(MaterialProperty property, string label, string[] names, int indent = 0)
    {
        EditorGUI.showMixedValue = property.hasMixedValue;
        var mode = (int)property.floatValue;

        EditorGUI.BeginChangeCheck();
        EditorGUI.indentLevel += indent;
        mode = EditorGUILayout.Popup(label, mode, names);
        EditorGUI.indentLevel -= indent;

        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo(label);
            property.floatValue = (float) mode;
        }

        EditorGUI.showMixedValue = false;
    }
    
    void UpdateKeyword(Material material)
    {
        material.SetKeyword("_NORMALMAP", _NormalMetalSmoothMap.textureValue != null);
        material.SetKeyword("_EMISSIVE_AO_MAP", _EmissiveAOMap.textureValue != null);
        material.SetKeyword("_TERRAIN_BLEND_FUNC", _TerrainBlendToggle.floatValue != 0);
        material.SetKeyword("_OUTLINE", _OutlineToggle.floatValue != 0);
        material.SetKeyword("_DARKPART", _DarkPartToggle.floatValue != 0); 
        material.SetKeyword("_ADDCOLOR", _AddColorToggle.floatValue != 0);
        material.SetKeyword("_BUTGRADIENT", _ButGradientToggle.floatValue != 0);
        material.SetKeyword("_VERTEXAO_ON", _VertexAO.floatValue != 0);
    }

}