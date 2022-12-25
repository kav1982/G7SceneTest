using UnityEditor;
using UnityEngine;
using BioumRP;

public class CharacterCommonGUI : ShaderGUI
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
        public static GUIContent brushTexText = new GUIContent("笔刷贴图");
        public static GUIContent normalMapText = new GUIContent("法线(RG)");
        public static GUIContent emissiveAOMapText = new GUIContent("自发光(RGB) AO(A)");
        public static GUIContent dissolveNoiseText = new GUIContent("溶解噪声＆Tiling");
    }

    MaterialProperty _BlendMode = null;
    MaterialProperty _CullMode = null;

    MaterialProperty _BaseMap = null;
    MaterialProperty _BaseColor = null;
    MaterialProperty _PenumbraTintColor = null;
    MaterialProperty _BrushTex = null;

    //MaterialProperty _NormalMap = null;
    //MaterialProperty _NormalScale = null;
    
    MaterialProperty _EmissiveColor = null;
    MaterialProperty _EmissiveAOMap = null;
    MaterialProperty _EmissiveAOMapUseUV2 = null;
    
    MaterialProperty _AOStrength = null;
    MaterialProperty _IndirectParam = null;
    
    MaterialProperty _Transparent = null;
    MaterialProperty _Cutoff = null;
    MaterialProperty _TransparentZWrite = null;
    MaterialProperty _TransparentShadowCaster = null;
    MaterialProperty _TransparentParam = null;
    
    MaterialProperty _SSSToggle = null;
    MaterialProperty _SSSColor = null;
    
    MaterialProperty _LightIntensity = null;
    MaterialProperty _SmoothDiff = null;
    MaterialProperty _LightOffset = null;
    MaterialProperty _LightControlParam = null;

    //MaterialProperty _UseGlobalLightingControl = null;

    //MaterialProperty _EdgeRange = null;
    //MaterialProperty _EdgeThred = null;
    //MaterialProperty _EdgePow = null;
    //MaterialProperty _ColorRat = null;
    
    MaterialProperty _OUT_LINE_ON;
    MaterialProperty _OutLineCol;
    MaterialProperty _OutLineMul;
    MaterialProperty _OutLineAdd;
    
    MaterialProperty _reflectionRat;
    MaterialProperty _reflectionPow;
    MaterialProperty _SmoothReflection;

    MaterialProperty _UseBrushTex;

    MaterialProperty _UseDissolove;MaterialProperty _DissolveAmount;
    MaterialProperty _DissoloveTurn;
    MaterialProperty _DissolveNoiseTex;MaterialProperty _NoiseTile;
    MaterialProperty _NoiseSpeed;MaterialProperty _ExpandWidth;
    MaterialProperty _ClipWidth;MaterialProperty _ClipPow;
    //MaterialProperty _DissolveDisapper;
    MaterialProperty _DissolveScale; 
    MaterialProperty _DissolveEdgeColor;MaterialProperty _DissolveEdgeColStrength;
    MaterialProperty _DissolveEdgePow;MaterialProperty _DissoloveParam1;
    MaterialProperty _DissoloveParam2;

    MaterialEditor m_MaterialEditor;
    
    private float f1, f2, pos1, pos2;

    public void FindProperties(MaterialProperty[] props)
    {
        _BlendMode = FindProperty("_BlendMode", props);
        _CullMode = FindProperty("_CullMode", props);
        
        _BaseMap = FindProperty("_BaseMap", props);
        _BaseColor = FindProperty("_BaseColor", props);
        _PenumbraTintColor = FindProperty("_PenumbraTintColor", props);
        
        _UseBrushTex = FindProperty("_UseBrushTex", props);
        _BrushTex = FindProperty("_BrushTex", props);

        //_NormalMap = FindProperty("_NormalMap", props);
        //_NormalScale = FindProperty("_NormalScale", props);
        
        _EmissiveColor = FindProperty("_EmissiveColor", props);
        _EmissiveAOMap = FindProperty("_EmissiveAOMap", props);
        _EmissiveAOMapUseUV2 = FindProperty("_EmissiveAOMapUseUV2", props);
        
        _AOStrength = FindProperty("_AOStrength", props);
        _IndirectParam = FindProperty("_IndirectParam", props);
        
        _Transparent = FindProperty("_Transparent", props);
        _Cutoff = FindProperty("_Cutoff", props);
        _TransparentZWrite = FindProperty("_TransparentZWrite", props);
        _TransparentShadowCaster = FindProperty("_TransparentShadowCaster", props);
        _TransparentParam = FindProperty("_TransparentParam", props);
        
        _SSSToggle = FindProperty("_SSSToggle", props);
        _SSSColor = FindProperty("_SSSColor", props);
        
        _LightIntensity = FindProperty("_LightIntensity", props);
        _SmoothDiff = FindProperty("_SmoothDiff", props);
        _LightOffset = FindProperty("_LightOffset", props);
        _LightControlParam = FindProperty("_LightControlParam", props);
        
        
        //_ColorRat = FindProperty("_ColorRat", props);
        
        _OUT_LINE_ON = FindProperty("_OUT_LINE_ON", props);
        _OutLineCol = FindProperty("_OutLineCol", props);
        _OutLineMul = FindProperty("_OutLineMul", props);
        _OutLineAdd = FindProperty("_OutLineAdd", props);
        
        _reflectionRat = FindProperty("_reflectionRat", props);
        _reflectionPow = FindProperty("_reflectionPow", props);
        _SmoothReflection = FindProperty("_SmoothReflection", props);

        _UseDissolove = FindProperty("_UseDissolove", props);
        _DissoloveTurn = FindProperty("_DissoloveTurn", props);
        _DissolveAmount = FindProperty("_DissolveAmount", props);
        _DissolveNoiseTex = FindProperty("_DissolveNoiseTex", props);
        _NoiseTile = FindProperty("_NoiseTile", props);
        _NoiseSpeed = FindProperty("_NoiseSpeed", props);
        _ExpandWidth = FindProperty("_ExpandWidth", props);
        _ClipWidth = FindProperty("_ClipWidth", props);
        _ClipPow = FindProperty("_ClipPow", props);
        //_DissolveDisapper = FindProperty("_DissolveDisapper", props);
        _DissolveScale = FindProperty("_DissolveScale", props);
        _DissolveEdgeColor = FindProperty("_DissolveEdgeColor", props);
        _DissolveEdgeColStrength = FindProperty("_DissolveEdgeColStrength", props);
        _DissolveEdgePow = FindProperty("_DissolveEdgePow", props);
        _DissoloveParam1 = FindProperty("_DissoloveParam1", props);
        _DissoloveParam2 = FindProperty("_DissoloveParam2", props);
        //_DissoloveParam3 = FindProperty("_DissoloveParam3", props);
        
        //_UseGlobalLightingControl = FindProperty("_UseGlobalLightingControl", props);
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
        //m_MaterialEditor.ShaderProperty(_UseGlobalLightingControl, "使用灯光脚本控制光照强度");
        m_MaterialEditor.ShaderProperty(_LightIntensity, "灯光强度");
        m_MaterialEditor.ShaderProperty(_SmoothDiff, "明暗交界线硬度");
        m_MaterialEditor.ShaderProperty(_LightOffset,"减弱光照");
        _LightControlParam.vectorValue = new Vector4(_LightIntensity.floatValue, _SmoothDiff.floatValue,_LightOffset.floatValue);
        m_MaterialEditor.ShaderProperty(_PenumbraTintColor, "暗面颜色");

        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.baseMapText, _BaseMap, _BaseColor);
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_UseBrushTex,"使用笔触贴图");
        if (_UseBrushTex.floatValue != 0)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.brushTexText, _BrushTex);
        }
        EditorGUILayout.Space();
        //m_MaterialEditor.ShaderProperty(_ColorRat, "饱和度");

        Color baseColor = _BaseColor.colorValue;
        //baseColor.a = _UseGlobalLightingControl.floatValue;
        _BaseColor.colorValue = baseColor;
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_OUT_LINE_ON, "描边");
        if(_OUT_LINE_ON.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            {
                m_MaterialEditor.ShaderProperty(_OutLineCol, "颜色");
                GetRangeProperty(ref pos1, ref pos2, _OutLineMul, _OutLineAdd);
                EditorGUILayout.MinMaxSlider("描边位置", ref pos1, ref pos2, 0, 1);
                SetRangeProperty(pos1, pos2, _OutLineMul, _OutLineAdd);
            }
            EditorGUI.indentLevel--;
        }
        
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("菲涅尔");
        EditorGUI.indentLevel++;
        m_MaterialEditor.ShaderProperty(_reflectionRat, "反射系数");
        m_MaterialEditor.ShaderProperty(_reflectionPow, "Pow系数");
        m_MaterialEditor.ShaderProperty(_SmoothReflection, "平滑RdotV");
        EditorGUI.indentLevel--;
        
        EditorGUILayout.Space();
        /*m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, _NormalMap);
        if (_NormalMap.textureValue != null)
            m_MaterialEditor.ShaderProperty(_NormalScale, "法线强度", indent);*/
        
        EditorGUILayout.Space();
        m_MaterialEditor.TexturePropertySingleLine(Styles.emissiveAOMapText, _EmissiveAOMap);
        if (_EmissiveAOMap.textureValue != null)
        {
            m_MaterialEditor.ShaderProperty(_EmissiveAOMapUseUV2, "使用2U", indent);
            m_MaterialEditor.ShaderProperty(_AOStrength, "AO强度", indent);
        }
        m_MaterialEditor.ShaderProperty(_EmissiveColor, "自发光", indent);
        
        EditorGUILayout.Space();

        _IndirectParam.vectorValue = new Vector4(
            1, _AOStrength.floatValue, _EmissiveAOMapUseUV2.floatValue, 0);//_ColorRat.floatValue
        

        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_SSSToggle, "SSS");
        if (_SSSToggle.floatValue != 0)
        {
            m_MaterialEditor.ShaderProperty(_SSSColor, "SSS颜色", indent);
        }
        
        EditorGUILayout.Space();
        m_MaterialEditor.ShaderProperty(_UseDissolove,"开启溶解");
        if (_UseDissolove.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_DissoloveTurn,"反向溶解");
            m_MaterialEditor.ShaderProperty(_DissolveAmount,"溶解度");
            m_MaterialEditor.TexturePropertySingleLine(Styles.dissolveNoiseText,_DissolveNoiseTex,_NoiseTile);
            m_MaterialEditor.ShaderProperty(_NoiseSpeed,"噪声速度");
            m_MaterialEditor.ShaderProperty(_ExpandWidth,"扩张范围");
            m_MaterialEditor.ShaderProperty(_DissolveScale,"扩张幅度");
            m_MaterialEditor.ShaderProperty(_ClipWidth,"裁剪宽度");
            m_MaterialEditor.ShaderProperty(_ClipPow,"裁剪强度");
            //m_MaterialEditor.ShaderProperty(_DissolveDisapper,"溶解消失位置");
            m_MaterialEditor.ShaderProperty(_DissolveEdgeColor,"溶解边缘光颜色");
            m_MaterialEditor.ShaderProperty(_DissolveEdgeColStrength,"溶解边缘光强度");
            m_MaterialEditor.ShaderProperty(_DissolveEdgePow,"溶解边缘光范围");
        }

        _DissoloveParam1.vectorValue = new Vector4(_NoiseTile.floatValue, _NoiseSpeed.floatValue,
            _ExpandWidth.floatValue, _ClipWidth.floatValue);
        _DissoloveParam2.vectorValue = new Vector4(_ClipPow.floatValue,_DissolveScale.floatValue, 
            _DissolveEdgeColStrength.floatValue,_DissolveEdgePow.floatValue);
        

        UpdateKeyword(material);
        
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
            property.floatValue = (float) mode;
        }

        EditorGUI.showMixedValue = false;
    }
    
    void UpdateKeyword(Material material)
    {
        //material.SetKeyword("_NORMALMAP", _NormalMap.textureValue != null);
        material.SetKeyword("_EMISSIVE_AO_MAP", _EmissiveAOMap.textureValue != null);
            
        material.SetKeyword("_SSS", _SSSToggle.floatValue != 0);
        material.SetKeyword("_USE_BRUSHTEX",_UseBrushTex.floatValue != 0);
        material.SetKeyword("_USE_DISSOLOVE", _UseDissolove.floatValue != 0);
        material.SetKeyword("_DISSOLOVETURN", _DissoloveTurn.floatValue != 0);
        

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