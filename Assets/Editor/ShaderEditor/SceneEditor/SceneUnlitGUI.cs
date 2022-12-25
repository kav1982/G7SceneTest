using UnityEditor;
using UnityEngine;
using BioumRP;

public class SceneUnlitGUI : ShaderGUI
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
        public static readonly string[] blendNames = { "不透明", "透贴", "半透明" };
        public static readonly string[] cullNames = { "正面显示", "双面显示" };
        public static GUIContent baseMapText = new GUIContent("颜色贴图");
        public static GUIContent emissiveMapText = new GUIContent("自发光(RGB)");
    }

    MaterialProperty _BlendMode = null;
    MaterialProperty _CullMode = null;

    MaterialProperty _BaseMap = null;
    MaterialProperty _BaseColor = null;
    
    MaterialProperty _EmissiveColor = null;
    MaterialProperty _EmissiveMap = null;
    MaterialProperty _EmissiveMapUseUV2 = null;
    
    MaterialProperty _Transparent = null;
    MaterialProperty _Cutoff = null;
    MaterialProperty _TransparentZWrite = null;
    MaterialProperty _TransparentShadowCaster = null;
    MaterialProperty _UnlitShaderParam = null;
    
    MaterialProperty _UseFog = null;
    MaterialProperty _FogIntensity = null;

    MaterialEditor m_MaterialEditor;

    public void FindProperties(MaterialProperty[] props)
    {
        _BlendMode = FindProperty("_BlendMode", props);
        _CullMode = FindProperty("_CullMode", props);
        
        _BaseMap = FindProperty("_BaseMap", props);
        _BaseColor = FindProperty("_BaseColor", props);
        
        _EmissiveMap = FindProperty("_EmissiveMap", props);
        _EmissiveColor = FindProperty("_EmissiveColor", props);
        _EmissiveMapUseUV2 = FindProperty("_EmissiveMapUseUV2", props);
        
        _Transparent = FindProperty("_Transparent", props);
        _Cutoff = FindProperty("_Cutoff", props);
        _TransparentZWrite = FindProperty("_TransparentZWrite", props);
        _TransparentShadowCaster = FindProperty("_TransparentShadowCaster", props);
        _UnlitShaderParam = FindProperty("_UnlitShaderParam", props);
        
        _UseFog = FindProperty("_UseFog", props);
        _FogIntensity = FindProperty("_FogIntensity", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        material.doubleSidedGI = true;

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
                material.SetInt("_ZWrite", 1);
                material.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int) UnityEngine.Rendering.BlendMode.Zero);
                material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.Geometry;
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetKeyword("_ALPHATEST_ON", true);
                material.SetInt("_ZWrite", 1);
                material.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int) UnityEngine.Rendering.BlendMode.Zero);
                material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetKeyword("_ALPHATEST_ON", false);
                material.SetInt("_ZWrite", (int) _TransparentZWrite.floatValue);
                material.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
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
                material.SetKeyword("_DITHER_CLIP", false);
                break;
            case BlendMode.Transparent:
                m_MaterialEditor.ShaderProperty(_Transparent, "透明度", indent);
                m_MaterialEditor.ShaderProperty(_TransparentZWrite, "Z写入", indent);
                m_MaterialEditor.ShaderProperty(_TransparentShadowCaster, "半透明阴影", indent);
                material.SetKeyword("_DITHER_CLIP", _TransparentShadowCaster.floatValue != 0);
                break;
            case BlendMode.Opaque:
                material.SetKeyword("_DITHER_CLIP", false);
                break;
        }

        Popup(_CullMode, Styles.cullingMode, Styles.cullNames);
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_UseFog, "接受雾");
        if(_UseFog.floatValue != 0)
            m_MaterialEditor.ShaderProperty(_FogIntensity, "雾强度", indent);

        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.baseMapText, _BaseMap, _BaseColor);
        
        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.emissiveMapText, _EmissiveMap);
        if (_EmissiveMap.textureValue != null)
        {
            m_MaterialEditor.ShaderProperty(_EmissiveMapUseUV2, "使用2U", indent);
        }
        m_MaterialEditor.ShaderProperty(_EmissiveColor, "自发光", indent);
        
        _UnlitShaderParam.vectorValue = new Vector4(
            _Transparent.floatValue, _Cutoff.floatValue, _EmissiveMapUseUV2.floatValue, _FogIntensity.floatValue);
        
        
        material.SetKeyword("_EMISSIVE_MAP", _EmissiveMap.textureValue != null);
        material.SetKeyword("_USE_FOG", _UseFog.floatValue != 0);
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

}