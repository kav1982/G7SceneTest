using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class BlenderShuiMoEditor : ShaderGUI
{

    MaterialProperty _BaseMap;
    MaterialProperty _Hue;
    MaterialProperty _Saturation;
    MaterialProperty _HSVFac;
    MaterialProperty _ValueMul;
    MaterialProperty _ValueAdd;
    MaterialProperty _ZWrite;

    MaterialEditor m_MaterialEditor;

    private float f1, f2, pos1, pos2;

    public void FindProperties(MaterialProperty[] props)
    {

        _BaseMap = FindProperty("_BaseMap", props);

        _Hue = FindProperty("_Hue", props);
        _Saturation = FindProperty("_Saturation", props);
        _HSVFac = FindProperty("_HSVFac", props);

        _ValueMul = FindProperty("_ValueMul", props);
        _ValueAdd = FindProperty("_ValueAdd", props);

        _ZWrite = FindProperty("_ZWrite", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        FindProperties(props);
        ShaderPropertiesGUI(material);
    }

    public void ShaderPropertiesGUI(Material material)
    {
        m_MaterialEditor.TextureProperty(_BaseMap, "主贴图");


        EditorGUILayout.Space();

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("色相/饱和度/明度");
        EditorGUI.indentLevel++;
        m_MaterialEditor.ShaderProperty(_Hue, "色相");
        m_MaterialEditor.ShaderProperty(_Saturation, "饱和度");
        EditorGUILayout.BeginHorizontal();
        {
            EditorGUILayout.LabelField("颜色过渡", GUILayout.Width(100));
            GetRangeProperty(ref pos1, ref pos2, _ValueMul, _ValueAdd);
            EditorGUILayout.MinMaxSlider(ref pos1, ref pos2, 0, 1);
            SetRangeProperty(pos1, pos2, _ValueMul, _ValueAdd);
        }
        EditorGUILayout.EndHorizontal();
        m_MaterialEditor.ShaderProperty(_HSVFac, "系数");
        EditorGUI.indentLevel--;

        m_MaterialEditor.ShaderProperty(_ZWrite, "写深度");
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
