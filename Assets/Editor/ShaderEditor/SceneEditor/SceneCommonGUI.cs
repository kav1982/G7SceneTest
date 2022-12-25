using UnityEditor;
using UnityEngine;
using BioumRP;

public class SceneCommonGUI : ShaderGUI
{
    public enum BlendMode
    {
        Opaque,
        Cutout,
        Transparent,
        PreMultiply,
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
        public static readonly string[] blendNames = { "不透明", "透贴", "半透明", "预乘Alpha半透明(适合做玻璃)" };
        public static readonly string[] cullNames = { "正面显示", "双面显示" };
        public static GUIContent baseMapText = new GUIContent("颜色贴图");
        public static GUIContent normalMapText = new GUIContent("法线(AG) 光滑(R) 金属(B)");
        public static GUIContent snowNormalMapText = new GUIContent("法线(AG) 光滑(R) ");
        public static GUIContent emissiveAOMapText = new GUIContent("自发光(RGB) AO(A)");
    }

    MaterialProperty _BlendMode = null;
    MaterialProperty _CullMode = null;

    MaterialProperty _BaseMap = null;
    MaterialProperty _BaseColor = null;
    MaterialProperty _PenumbraTintColor = null;
    MaterialProperty _SpecularColor = null;
    
    MaterialProperty _NormalMetalSmoothMap = null;
    MaterialProperty _NormalScale = null;
    MaterialProperty _Smoothness = null;
    MaterialProperty _Metallic = null;
    MaterialProperty _NormalMatelSmoothParam = null;
    
    MaterialProperty _EmissiveColor = null;
    MaterialProperty _EmissiveBake = null;
    MaterialProperty _EmissiveBakeBoost = null;
    MaterialProperty _EmissiveAOMap = null;
    MaterialProperty _EmissiveAOMapUseUV2 = null;
    
    MaterialProperty _FresnelStrength = null;
    MaterialProperty _F0Tint = null;
    MaterialProperty _F0Strength = null;
    MaterialProperty _AOStrength = null;
    MaterialProperty _IndirectParam = null;
    
    MaterialProperty _Transparent = null;
    MaterialProperty _Cutoff = null;
    MaterialProperty _TransparentZWrite = null;
    MaterialProperty _TransparentShadowCaster = null;
    MaterialProperty _TransparentParam = null;
    
    MaterialProperty _SSSToggle = null;
    MaterialProperty _SSSColor = null;
    
    MaterialProperty _RimToggle = null;
    MaterialProperty _RimColorFront = null;
    MaterialProperty _RimColorBack = null;
    MaterialProperty _RimSmooth = null;
    MaterialProperty _RimOffsetX = null;
    MaterialProperty _RimOffsetY = null;
    MaterialProperty _RimParam = null;
    
    MaterialProperty _WindToggle = null;
    MaterialProperty _WindScale = null;
    MaterialProperty _WindSpeed = null;
    MaterialProperty _WindDirection = null;
    MaterialProperty _WindIntensity = null;
    MaterialProperty _WindParam = null;
    
    MaterialProperty _SnowToggle = null;
    MaterialProperty _SnowNormalMap = null;
    MaterialProperty _SnowNormalTilling = null;
    MaterialProperty _SnowNormalScale = null;
    MaterialProperty _SnowMaskRange = null;
    MaterialProperty _SnowMaskEdge = null;
    MaterialProperty _SnowParam = null;
    MaterialProperty _SnowColor = null;
    MaterialProperty _SnowSmoothness = null;
    
    MaterialEditor m_MaterialEditor;

    public void FindProperties(MaterialProperty[] props)
    {
        _BlendMode = FindProperty("_BlendMode", props);
        _CullMode = FindProperty("_CullMode", props);
        
        _BaseMap = FindProperty("_BaseMap", props);
        _BaseColor = FindProperty("_BaseColor", props);
        _PenumbraTintColor = FindProperty("_PenumbraTintColor", props);
        _SpecularColor = FindProperty("_SpecularColor", props);
        
        _NormalMetalSmoothMap = FindProperty("_NormalMetalSmoothMap", props);
        _NormalScale = FindProperty("_NormalScale", props);
        _Smoothness = FindProperty("_Smoothness", props);
        _Metallic = FindProperty("_Metallic", props);
        _NormalMatelSmoothParam = FindProperty("_NormalMatelSmoothParam", props);
        
        _EmissiveColor = FindProperty("_EmissiveColor", props);
        _EmissiveBake = FindProperty("_EmissiveBake", props);
        _EmissiveBakeBoost = FindProperty("_EmissiveBakeBoost", props);
        _EmissiveAOMap = FindProperty("_EmissiveAOMap", props);
        _EmissiveAOMapUseUV2 = FindProperty("_EmissiveAOMapUseUV2", props);
        
        _AOStrength = FindProperty("_AOStrength", props);
        _FresnelStrength = FindProperty("_FresnelStrength", props);
        _F0Tint = FindProperty("_F0Tint", props);
        _F0Strength = FindProperty("_F0Strength", props);
        _IndirectParam = FindProperty("_IndirectParam", props);
        
        _Transparent = FindProperty("_Transparent", props);
        _Cutoff = FindProperty("_Cutoff", props);
        _TransparentZWrite = FindProperty("_TransparentZWrite", props);
        _TransparentShadowCaster = FindProperty("_TransparentShadowCaster", props);
        _TransparentParam = FindProperty("_TransparentParam", props);
        
        _SSSToggle = FindProperty("_SSSToggle", props);
        _SSSColor = FindProperty("_SSSColor", props);
        
        _RimToggle = FindProperty("_RimToggle", props);
        _RimColorFront = FindProperty("_RimColorFront", props);
        _RimColorBack = FindProperty("_RimColorBack", props);
        _RimSmooth = FindProperty("_RimSmooth", props);
        _RimOffsetX = FindProperty("_RimOffsetX", props);
        _RimOffsetY = FindProperty("_RimOffsetY", props);
        _RimParam = FindProperty("_RimParam", props);
        
        _WindToggle = FindProperty("_WindToggle", props);
        _WindScale = FindProperty("_WindScale", props);
        _WindSpeed = FindProperty("_WindSpeed", props);
        _WindDirection = FindProperty("_WindDirection", props);
        _WindIntensity = FindProperty("_WindIntensity", props);
        _WindParam = FindProperty("_WindParam", props);
        
        _SnowToggle = FindProperty("_SnowToggle", props);
        _SnowNormalMap = FindProperty("_SnowNormalMap", props);
        _SnowNormalTilling = FindProperty("_SnowNormalTilling", props);
        _SnowNormalScale = FindProperty("_SnowNormalScale", props);
        _SnowMaskRange = FindProperty("_SnowMaskRange", props);
        _SnowMaskEdge = FindProperty("_SnowMaskEdge", props);
        _SnowParam = FindProperty("_SnowParam", props);
        _SnowColor = FindProperty("_SnowColor", props);
        _SnowSmoothness = FindProperty("_SnowSmoothness", props);
    }

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

    public void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "Opaque");
                material.SetKeyword("_ALPHATEST_ON", false);
                material.SetKeyword("_ALPHAPREMULTIPLY_ON", false);
                material.SetInt("_ZWrite", 1);
                material.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int) UnityEngine.Rendering.BlendMode.Zero);
                material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.Geometry;
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetKeyword("_ALPHATEST_ON", true);
                material.SetKeyword("_ALPHAPREMULTIPLY_ON", false);
                material.SetInt("_ZWrite", 1);
                material.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int) UnityEngine.Rendering.BlendMode.Zero);
                material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetKeyword("_ALPHATEST_ON", false);
                material.SetKeyword("_ALPHAPREMULTIPLY_ON", false);
                material.SetInt("_ZWrite", (int) _TransparentZWrite.floatValue);
                material.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.PreMultiply:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetKeyword("_ALPHATEST_ON", false);
                material.SetKeyword("_ALPHAPREMULTIPLY_ON", true);
                material.SetInt("_ZWrite", (int) _TransparentZWrite.floatValue);
                material.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.Transparent;
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
        Popup(_BlendMode, Styles.renderingMode, Styles.blendNames);

        Color mainColor = _BaseColor.colorValue;
        switch ((BlendMode) _BlendMode.floatValue)
        {
            case BlendMode.Cutout:
                m_MaterialEditor.ShaderProperty(_Cutoff, "透贴强度", indent);
                mainColor.a = 1;
                break;
            case BlendMode.Opaque:
                mainColor.a = 1;
                break;
            default:
                m_MaterialEditor.ShaderProperty(_Transparent, "透明度", indent);
                m_MaterialEditor.ShaderProperty(_TransparentZWrite, "写入深度", indent);
                m_MaterialEditor.ShaderProperty(_TransparentShadowCaster, "半透明阴影", indent);
                mainColor.a = _Transparent.floatValue;
                break;
        }
        
        Popup(_CullMode, Styles.cullingMode, Styles.cullNames);
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_PenumbraTintColor, "半影色调");

        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.baseMapText, _BaseMap, _BaseColor);
        // 烘焙需要的颜色参数
        material.SetTexture("_MainTex", _BaseMap.textureValue);
        material.SetColor("_Color", mainColor);
        
        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, _NormalMetalSmoothMap);
        if (_NormalMetalSmoothMap.textureValue != null)
            m_MaterialEditor.ShaderProperty(_NormalScale, "法线强度", indent);
        
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
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_SpecularColor, "高光颜色");
        m_MaterialEditor.ShaderProperty(_Metallic, "金属度");
        m_MaterialEditor.ShaderProperty(_Smoothness, "光滑度");
        _NormalMatelSmoothParam.vectorValue = new Vector4(
            _NormalScale.floatValue, _Metallic.floatValue, _Smoothness.floatValue, _EmissiveAOMapUseUV2.floatValue);
        
        
        m_MaterialEditor.ShaderProperty(_FresnelStrength, "菲涅尔强度");
        m_MaterialEditor.ShaderProperty(_F0Strength, "非金属反射强度");
        m_MaterialEditor.ShaderProperty(_F0Tint, "非金属反射着色");
        _IndirectParam.vectorValue = new Vector4(
            _AOStrength.floatValue, _FresnelStrength.floatValue, _F0Tint.floatValue, _F0Strength.floatValue);

        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_SSSToggle, "SSS");
        if (_SSSToggle.floatValue != 0)
        {
            m_MaterialEditor.ShaderProperty(_SSSColor, "SSS颜色", indent);
        }
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_RimToggle, "边缘光");
        if (_RimToggle.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_RimColorFront, "亮面颜色");
            m_MaterialEditor.ShaderProperty(_RimColorBack, "暗面颜色");
            m_MaterialEditor.ShaderProperty(_RimSmooth, "边缘硬度");
            m_MaterialEditor.ShaderProperty(_RimOffsetX, "亮部偏移");
            m_MaterialEditor.ShaderProperty(_RimOffsetY, "暗部偏移");
            _RimParam.vectorValue = new Vector4(
                _RimSmooth.floatValue, 1, _RimOffsetX.floatValue, _RimOffsetY.floatValue);
            EditorGUI.indentLevel--;
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
        
        _TransparentParam.vectorValue = new Vector4(_Transparent.floatValue, _Cutoff.floatValue, _WindToggle.floatValue);

        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_SnowToggle, "积雪");
        if(_SnowToggle.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.TexturePropertySingleLine(Styles.snowNormalMapText, _SnowNormalMap);
            m_MaterialEditor.ShaderProperty(_SnowNormalTilling, "贴图平铺");
            m_MaterialEditor.ShaderProperty(_SnowNormalScale, "法线强度");
            m_MaterialEditor.ShaderProperty(_SnowColor, "颜色");
            m_MaterialEditor.ShaderProperty(_SnowMaskRange, "范围");
            m_MaterialEditor.ShaderProperty(_SnowMaskEdge, "边缘");
            m_MaterialEditor.ShaderProperty(_SnowSmoothness, "光滑度");
            Color snowColor = _SnowColor.colorValue;
            snowColor.a = _SnowSmoothness.floatValue;
            _SnowColor.colorValue = snowColor;
            _SnowParam.vectorValue = new Vector4(
                _SnowNormalTilling.floatValue, _SnowNormalScale.floatValue, _SnowMaskRange.floatValue, _SnowMaskEdge.floatValue);
            EditorGUI.indentLevel--;
        }
        
        
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
        
        material.SetKeyword("_SSS", _SSSToggle.floatValue != 0);
        material.SetKeyword("_RIM", _RimToggle.floatValue != 0);

        if ((BlendMode)_BlendMode.floatValue == BlendMode.Transparent ||
            (BlendMode)_BlendMode.floatValue == BlendMode.PreMultiply)
        {
            material.SetKeyword("_DITHER_CLIP", _TransparentShadowCaster.floatValue != 0);
        }
        else
        {
            material.SetKeyword("_DITHER_CLIP", false);
        }
        
        material.SetKeyword("_NORMALMAP_SNOW", _SnowNormalMap.textureValue != null);
        material.SetKeyword("_SNOW", _SnowToggle.floatValue != 0);
    }
}