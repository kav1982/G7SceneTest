using UnityEditor;
using UnityEngine;
using BioumRP;

public class SceneTerrainGUI : ShaderGUI
{
    public enum TextureCount
    {
        _2 = 2,
        _3 = 3,
        _4 = 4,
    }

    private static class Styles
    {
        public static string textureCount = "贴图数量";
        public static readonly string[] textureCountNames = { "两张", "三张", "四张" };
        public static GUIContent baseMapText = new GUIContent("颜色(RGB) 高度(A)");
        public static GUIContent maskMapText = new GUIContent("法线(AG) 光滑(R) AO(B)");
    }

    
    MaterialProperty _PenumbraTintColor = null;
    
    MaterialProperty _Color0 = null;
    MaterialProperty _Color1 = null;
    MaterialProperty _Color2 = null;
    MaterialProperty _Color3 = null;
    
    MaterialProperty _Splat0 = null;
    MaterialProperty _Splat1 = null;
    MaterialProperty _Splat2 = null;
    MaterialProperty _Splat3 = null;
    
    MaterialProperty _SplatMask0 = null;
    MaterialProperty _SplatMask1 = null;
    MaterialProperty _SplatMask2 = null;
    MaterialProperty _SplatMask3 = null;
    
    MaterialProperty _Tilling0 = null;
    MaterialProperty _Tilling1 = null;
    MaterialProperty _Tilling2 = null;
    MaterialProperty _Tilling3 = null;
    MaterialProperty _Tilling = null;
    
    MaterialProperty _NormalScale0 = null;
    MaterialProperty _NormalScale1 = null;
    MaterialProperty _NormalScale2 = null;
    MaterialProperty _NormalScale3 = null;
    MaterialProperty _NormalScale = null;
    
    MaterialProperty _Smoothness0 = null;
    MaterialProperty _Smoothness1 = null;
    MaterialProperty _Smoothness2 = null;
    MaterialProperty _Smoothness3 = null;
    MaterialProperty _Smoothness = null;
    
    MaterialProperty _AOStrength0 = null;
    MaterialProperty _AOStrength1 = null;
    MaterialProperty _AOStrength2 = null;
    MaterialProperty _AOStrength3 = null;
    MaterialProperty _AOStrength = null;
    
    MaterialProperty _FresnelStrength0 = null;
    MaterialProperty _FresnelStrength1 = null;
    MaterialProperty _FresnelStrength2 = null;
    MaterialProperty _FresnelStrength3 = null;
    MaterialProperty _FresnelStrength = null;
    
    MaterialProperty _F0Tint0 = null;
    MaterialProperty _F0Tint1 = null;
    MaterialProperty _F0Tint2 = null;
    MaterialProperty _F0Tint3 = null;
    MaterialProperty _F0Tint = null;
    
    MaterialProperty _F0Strength0 = null;
    MaterialProperty _F0Strength1 = null;
    MaterialProperty _F0Strength2 = null;
    MaterialProperty _F0Strength3 = null;
    MaterialProperty _F0Strength = null;
    
    MaterialProperty _HeightBlendWeight = null;
    MaterialProperty _TexCount = null;

    //MaterialProperty _HeightFogDensity = null;
    //MaterialProperty _FogInfo = null;
    //MaterialProperty _FogColor = null;

    MaterialEditor m_MaterialEditor;

    public void FindProperties(MaterialProperty[] props)
    {
        _PenumbraTintColor = FindProperty("_PenumbraTintColor", props);
        
        _Color0 = FindProperty("_Color0", props);
        _Color1 = FindProperty("_Color1", props);
        _Color2 = FindProperty("_Color2", props);
        _Color3 = FindProperty("_Color3", props);
        
        _Splat0 = FindProperty("_Splat0", props);
        _Splat1 = FindProperty("_Splat1", props);
        _Splat2 = FindProperty("_Splat2", props);
        _Splat3 = FindProperty("_Splat3", props);
        
        _SplatMask0 = FindProperty("_SplatMask0", props);
        _SplatMask1 = FindProperty("_SplatMask1", props);
        _SplatMask2 = FindProperty("_SplatMask2", props);
        _SplatMask3 = FindProperty("_SplatMask3", props);
        
        _Tilling0 = FindProperty("_Tilling0", props);
        _Tilling1 = FindProperty("_Tilling1", props);
        _Tilling2 = FindProperty("_Tilling2", props);
        _Tilling3 = FindProperty("_Tilling3", props);
        _Tilling = FindProperty("_Tilling", props);
        
        _NormalScale0 = FindProperty("_NormalScale0", props);
        _NormalScale1 = FindProperty("_NormalScale1", props);
        _NormalScale2 = FindProperty("_NormalScale2", props);
        _NormalScale3 = FindProperty("_NormalScale3", props);
        _NormalScale = FindProperty("_NormalScale", props);
        
        _Smoothness0 = FindProperty("_Smoothness0", props);
        _Smoothness1 = FindProperty("_Smoothness1", props);
        _Smoothness2 = FindProperty("_Smoothness2", props);
        _Smoothness3 = FindProperty("_Smoothness3", props);
        _Smoothness = FindProperty("_Smoothness", props);
        
        _AOStrength0 = FindProperty("_AOStrength0", props);
        _AOStrength1 = FindProperty("_AOStrength1", props);
        _AOStrength2 = FindProperty("_AOStrength2", props);
        _AOStrength3 = FindProperty("_AOStrength3", props);
        _AOStrength = FindProperty("_AOStrength", props);
        
        _FresnelStrength0 = FindProperty("_FresnelStrength0", props);
        _FresnelStrength1 = FindProperty("_FresnelStrength1", props);
        _FresnelStrength2 = FindProperty("_FresnelStrength2", props);
        _FresnelStrength3 = FindProperty("_FresnelStrength3", props);
        _FresnelStrength = FindProperty("_FresnelStrength", props);
        
        _F0Tint0 = FindProperty("_F0Tint0", props);
        _F0Tint1 = FindProperty("_F0Tint1", props);
        _F0Tint2 = FindProperty("_F0Tint2", props);
        _F0Tint3 = FindProperty("_F0Tint3", props);
        _F0Tint = FindProperty("_F0Tint", props);
        
        _F0Strength0 = FindProperty("_F0Strength0", props);
        _F0Strength1 = FindProperty("_F0Strength1", props);
        _F0Strength2 = FindProperty("_F0Strength2", props);
        _F0Strength3 = FindProperty("_F0Strength3", props);
        _F0Strength = FindProperty("_F0Strength", props);
        
        _HeightBlendWeight = FindProperty("_HeightBlendWeight", props);
        _TexCount = FindProperty("_TexCount", props);

        //_HeightFogDensity = FindProperty("_HeightFogDensity", props);
        //_FogInfo = FindProperty("_FogInfo", props);
        //_FogColor = FindProperty("_FogColor", props);
    }
    
    private string m_HeaderStateKey = null;
    private const string k_KeyPrefix = "BioumRP:Material:UI_State:";
    private SavedBool m_Texture0Foldout;
    private SavedBool m_Texture1Foldout;
    private SavedBool m_Texture2Foldout;
    private SavedBool m_Texture3Foldout;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;
        
        m_HeaderStateKey = k_KeyPrefix + material.shader.name; // Create key string for editor prefs
        m_Texture0Foldout = new SavedBool($"{m_HeaderStateKey}.Texture0Foldout", true);
        m_Texture1Foldout = new SavedBool($"{m_HeaderStateKey}.Texture1Foldout", true);
        m_Texture2Foldout = new SavedBool($"{m_HeaderStateKey}.Texture2Foldout", true);
        m_Texture3Foldout = new SavedBool($"{m_HeaderStateKey}.Texture3Foldout", true);

        material.doubleSidedGI = true;

        FindProperties(props);
        ShaderPropertiesGUI(material);

        //EditorGUILayout.Space();
        //m_MaterialEditor.RenderQueueField();
        //m_MaterialEditor.EnableInstancingField();
        //m_MaterialEditor.DoubleSidedGIField();
    }

    const int indent = 1;
    private Color color0, color1, color2, color3;
    public void ShaderPropertiesGUI(Material material)
    {
        Popup(ref _TexCount, Styles.textureCount, Styles.textureCountNames);
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_PenumbraTintColor, "半影色调");
        m_MaterialEditor.ShaderProperty(_HeightBlendWeight, "高度混合");
        
        
        EditorGUILayout.Space();
        m_Texture0Foldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_Texture0Foldout.value, "贴图1");
        if (m_Texture0Foldout.value)
        {
            DrawTextureArea(_Splat0, _Color0, _Tilling0, _SplatMask0, _NormalScale0, _Smoothness0, 
                _AOStrength0, _FresnelStrength0, _F0Tint0, _F0Strength0);
        }
        EditorGUILayout.EndFoldoutHeaderGroup();
        
        
        EditorGUILayout.Space();
        m_Texture1Foldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_Texture1Foldout.value, "贴图2");
        if (m_Texture1Foldout.value)
        {
            DrawTextureArea(_Splat1, _Color1, _Tilling1, _SplatMask1, _NormalScale1, _Smoothness1, 
                _AOStrength1, _FresnelStrength1, _F0Tint1, _F0Strength1);
        }
        EditorGUILayout.EndFoldoutHeaderGroup();


        if ((int) _TexCount.floatValue > 2)
        {
            EditorGUILayout.Space();
            m_Texture2Foldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_Texture2Foldout.value, "贴图3");
            if (m_Texture2Foldout.value)
            {
                DrawTextureArea(_Splat2, _Color2, _Tilling2, _SplatMask2, _NormalScale2, _Smoothness2, 
                    _AOStrength2, _FresnelStrength2, _F0Tint2, _F0Strength2);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
        
        if ((int) _TexCount.floatValue > 3)
        {
            EditorGUILayout.Space();
            m_Texture3Foldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_Texture3Foldout.value, "贴图4");
            if (m_Texture3Foldout.value)
            {
                DrawTextureArea(_Splat3, _Color3, _Tilling3, _SplatMask3, _NormalScale3, _Smoothness3, 
                    _AOStrength3, _FresnelStrength3, _F0Tint3, _F0Strength3);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
 
        }
        
        _Tilling.vectorValue = new Vector4(
            _Tilling0.floatValue, _Tilling1.floatValue, _Tilling2.floatValue, _Tilling3.floatValue);
        _NormalScale.vectorValue = new Vector4(
            _NormalScale0.floatValue, _NormalScale1.floatValue, _NormalScale2.floatValue, _NormalScale3.floatValue);
        _Smoothness.vectorValue = new Vector4(
            _Smoothness0.floatValue, _Smoothness1.floatValue, _Smoothness2.floatValue, _Smoothness3.floatValue);
        _AOStrength.vectorValue = new Vector4(
            _AOStrength0.floatValue, _AOStrength1.floatValue, _AOStrength2.floatValue, _AOStrength3.floatValue);
        _FresnelStrength.vectorValue = new Vector4(
            _FresnelStrength0.floatValue, _FresnelStrength1.floatValue, _FresnelStrength2.floatValue, _FresnelStrength3.floatValue);
        _F0Tint.vectorValue = new Vector4(
            _F0Tint0.floatValue, _F0Tint1.floatValue, _F0Tint2.floatValue, _F0Tint3.floatValue);
        _F0Strength.vectorValue = new Vector4(
            _F0Strength0.floatValue, _F0Strength1.floatValue, _F0Strength2.floatValue, _F0Strength3.floatValue);

        color0 = _Color0.colorValue;
        color1 = _Color1.colorValue;
        color2 = _Color2.colorValue;
        color3 = _Color3.colorValue;

        color0.a = _PenumbraTintColor.colorValue.r;
        color1.a = _PenumbraTintColor.colorValue.g;
        color2.a = _PenumbraTintColor.colorValue.b;
        color3.a = _HeightBlendWeight.floatValue;
        
        _Color0.colorValue = color0;
        _Color1.colorValue = color1;
        _Color2.colorValue = color2;
        _Color3.colorValue = color3;

        EditorGUILayout.Space(5);

        //m_MaterialEditor.ShaderProperty(_HeightFogDensity, "高度雾强度");
        //m_MaterialEditor.ShaderProperty(_FogInfo, "FogInfo范围, x y为相机空间近 远, z w为世界空间高 低");
        //m_MaterialEditor.ShaderProperty(_FogColor, "FogColor");

        UpdateKeyword(material);
    }

    void DrawTextureArea(MaterialProperty splat, MaterialProperty baseColor, MaterialProperty tilling,
        MaterialProperty maskTexture, MaterialProperty normalScale, MaterialProperty smoothness, 
        MaterialProperty aoStrength, MaterialProperty fresnel, MaterialProperty F0Tint, MaterialProperty F0Strength)
    {
        EditorGUI.indentLevel += indent;
        m_MaterialEditor.TexturePropertySingleLine(Styles.baseMapText, splat, baseColor);
        m_MaterialEditor.TexturePropertySingleLine(Styles.maskMapText, maskTexture);
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(tilling, "平铺");
        m_MaterialEditor.ShaderProperty(normalScale, "法线强度");
        m_MaterialEditor.ShaderProperty(smoothness, "光滑度");
        m_MaterialEditor.ShaderProperty(aoStrength, "AO强度");
        m_MaterialEditor.ShaderProperty(fresnel, "菲涅尔强度");
        m_MaterialEditor.ShaderProperty(F0Tint, "反射着色");
        m_MaterialEditor.ShaderProperty(F0Strength, "反射强度");
        EditorGUI.indentLevel -= indent;
    }

    void UpdateKeyword(Material material)
    {
        if(_SplatMask0.textureValue != null || _SplatMask1.textureValue != null || _SplatMask2.textureValue != null || _SplatMask3.textureValue != null)
            material.SetKeyword("_NORMALMAP", true);
        else
            material.SetKeyword("_NORMALMAP", false);

        int count = (int) _TexCount.floatValue;
        if (count == 2)
        {
            material.SetKeyword("_TERRAIN_2TEX", true);
            material.SetKeyword("_TERRAIN_3TEX", false);
            material.SetKeyword("_TERRAIN_4TEX", false);
        }
        else if (count == 3)
        {
            material.SetKeyword("_TERRAIN_2TEX", false);
            material.SetKeyword("_TERRAIN_3TEX", true);
            material.SetKeyword("_TERRAIN_4TEX", false);
        }
        else if (count == 4)
        {
            material.SetKeyword("_TERRAIN_2TEX", false);
            material.SetKeyword("_TERRAIN_3TEX", false);
            material.SetKeyword("_TERRAIN_4TEX", true);
        }
    }

    void Popup(ref MaterialProperty property, string label, string[] names, int indent = 0)
    {
        EditorGUI.showMixedValue = property.hasMixedValue;
        var mode = (int)property.floatValue - 2;

        EditorGUI.BeginChangeCheck();
        EditorGUI.indentLevel += indent;
        mode = EditorGUILayout.Popup(label, mode, names);
        EditorGUI.indentLevel -= indent;

        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo(label);
            property.floatValue = (float) mode + 2;
        }

        EditorGUI.showMixedValue = false;
    }
}