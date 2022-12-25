using UnityEditor;
using UnityEngine;

public class ShadowCasterOnlyGUI : ShaderGUI
{
    public enum BlendMode
    {
        Opaque,
        Cutout,
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
        public static readonly string[] blendNames = { "不透明", "透贴"};
        public static readonly string[] cullNames = { "正面显示", "双面显示" };
    }
    MaterialProperty _BlendMode = null;
    MaterialProperty _CullMode = null;
    MaterialProperty _BaseMap = null;
    MaterialProperty _AlphaClip = null;
    
    MaterialEditor m_MaterialEditor;

    public void FindProperties(MaterialProperty[] props)
    {
        _BlendMode = FindProperty("_BlendMode", props);
        _CullMode = FindProperty("_CullMode", props);
        
        _BaseMap = FindProperty("_BaseMap", props);
        _AlphaClip = FindProperty("_AlphaClip", props);
    }
    void RenderMode(Material material)
    {
        SetupMaterialWithBlendMode(material, (BlendMode) _BlendMode.floatValue);
        SetupMaterialWithCullMode(material, (CullMode) _CullMode.floatValue);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;
        FindProperties(props);
        RenderMode(material);
        ShaderPropertiesGUI(material);
    }

    public void ShaderPropertiesGUI(Material material)
    {
        Popup(_BlendMode, Styles.renderingMode, Styles.blendNames);
        Popup(_CullMode, Styles.cullingMode, Styles.cullNames);
        
        m_MaterialEditor.ShaderProperty(_BaseMap, "主帖图");
        m_MaterialEditor.ShaderProperty(_AlphaClip, "透明度裁切");
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
    public void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "Opaque");
                material.SetKeyword("_ALPHATEST_ON", false);
                material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.Geometry;
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetKeyword("_ALPHATEST_ON", true);
                material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
        }
    }
}
