using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class BlenderSkinEditor : ShaderGUI
{
    public enum BlendMode
    {
        Opaque,
        Cutout,
        Transparent,
    }

    MaterialProperty _BaseMap;
    MaterialProperty _BaseColor;
    MaterialProperty _TEXTURE_COLOR_MAPING;
    MaterialProperty _GammaTex;
    MaterialProperty _Bright;
    MaterialProperty _Contrast;
    MaterialProperty _Hue;
    MaterialProperty _Saturation;
    MaterialProperty _Value;
    MaterialProperty _HSVFac;

    MaterialProperty _SET_LIGHT_DIR;
    MaterialProperty _LightDirH;
    MaterialProperty _LightDirV;
    MaterialProperty _LightDir;
    MaterialProperty _LightInvert;
    MaterialProperty _LightColor1;
    MaterialProperty _LightColor2;
    MaterialProperty _LightDirMul;
    MaterialProperty _LightDirAdd;

    MaterialProperty _OutLineMul;
    MaterialProperty _OutLineAdd;

    MaterialProperty _Gamma;

    MaterialProperty _Color1;
    MaterialProperty _Color2;
    MaterialProperty _ColorMul;
    MaterialProperty _ColorAdd;
    MaterialProperty _ColorLerp;
    MaterialProperty _LightOffset;

    MaterialProperty _BlendMode;
    MaterialProperty _Cutoff;

    MaterialEditor m_MaterialEditor;

    private float f1, f2, pos1, pos2;

    private static class Styles
    {
        public static GUIContent baseMapText = new GUIContent("颜色贴图");
        public static string renderingMode = "混合模式";
        public static readonly string[] blendNames = { "不透明", "透贴", "半透明" };
    }

    public void FindProperties(MaterialProperty[] props)
    {
        _BlendMode = FindProperty("_BlendMode", props);
        _Cutoff = FindProperty("_Cutoff", props);
        _BaseMap = FindProperty("_BaseMap", props);
        _BaseColor = FindProperty("_BaseColor", props);

        _TEXTURE_COLOR_MAPING = FindProperty("_TEXTURE_COLOR_MAPING", props);
        _GammaTex = FindProperty("_GammaTex", props);
        _Bright = FindProperty("_Bright", props);
        _Contrast = FindProperty("_Contrast", props);
        _Hue = FindProperty("_Hue", props);
        _Saturation = FindProperty("_Saturation", props);
        _Value = FindProperty("_Value", props);
        _HSVFac = FindProperty("_HSVFac", props);

        _SET_LIGHT_DIR = FindProperty("_SET_LIGHT_DIR", props);
        _LightDirH = FindProperty("_LightDirH", props);
        _LightDirV = FindProperty("_LightDirV", props);
        _LightDir = FindProperty("_LightDir", props);
        _LightInvert = FindProperty("_LightInvert", props);
        _LightColor1 = FindProperty("_LightColor1", props);
        _LightColor2 = FindProperty("_LightColor2", props);
        _LightDirMul = FindProperty("_LightDirMul", props);
        _LightDirAdd = FindProperty("_LightDirAdd", props);

        _OutLineMul = FindProperty("_OutLineMul", props);
        _OutLineAdd = FindProperty("_OutLineAdd", props);

        _Gamma = FindProperty("_Gamma", props);

        _Color1 = FindProperty("_Color1", props);
        _Color2 = FindProperty("_Color2", props);
        _ColorMul = FindProperty("_ColorMul", props);
        _ColorAdd = FindProperty("_ColorAdd", props);
        _ColorLerp = FindProperty("_ColorLerp", props);

        _LightOffset = FindProperty("_LightOffset", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        FindProperties(props);
        SetupMaterialWithBlendMode(material, (BlendMode)_BlendMode.floatValue);
        ShaderPropertiesGUI(material);
    }

    public void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "Opaque");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                material.SetKeyword("_ALPHATEST_ON", false);
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                material.SetKeyword("_ALPHATEST_ON", true);
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                material.SetKeyword("_ALPHATEST_ON", false);
                break;
        }
    }

    public void ShaderPropertiesGUI(Material material)
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.baseMapText, _BaseMap, _BaseColor);

        Popup(_BlendMode, Styles.renderingMode, Styles.blendNames);
        switch ((BlendMode)_BlendMode.floatValue)
        {
            case BlendMode.Cutout:
                m_MaterialEditor.ShaderProperty(_Cutoff, "透贴强度");
                break;
        }
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_TEXTURE_COLOR_MAPING, "调整贴图颜色");
        if (_TEXTURE_COLOR_MAPING.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            {
                m_MaterialEditor.ShaderProperty(_GammaTex, "Gamma");

                EditorGUILayout.Space();
                EditorGUILayout.LabelField("亮度/对比度");
                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(_Bright, "亮度");
                m_MaterialEditor.ShaderProperty(_Contrast, "对比度");
                EditorGUI.indentLevel--;

                EditorGUILayout.Space();
                EditorGUILayout.LabelField("色相/饱和度/明度");
                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(_Hue, "色相");
                m_MaterialEditor.ShaderProperty(_Saturation, "饱和度");
                m_MaterialEditor.ShaderProperty(_Value, "明度");
                m_MaterialEditor.ShaderProperty(_HSVFac, "系数");
                EditorGUI.indentLevel--;
                EditorGUILayout.Space();
                if (GUILayout.Button("应用修改到贴图"))
                {
                    if (_BaseMap.textureValue != null)
                        if (EditorFileTools.ChangeTextureColor(AssetDatabase.GetAssetPath(_BaseMap.textureValue), _GammaTex.floatValue, _Bright.floatValue, _Contrast.floatValue, _Hue.floatValue, _Saturation.floatValue, _Value.floatValue, _HSVFac.floatValue))
                        {
                            _TEXTURE_COLOR_MAPING.floatValue = 0;
                            material.DisableKeyword("_TEXTURE_COLOR_MAPING");
                        }

                }
            }
            EditorGUI.indentLevel--;
        }

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("光照");
        EditorGUI.indentLevel++;
        {
            m_MaterialEditor.ShaderProperty(_SET_LIGHT_DIR, "指定光源角度");
            if(_SET_LIGHT_DIR.floatValue != 0)
            {
                EditorGUI.indentLevel++;
                {
                    m_MaterialEditor.ShaderProperty(_LightDirH, "水平角度");
                    m_MaterialEditor.ShaderProperty(_LightDirV, "竖直角度");
                    _LightDir.vectorValue = Quaternion.AngleAxis(-_LightDirH.floatValue * 180f, Vector3.up) * Quaternion.AngleAxis(_LightDirV.floatValue * 180f, Vector3.right) * Vector3.back;
                }
                EditorGUI.indentLevel--;
            }
            m_MaterialEditor.ShaderProperty(_LightInvert, "光线角度调整");
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("光照颜色", GUILayout.Width(100));
                _LightColor1.colorValue = EditorGUILayout.ColorField(_LightColor1.colorValue, GUILayout.Width(80));
                EditorGUILayout.Space();
                _LightColor2.colorValue = EditorGUILayout.ColorField(_LightColor2.colorValue, GUILayout.Width(80));
            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("颜色位置", GUILayout.Width(100));
                GetRangeProperty(ref pos1, ref pos2, _LightDirMul, _LightDirAdd);
                EditorGUILayout.MinMaxSlider(ref pos1, ref pos2, 0, 1);
                SetRangeProperty(pos1, pos2, _LightDirMul, _LightDirAdd);
            }
            EditorGUILayout.EndHorizontal();
        }
        EditorGUI.indentLevel--;

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("描边");
        EditorGUI.indentLevel++;
        {
            GetRangeProperty(ref pos1, ref pos2, _OutLineMul, _OutLineAdd);
            EditorGUILayout.MinMaxSlider("描边位置", ref pos1, ref pos2, 0, 1);
            SetRangeProperty(pos1, pos2, _OutLineMul, _OutLineAdd);
        }
        EditorGUI.indentLevel--;

        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_Gamma, "Gamma");

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("颜色");
        EditorGUI.indentLevel++;
        {
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("叠加颜色", GUILayout.Width(100));
                _Color1.colorValue = EditorGUILayout.ColorField(_Color1.colorValue, GUILayout.Width(80));
                EditorGUILayout.Space();
                _Color2.colorValue = EditorGUILayout.ColorField(_Color2.colorValue, GUILayout.Width(80));
            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("颜色位置", GUILayout.Width(100));
                GetRangeProperty(ref pos1, ref pos2, _ColorMul, _ColorAdd);
                EditorGUILayout.MinMaxSlider(ref pos1, ref pos2, 0, 1);
                SetRangeProperty(pos1, pos2, _ColorMul, _ColorAdd);
            }
            EditorGUILayout.EndHorizontal();
            m_MaterialEditor.ShaderProperty(_ColorLerp, "系数");
        }
        EditorGUI.indentLevel--;

        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_LightOffset, "减弱光照");
    }

    public void SetRangeProperty(float v1, float v2, MaterialProperty p1, MaterialProperty p2)
    {
        f1 = Mathf.Min(v1, v2);
        f2 = Mathf.Max(v1, v2);
        if (Mathf.Approximately(f1, f2)) f2 += 0.01f;
        v1 = 1.0f / (f2 - f1);
        v2 = -v1 * f1;
        p1.floatValue = v1;
        p2.floatValue = v2;
    }

    public void GetRangeProperty(ref float v1, ref float v2, MaterialProperty p1, MaterialProperty p2)
    {
        f2 = -p2.floatValue / p1.floatValue;
        f1 = f2 + 1.0f / p1.floatValue;
        v1 = Mathf.Min(f1, f2);
        v2 = Mathf.Max(f1, f2);
        if (Mathf.Approximately(v1, v2)) v2 += 0.01f;
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
            property.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }
}
