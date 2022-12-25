using UnityEditor;
using UnityEngine;

public class SceneTerrainMaskGUI : ShaderGUI
{
    public enum TextureCount
    {
        two,
        three,
        four,
    }
    public enum LightingModel
    {
        Lambert,
        NoLight,
    }

    private static class Styles
    {
        public static string textureCount = "贴图数量";
        public static string lightingModel = "光照模式";
        public static readonly string[] textureCountNames = { "两张", "三张", "四张", };
        public static readonly string[] lightingModelNames = { "简单", "无光照", };
        public static GUIContent splatMapText = new GUIContent("颜色贴图");
        public static GUIContent normalMapText = new GUIContent("法线贴图");
        public static GUIContent controlMapText = new GUIContent("混合贴图");
    }

    MaterialProperty textureCountProp = null;
    MaterialProperty lightingModelProp = null;
    MaterialProperty PenumbraTintColor = null;
    //MaterialProperty lightIntensity = null;
    MaterialProperty controlMap = null;
    MaterialProperty splatMap0 = null;
    MaterialProperty splatMap1 = null;
    MaterialProperty splatMap2 = null;
    MaterialProperty splatMap3 = null;
    MaterialProperty splatScale0 = null;
    MaterialProperty splatScale1 = null;
    MaterialProperty splatScale2 = null;
    MaterialProperty splatScale3 = null;
    MaterialProperty splatScale = null;
    MaterialProperty normalMapToggle = null;
    MaterialProperty normalMap0 = null;
    MaterialProperty normalMap1 = null;
    MaterialProperty normalMap2 = null;
    MaterialProperty normalMap3 = null;
    MaterialProperty normalScale0 = null;
    MaterialProperty normalScale1 = null;
    MaterialProperty normalScale2 = null;
    MaterialProperty normalScale3 = null;
    MaterialProperty normalScale = null;
    MaterialProperty _VertexAO = null;
    MaterialProperty _VertexAOStrength = null;
    MaterialProperty _VertexAOCol = null;
    MaterialProperty _AOColStrength = null;
    MaterialProperty _VertexAOParam = null;

    MaterialEditor m_MaterialEditor;

    public void FindProperties(MaterialProperty[] props)
    {
        textureCountProp = FindProperty("_TexCount", props);
        lightingModelProp = FindProperty("_LightingModel", props);
        //lightIntensity = FindProperty("_LightIntensity", props);
        PenumbraTintColor = FindProperty("_PenumbraTintColor", props);
        controlMap = FindProperty("_Control", props);
        splatMap0 = FindProperty("_Splat0", props);
        splatMap1 = FindProperty("_Splat1", props);
        splatMap2 = FindProperty("_Splat2", props);
        splatMap3 = FindProperty("_Splat3", props);
        splatScale0 = FindProperty("_SplatScale0", props);
        splatScale1 = FindProperty("_SplatScale1", props);
        splatScale2 = FindProperty("_SplatScale2", props);
        splatScale3 = FindProperty("_SplatScale3", props);
        splatScale = FindProperty("_SplatScale", props);
        normalMapToggle = FindProperty("_NormalMapToggle", props);
        normalMap0 = FindProperty("_Normal0", props);
        normalMap1 = FindProperty("_Normal1", props);
        normalMap2 = FindProperty("_Normal2", props);
        normalMap3 = FindProperty("_Normal3", props);
        normalScale0 = FindProperty("_NormalScale0", props);
        normalScale1 = FindProperty("_NormalScale1", props);
        normalScale2 = FindProperty("_NormalScale2", props);
        normalScale3 = FindProperty("_NormalScale3", props);
        normalScale = FindProperty("_NormalScale", props);
        _VertexAO = FindProperty("_VertexAO", props);
        _VertexAOStrength = FindProperty("_VertexAOStrength", props);
        _VertexAOCol = FindProperty("_VertexAOCol", props);
        _AOColStrength = FindProperty("_AOColStrength", props);
        _VertexAOParam = FindProperty("_VertexAOParam", props);
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
        SetupMaterialWithTextureCount(material, (TextureCount) (textureCountProp.floatValue - 2.0f));
        SetupMaterialWithLightingModel(material, (LightingModel) lightingModelProp.floatValue);
    }

    public void SetupMaterialWithTextureCount(Material material, TextureCount textureCount)
    {
        switch (textureCount)
        {
            case TextureCount.two:
                material.SetKeyword("TERRAIN_2TEX", true);
                material.SetKeyword("TERRAIN_3TEX", false);
                material.SetKeyword("TERRAIN_4TEX", false);
                break;
            case TextureCount.three:
                material.SetKeyword("TERRAIN_2TEX", false);
                material.SetKeyword("TERRAIN_3TEX", true);
                material.SetKeyword("TERRAIN_4TEX", false);
                break;
            case TextureCount.four:
                material.SetKeyword("TERRAIN_2TEX", false);
                material.SetKeyword("TERRAIN_3TEX", false);
                material.SetKeyword("TERRAIN_4TEX", true);
                break;
        }
    }

    public void SetupMaterialWithLightingModel(Material material, LightingModel lightingModel)
    {
        switch (lightingModel)
        {
            case LightingModel.Lambert:
                material.SetKeyword("LIGHTMODEL_LAMBERT", true);
                material.SetKeyword("LIGHTMODEL_NOLIGHT", false);
                break;
            case LightingModel.NoLight:
                material.SetKeyword("LIGHTMODEL_LAMBERT", false);
                material.SetKeyword("LIGHTMODEL_NOLIGHT", true);
                break;
        }
    }
    Vector4 splatScaleVector = Vector4.one;
    Vector4 normalScaleVector = Vector4.one;
    public void ShaderPropertiesGUI(Material material)
    {
        TextureCountPopup();
        LightingModelPopup();

        EditorGUILayout.Space(10);
        m_MaterialEditor.TexturePropertySingleLine(Styles.splatMapText, splatMap0);
        m_MaterialEditor.ShaderProperty(splatScale0, "贴图缩放");
        m_MaterialEditor.TexturePropertySingleLine(Styles.splatMapText, splatMap1);
        m_MaterialEditor.ShaderProperty(splatScale1, "贴图缩放");
        if (textureCountProp.floatValue > 2)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.splatMapText, splatMap2);
            m_MaterialEditor.ShaderProperty(splatScale2, "贴图缩放");
        }
        if (textureCountProp.floatValue > 3)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.splatMapText, splatMap3);
            m_MaterialEditor.ShaderProperty(splatScale3, "贴图缩放");
        }

        splatScaleVector.x = splatScale0.floatValue;
        splatScaleVector.y = splatScale1.floatValue;
        splatScaleVector.z = splatScale2.floatValue;
        splatScaleVector.w = splatScale3.floatValue;
        splatScale.vectorValue = splatScaleVector;

        EditorGUILayout.Space(10);
        m_MaterialEditor.ShaderProperty(normalMapToggle, "使用法线贴图");
        if (normalMapToggle.floatValue != 0)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, normalMap0, normalScale0);
            m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, normalMap1, normalScale1);
            if (textureCountProp.floatValue > 2)
                m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, normalMap2, normalScale2);
            if (textureCountProp.floatValue > 3)
                m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, normalMap3, normalScale3);

            normalScaleVector.x = normalScale0.floatValue;
            normalScaleVector.y = normalScale1.floatValue;
            normalScaleVector.z = normalScale2.floatValue;
            normalScaleVector.w = normalScale3.floatValue;
            normalScale.vectorValue = normalScaleVector;
        }

        EditorGUILayout.Space(10);


        EditorGUILayout.Space();
        //m_MaterialEditor.ShaderProperty(lightIntensity, "灯光强度");
        m_MaterialEditor.ShaderProperty(PenumbraTintColor, "暗部颜色");
        

        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_VertexAO, "顶点色AO开关");
        if (_VertexAO.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_VertexAOStrength, "顶点色AO强度");
            m_MaterialEditor.ShaderProperty(_VertexAOCol, "AO颜色");
            m_MaterialEditor.ShaderProperty(_AOColStrength, "AO颜色强度");
            _VertexAOParam.vectorValue = new Vector4(_VertexAOStrength.floatValue, _AOColStrength.floatValue, 0, 0);
            EditorGUI.indentLevel--;
        }
        material.SetKeyword("_VERTEXAO_ON", _VertexAO.floatValue != 0);

        EditorGUILayout.Space(10);
        m_MaterialEditor.TexturePropertySingleLine(Styles.controlMapText, controlMap);

        EditorGUILayout.Space();
        m_MaterialEditor.RenderQueueField();
    }

    void TextureCountPopup()
    {
        EditorGUI.showMixedValue = textureCountProp.hasMixedValue;
        var count = (TextureCount) (textureCountProp.floatValue - 2.0f);

        EditorGUI.BeginChangeCheck();
        count = (TextureCount) EditorGUILayout.Popup(Styles.textureCount, (int) count, Styles.textureCountNames);

        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Texture Count Mode");
            textureCountProp.floatValue = (float) count + 2;
        }

        EditorGUI.showMixedValue = false;
    }

    void LightingModelPopup()
    {
        EditorGUI.showMixedValue = lightingModelProp.hasMixedValue;
        var mode = (LightingModel) lightingModelProp.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (LightingModel) EditorGUILayout.Popup(Styles.lightingModel, (int) mode, Styles.lightingModelNames);

        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("LightingModel Mode");
            lightingModelProp.floatValue = (float) mode;
        }

        EditorGUI.showMixedValue = false;

    }

}