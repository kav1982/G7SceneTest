using UnityEngine;
using UnityEditor;
using System;

public class BiouParticleShaderGUI : ShaderGUI
{
    public enum BlendMode
    {
        Additive,
        AdditiveSoft,
        AlphaBlend,
        Multiply,
        Opaque,
        AlphaTest,
    }

    public enum CullMode
    {
        BackfaceCull,
        DoubleSide
    }

    public enum ZTest
    {
        Less,
        Greater,
        LEqual,
        GEqual,
        Equal,
        NotEqual,
        Always
    }
    
    private static class Styles
    {
        public static string renderingMode = "混合模式";
        public static string cullingMode = "裁剪模式";
        public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));
        public static readonly string[] cullNames = Enum.GetNames(typeof(CullMode));
        public static readonly string[] zTestNames = Enum.GetNames(typeof(ZTest));
        public static GUIContent albedoText = new GUIContent("贴图1", "RGBA");
        public static GUIContent secondaryAlbedoText = new GUIContent("贴图2", "RGBA");
        public static GUIContent distortText = new GUIContent("扰乱贴图", "使用R通道");
        public static GUIContent enableDistortText = new GUIContent("扰乱", "是否开启扰乱");
        public static GUIContent maskText = new GUIContent("遮罩贴图", "使用R通道");
        public static GUIContent enableMaskText = new GUIContent("遮罩", "是否开启遮罩");
        public static GUIContent enableRimText = new GUIContent("边缘光", "是否开启边缘光");
        public static GUIContent enableDissolveText = new GUIContent("溶解", "是否开启溶解");
        public static GUIContent dissolveText = new GUIContent("溶解贴图", "使用R通道");
        public static GUIContent enableClockClip = new GUIContent("CD效果", "是否开启CD效果");
        public static GUIContent openUIClip = new GUIContent("是否开启UI区域裁剪");

    }

    MaterialProperty blendMode = null;
    MaterialProperty cullMode = null;
    MaterialProperty zTest = null;

    MaterialProperty albedoMap = null;
    MaterialProperty albedoMapSecondary = null;
    MaterialProperty enableSecondaryAlbedo = null;
    MaterialProperty albedoAni = null;

    MaterialProperty distortMap = null;
    MaterialProperty secondaryDistortMap = null;
    MaterialProperty distort = null;
    MaterialProperty distortAni = null;
    MaterialProperty distortFactor = null;

    MaterialProperty colorIntensity = null;
    MaterialProperty color = null;
    MaterialProperty backColor = null;

    MaterialProperty mask = null;
    MaterialProperty maskMap = null;

	MaterialProperty stencilComp = null;
	MaterialProperty stencil = null;
	MaterialProperty stencilOp = null;
	MaterialProperty stencilWriteMask = null;
	MaterialProperty stencilReadMask = null;
	MaterialProperty colorMask = null;

	MaterialProperty rim = null;
    MaterialProperty rimPower = null;
    MaterialProperty rimFactor = null;
    MaterialProperty rimColor = null;

    MaterialProperty dissolve = null;
    MaterialProperty dissolveFactor = null;
    MaterialProperty dissolveMap = null;
    MaterialProperty dissolveEdge = null;
    MaterialProperty dissolveEdgeColor = null;

    MaterialProperty clockClip = null;
    MaterialProperty clockClipFactor = null;

    MaterialProperty isParticle = null;

    MaterialProperty isOpenUIClip = null;

    MaterialEditor m_MaterialEditor;
    
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        FindProperties(props, material);
        MaterialChanged(material);

        ShaderPropertiesGUI(material);
    }

    public void ShaderPropertiesGUI(Material material)
    {
        EditorGUI.BeginChangeCheck();
        {
            BlendModePopup();
            if (!material.shader.name.Contains("Bioumaiquan/CommonEffect-DoubleSide"))
            {
                CullModePopup();
            }
            m_MaterialEditor.ShaderProperty(isParticle, "是否粒子");
            ZTestPopup();
            EditorGUILayout.Space();

            m_MaterialEditor.ShaderProperty(colorIntensity, "亮度");
            m_MaterialEditor.ColorProperty(color, "颜色");
            if (material.shader.name.Contains("Bioumaiquan/CommonEffect-DoubleSide"))
            {
                m_MaterialEditor.ColorProperty(backColor, "背面颜色");
            }

            EditorGUILayout.Space();

            DoAlbedoArea(material);
            DoSecondaryAlbedoArea();

            GUILayout.Label("----------------------------", EditorStyles.centeredGreyMiniLabel);
            DoDistortArea(material);

            GUILayout.Label("----------------------------", EditorStyles.centeredGreyMiniLabel);
            DoMaskArea(material);

            GUILayout.Label("----------------------------", EditorStyles.centeredGreyMiniLabel);
            DoRimArea(material);

            GUILayout.Label("----------------------------", EditorStyles.centeredGreyMiniLabel);
            DoDissolveArea(material);

            GUILayout.Label("----------------------------", EditorStyles.centeredGreyMiniLabel);
            DoClockClipAera(material);

			GUILayout.Label("----------------------------", EditorStyles.centeredGreyMiniLabel);
			DoStencilArea(material);
            m_MaterialEditor.ShaderProperty(isOpenUIClip, "是否开启UI裁剪");

        }

        EditorGUILayout.Space();

        //m_MaterialEditor.RenderQueueField();
        //m_MaterialEditor.EnableInstancingField();
        //m_MaterialEditor.DoubleSidedGIField();
    }

    public void FindProperties(MaterialProperty[] props, Material material)
    {
        blendMode = FindProperty("_Mode", props);
        cullMode = FindProperty("_CullMode", props);
        zTest = FindProperty("_ZTest", props);

        albedoMap = FindProperty("_MainTex", props);
        albedoMapSecondary = FindProperty("_SecondaryTex", props);
        enableSecondaryAlbedo = FindProperty("_EnableSecondaryTex", props);
        albedoAni = FindProperty("_MainTexUVAni", props);

        colorIntensity = FindProperty("_ColorFactor", props);
        color = FindProperty("_TintColor", props);

        distortMap = FindProperty("_DistortMap", props);
        secondaryDistortMap = FindProperty("_SecondaryDistortMap", props); 
        distort = FindProperty("_Distort", props);
        distortAni = FindProperty("_UVAnination", props);
        distortFactor = FindProperty("_DistortFactor", props);

        maskMap = FindProperty("_MaskMap", props);
        mask = FindProperty("_Mask", props);

		stencilComp = FindProperty("_StencilComp", props);
		stencil = FindProperty("_Stencil", props);
		stencilOp = FindProperty("_StencilOp", props);
		stencilWriteMask = FindProperty("_StencilWriteMask", props);
		stencilReadMask = FindProperty("_StencilReadMask", props);
		colorMask = FindProperty("_ColorMask", props);

		rim = FindProperty("_Rim", props);
        rimPower = FindProperty("_rimPower", props);
        rimFactor = FindProperty("_rimFactor", props);
        rimColor = FindProperty("_rimColor", props);

        dissolve = FindProperty("_Dissolve", props);
        dissolveFactor = FindProperty("_DissolveFactor", props);
        dissolveMap = FindProperty("_DissolveMap", props);
        dissolveEdge = FindProperty("_DissolveEdge", props);
        dissolveEdgeColor = FindProperty("_DissolveEdgeColor", props);

        clockClip = FindProperty("_Enable_Clock_Clip", props);
        clockClipFactor = FindProperty("_ClockClipFactor", props);
        isOpenUIClip = FindProperty("_ClipOpen", props);
        isParticle = FindProperty("_IsParticle", props);
        

        if (material.shader.name.Contains("Bioumaiquan/CommonEffect-DoubleSide"))
        {
            backColor = FindProperty("_BackTintColor", props);
        }
    }

    static void MaterialChanged(Material material)
    {
        SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));
        SetupMaterialWithCullMode(material, (CullMode)material.GetFloat("_CullMode"));
    }

    public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Additive:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ADDITIVESOFT_ON");
                material.DisableKeyword("_MULTIPLY_ON");
                material.DisableKeyword("_ALPHATEST_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.AdditiveSoft:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcColor);
                material.EnableKeyword("_ADDITIVESOFT_ON");
                material.DisableKeyword("_MULTIPLY_ON");
                material.DisableKeyword("_ALPHATEST_ON");
                material.SetInt("_ZWrite", 0);
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.AlphaBlend:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.DisableKeyword("_ADDITIVESOFT_ON");
                material.DisableKeyword("_MULTIPLY_ON");
                material.DisableKeyword("_ALPHATEST_ON");
                material.SetInt("_ZWrite", 0);
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Multiply:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.SrcColor);
                material.DisableKeyword("_ADDITIVESOFT_ON");
                material.EnableKeyword("_MULTIPLY_ON");
                material.DisableKeyword("_ALPHATEST_ON");
                material.SetInt("_ZWrite", 0);
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "Opaque");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.DisableKeyword("_ADDITIVESOFT_ON");
                material.DisableKeyword("_MULTIPLY_ON");
                material.DisableKeyword("_ALPHATEST_ON");
                material.SetInt("_ZWrite", 1);
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                break;
            case BlendMode.AlphaTest:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.DisableKeyword("_ADDITIVESOFT_ON");
                material.DisableKeyword("_MULTIPLY_ON");
                material.EnableKeyword("_ALPHATEST_ON");
                material.SetInt("_ZWrite", 1);
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
        }
    }

    public static void SetupMaterialWithCullMode(Material material, CullMode cullMode)
    {
        if (material.shader.name.Contains("Bioumaiquan/CommonEffect-DoubleSide"))
        {
            material.SetInt("_Cull", (int)UnityEngine.Rendering.CullMode.Back);
        }
        else
        {
            switch (cullMode)
            {
                case CullMode.BackfaceCull:
                    material.SetInt("_Cull", (int)UnityEngine.Rendering.CullMode.Back);
                    break;
                case CullMode.DoubleSide:
                    material.SetInt("_Cull", (int)UnityEngine.Rendering.CullMode.Off);
                    break;
            }
        }
    }

    void BlendModePopup()
    {
        EditorGUI.showMixedValue = blendMode.hasMixedValue;
        var mode = (BlendMode)blendMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (BlendMode)EditorGUILayout.Popup(Styles.renderingMode, (int)mode, Styles.blendNames);

        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
            blendMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }

    void CullModePopup()
    {
        EditorGUI.showMixedValue = cullMode.hasMixedValue;
        var mode = (CullMode)cullMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (CullMode)EditorGUILayout.Popup(Styles.cullingMode, (int)mode, Styles.cullNames);

        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Culling Mode");
            cullMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }

    void ZTestPopup()
    {
        EditorGUI.showMixedValue = zTest.hasMixedValue;
        var mode = (ZTest)zTest.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (ZTest)EditorGUILayout.Popup("ZTest", (int)mode, Styles.zTestNames);

        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("ZTest");
            zTest.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }

    void DoAlbedoArea(Material material)
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, albedoMap);
        m_MaterialEditor.TextureScaleOffsetProperty(albedoMap);
        m_MaterialEditor.ShaderProperty(albedoAni, "UV动画 XY贴图1 ZW贴图2");
    }

    void DoSecondaryAlbedoArea()
    {
        m_MaterialEditor.ShaderProperty(enableSecondaryAlbedo, "贴图2(与贴图1相乘)");
        if (enableSecondaryAlbedo.floatValue != 0)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.secondaryAlbedoText, albedoMapSecondary);
            m_MaterialEditor.TextureScaleOffsetProperty(albedoMapSecondary);
        }
        
    }

    void DoDistortArea(Material material)
    {
        m_MaterialEditor.ShaderProperty(distort, Styles.enableDistortText);

        if (distort.floatValue != 0)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.distortText, distortMap);
            m_MaterialEditor.TextureScaleOffsetProperty(distortMap);
            m_MaterialEditor.TexturePropertySingleLine(Styles.distortText, secondaryDistortMap);
            m_MaterialEditor.TextureScaleOffsetProperty(secondaryDistortMap);
            m_MaterialEditor.ShaderProperty(distortFactor, "扰乱强度");
            m_MaterialEditor.VectorProperty(distortAni, "UV动画 XY贴图1 ZW贴图2");
        }
    }

    void DoMaskArea(Material material)
    {
        m_MaterialEditor.ShaderProperty(mask, Styles.enableMaskText);

        if (mask.floatValue != 0)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.maskText, maskMap);
            m_MaterialEditor.TextureScaleOffsetProperty(maskMap);
        }
    }
	void DoStencilArea(Material material)
	{
		m_MaterialEditor.ShaderProperty(stencilComp, "Stencil Comparison");
		m_MaterialEditor.ShaderProperty(stencil, "Stencil ID");
		m_MaterialEditor.ShaderProperty(stencilOp, "Stencil Operation");
		m_MaterialEditor.ShaderProperty(stencilWriteMask, "Stencil Write Mask");
		m_MaterialEditor.ShaderProperty(stencilReadMask, "Stencil Read Mask");
		m_MaterialEditor.ShaderProperty(colorMask, "Color Mask");
	}

	void DoRimArea(Material material)
    {
        m_MaterialEditor.ShaderProperty(rim, Styles.enableRimText);

        if (rim.floatValue != 0)
        {
            m_MaterialEditor.ShaderProperty(rimColor, "颜色");
            m_MaterialEditor.ShaderProperty(rimFactor, "强度");
            m_MaterialEditor.ShaderProperty(rimPower, "范围");
        }
    }

    void DoDissolveArea(Material material)
    {
        m_MaterialEditor.ShaderProperty(dissolve, Styles.enableDissolveText);

        if (dissolve.floatValue != 0)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.dissolveText, dissolveMap);
            m_MaterialEditor.TextureScaleOffsetProperty(dissolveMap);
            m_MaterialEditor.ShaderProperty(dissolveFactor, "溶解强度");
            m_MaterialEditor.ShaderProperty(dissolveEdge, "边缘宽度");
            m_MaterialEditor.ShaderProperty(dissolveEdgeColor, "边缘颜色");
        }
    }

    void DoClockClipAera(Material material)
    {
        m_MaterialEditor.ShaderProperty(clockClip, Styles.enableClockClip);

        if (clockClip.floatValue != 0)
        {
            m_MaterialEditor.ShaderProperty(clockClipFactor, "裁剪强度");
        }
    }
}
