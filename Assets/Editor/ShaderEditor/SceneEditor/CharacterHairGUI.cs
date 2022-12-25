using UnityEditor;
using UnityEngine;
using BioumRP;

public class CharacterHairGUI : ShaderGUI
{
    private static class Styles
    {
        public static GUIContent baseMapText = new GUIContent("颜色贴图(RGB) 高光偏移(A)");
        public static GUIContent normalMapText = new GUIContent("法线(AG) 光滑(R) AO(B)");
    }

    MaterialProperty _BaseMap = null;
    MaterialProperty _BaseColor = null;
    MaterialProperty _PenumbraTintColor = null;
    
    MaterialProperty _NormalAOSmoothMap = null;
    MaterialProperty _NormalScale = null;
    
    MaterialProperty _SpecIntensity = null;
    MaterialProperty _SubSpecIntensity = null;
    MaterialProperty _Shift = null;
    MaterialProperty _SubShift = null;
    MaterialProperty _Smoothness = null;
    MaterialProperty _SubSmoothness = null;
    MaterialProperty _SwitchTangent = null;
    MaterialProperty _DoubleSpecular = null;
    MaterialProperty _SpecColor = null;
    MaterialProperty _HairLightingParam0 = null;
    MaterialProperty _HairLightingParam1 = null;
    
    MaterialProperty _FresnelStrength = null;
    MaterialProperty _F0Tint = null;
    MaterialProperty _F0Strength = null;
    MaterialProperty _AOStrength = null;
    MaterialProperty _IndirectParam = null;
    
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
        _BaseMap = FindProperty("_BaseMap", props);
        _BaseColor = FindProperty("_BaseColor", props);
        _PenumbraTintColor = FindProperty("_PenumbraTintColor", props);
        
        _SpecIntensity = FindProperty("_SpecIntensity", props);
        _SubSpecIntensity = FindProperty("_SubSpecIntensity", props);
        _Shift = FindProperty("_Shift", props);
        _SubShift = FindProperty("_SubShift", props);
        _Smoothness = FindProperty("_Smoothness", props);
        _SubSmoothness = FindProperty("_SubSmoothness", props);
        _SwitchTangent = FindProperty("_SwitchTangent", props);
        _DoubleSpecular = FindProperty("_DoubleSpecular", props);
        _SpecColor = FindProperty("_SpecColor", props);
        _HairLightingParam0 = FindProperty("_HairLightingParam0", props);
        _HairLightingParam1 = FindProperty("_HairLightingParam1", props);
        
        _NormalAOSmoothMap = FindProperty("_NormalAOSmoothMap", props);
        _NormalScale = FindProperty("_NormalScale", props);
        
        _AOStrength = FindProperty("_AOStrength", props);
        _FresnelStrength = FindProperty("_FresnelStrength", props);
        _F0Tint = FindProperty("_F0Tint", props);
        _F0Strength = FindProperty("_F0Strength", props);
        _IndirectParam = FindProperty("_IndirectParam", props);
        
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
        ShaderPropertiesGUI(material);

        //EditorGUILayout.Space();
        //m_MaterialEditor.RenderQueueField();
        //m_MaterialEditor.EnableInstancingField();
        //m_MaterialEditor.DoubleSidedGIField();
    }
    

    const int indent = 1;
    public void ShaderPropertiesGUI(Material material)
    {
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_UseGlobalLightingControl, "使用灯光脚本控制光照强度");
        m_MaterialEditor.ShaderProperty(_LightIntensity, "灯光强度");
        m_MaterialEditor.ShaderProperty(_SmoothDiff, "明暗交界线硬度");
        m_MaterialEditor.ShaderProperty(_PenumbraTintColor, "半影色调");
        m_MaterialEditor.ShaderProperty(_SwitchTangent, "高光方向切换");

        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.baseMapText, _BaseMap, _BaseColor);
        
        Color baseColor = _BaseColor.colorValue;
        baseColor.a = _UseGlobalLightingControl.floatValue;
        _BaseColor.colorValue = baseColor;
        
        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, _NormalAOSmoothMap);
        if (_NormalAOSmoothMap.textureValue != null)
        {
            m_MaterialEditor.ShaderProperty(_AOStrength, "AO强度", indent);
            m_MaterialEditor.ShaderProperty(_NormalScale, "法线强度", indent);
        }
        _LightControlParam.vectorValue = new Vector4(
            _LightIntensity.floatValue, _SmoothDiff.floatValue, _NormalScale.floatValue);
        

        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_FresnelStrength, "菲涅尔强度");
        m_MaterialEditor.ShaderProperty(_F0Strength, "非金属反射强度");
        m_MaterialEditor.ShaderProperty(_F0Tint, "非金属反射着色");
        _IndirectParam.vectorValue = new Vector4(
            _AOStrength.floatValue, _FresnelStrength.floatValue, _F0Tint.floatValue, _F0Strength.floatValue);

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("第一层高光");
        EditorGUI.indentLevel += indent;
        m_MaterialEditor.ShaderProperty(_SpecIntensity, "高光强度");
        m_MaterialEditor.ShaderProperty(_Smoothness, "光滑度");
        m_MaterialEditor.ShaderProperty(_Shift, "高光偏移");
        m_MaterialEditor.ShaderProperty(_DoubleSpecular, "双层高光");
        EditorGUI.indentLevel -= indent;
        
        EditorGUILayout.LabelField("第二层高光");
        EditorGUI.indentLevel += indent;
        m_MaterialEditor.ShaderProperty(_SpecColor, "高光颜色");
        m_MaterialEditor.ShaderProperty(_SubSpecIntensity, "高光强度");
        m_MaterialEditor.ShaderProperty(_SubSmoothness, "光滑度");
        m_MaterialEditor.ShaderProperty(_SubShift, "高光偏移");
        EditorGUI.indentLevel -= indent;
        
        _HairLightingParam0.vectorValue = new Vector4(
            _SpecIntensity.floatValue, _Shift.floatValue, _Smoothness.floatValue, _SwitchTangent.floatValue);
        _HairLightingParam1.vectorValue = new Vector4(
            _SubSpecIntensity.floatValue, _SubShift.floatValue, _SubSmoothness.floatValue, _DoubleSpecular.floatValue);
        
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
    
    void UpdateKeyword(Material material)
    {
        material.SetKeyword("_NORMALMAP", _NormalAOSmoothMap.textureValue != null);
        material.SetKeyword("_SSS", _SSSToggle.floatValue != 0);
        material.SetKeyword("_RIM", _RimToggle.floatValue != 0);
    }
}