using UnityEditor;
using UnityEngine;
using BioumRP;

public class CharacterCommonPBRGUI : ShaderGUI
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
        public static GUIContent emissiveAOMapText = new GUIContent("自发光(RGB) AO(A)");
        public static GUIContent dissolveMapText = new GUIContent("溶解贴图");
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
    
    MaterialProperty _LightIntensity = null;
    MaterialProperty _SmoothDiff = null;
    MaterialProperty _LightControlParam = null;
    
    MaterialProperty _DissolveEdgeColor = null;
    MaterialProperty _DissolveScale = null;
    MaterialProperty _DissolveFactor = null;
    MaterialProperty _DissolveEdge = null;
    MaterialProperty _DissolveAni = null;
    MaterialProperty _DissolveParam = null;
    
    MaterialProperty _OutlineColor = null;
    MaterialProperty _OutlineThickness = null;
    
    MaterialProperty _UseGlobalLightingControl = null;
    
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
        
        _LightIntensity = FindProperty("_LightIntensity", props);
        _SmoothDiff = FindProperty("_SmoothDiff", props);
        _LightControlParam = FindProperty("_LightControlParam", props);
        
        _DissolveEdgeColor = FindProperty("_DissolveEdgeColor", props);
        _DissolveScale = FindProperty("_DissolveScale", props);
        _DissolveFactor = FindProperty("_DissolveFactor", props);
        _DissolveEdge = FindProperty("_DissolveEdge", props);
        _DissolveAni = FindProperty("_DissolveAni", props);
        _DissolveParam = FindProperty("_DissolveParam", props);
        
        _OutlineThickness = FindProperty("_OutlineThickness", props);
        _OutlineColor = FindProperty("_OutlineColor", props);
        
        _UseGlobalLightingControl = FindProperty("_UseGlobalLightingControl", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;
        
        FindProperties(props);
        RenderMode(material);
        ShaderPropertiesGUI(material);

        //EditorGUILayout.Space();
        //m_MaterialEditor.RenderQueueField();
        //m_MaterialEditor.EnableInstancingField();
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
        
        switch ((BlendMode) _BlendMode.floatValue)
        {
            case BlendMode.Cutout:
                m_MaterialEditor.ShaderProperty(_Cutoff, "透贴强度", indent);
                break;
            case BlendMode.Opaque:
                break;
            default:
                m_MaterialEditor.ShaderProperty(_Transparent, "透明度", indent);
                m_MaterialEditor.ShaderProperty(_TransparentZWrite, "写入深度", indent);
                m_MaterialEditor.ShaderProperty(_TransparentShadowCaster, "半透明阴影", indent);
                break;
        }
        
        _TransparentParam.vectorValue = new Vector4(_Transparent.floatValue, _Cutoff.floatValue);

        Popup(_CullMode, Styles.cullingMode, Styles.cullNames);
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_UseGlobalLightingControl, "使用灯光脚本控制光照强度");
        m_MaterialEditor.ShaderProperty(_LightIntensity, "灯光强度");
        m_MaterialEditor.ShaderProperty(_SmoothDiff, "明暗交界线硬度");
        _LightControlParam.vectorValue = new Vector4(_LightIntensity.floatValue, _SmoothDiff.floatValue);
        m_MaterialEditor.ShaderProperty(_PenumbraTintColor, "半影色调");

        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.baseMapText, _BaseMap, _BaseColor);

        Color baseColor = _BaseColor.colorValue;
        baseColor.a = _UseGlobalLightingControl.floatValue;
        _BaseColor.colorValue = baseColor;
        
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
        Color rimColor = _RimColorFront.colorValue;
        rimColor.a = _RimToggle.floatValue;
        _RimColorFront.colorValue = rimColor;
        
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("溶解");
        EditorGUI.indentLevel++;
        m_MaterialEditor.ShaderProperty(_DissolveScale, "密度");
        m_MaterialEditor.ShaderProperty(_DissolveFactor, "强度");
        m_MaterialEditor.ShaderProperty(_DissolveAni, "速度");
        m_MaterialEditor.ShaderProperty(_DissolveEdge, "边缘宽度");
        m_MaterialEditor.ShaderProperty(_DissolveEdgeColor, "边缘颜色");
        _DissolveParam.vectorValue = new Vector4(
            _DissolveFactor.floatValue, _DissolveEdge.floatValue,
            _DissolveAni.floatValue, _DissolveScale.floatValue);
        EditorGUI.indentLevel--;
        
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("描边(后处理描边关闭时启用)");
        EditorGUI.indentLevel++;
        m_MaterialEditor.ShaderProperty(_OutlineThickness, "粗细");
        m_MaterialEditor.ShaderProperty(_OutlineColor, "颜色");
        Color outlineColor = _OutlineColor.colorValue;
        outlineColor.a = _OutlineThickness.floatValue;
        _OutlineColor.colorValue = outlineColor;
        EditorGUI.indentLevel--;

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
    }
}