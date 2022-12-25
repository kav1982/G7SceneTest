using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Assertions;
using UnityBlendMode = UnityEngine.Rendering.BlendMode;
using UnityCullMode = UnityEngine.Rendering.CullMode;
using UnityTestMode = UnityEngine.Rendering.CompareFunction;

namespace BioumRP.Effect
{
    public class EffectCommonGUI_V2 : ShaderGUI
    {
        public enum BlendMode
        {
            Blend,
            Additive,
            Opaque,
            AlphaTest,
            UIFog,
        }

        public enum CullMode
        {
            Front,
            Back,
            Double,
        }

        private static class Styles
        {
            public static readonly string renderingMode = "混合模式";
            public static readonly string cullingMode = "裁剪模式";
            public static readonly string textureBlendMode = "与主贴图的混合模式";
            public static readonly string rimColorBlendMode = "边缘光与颜色混合";
            public static readonly string rimAlphaBlendMode = "边缘光与Alpha混合";
            public static readonly string rimAlphaSource = "Alpha来源";
            public static readonly string[] blendNames = { "Blend", "Add", "不透明", "透贴", "UI迷雾" };
            public static readonly string[] cullNames = { "正面显示", "背面显示", "双面显示" };
            public static readonly string[] textureBlendNames = { "乘法", "相加" };
            public static readonly string[] rimBlendNames = { "相加", "相乘", };
            public static readonly string[] rimAlphaBlendNames = { "相加", "相乘", "使用边缘光作为Alpha",};
            public static readonly string[] rimAlphaSourceNames = { "主贴图", "所有功能混合后",};
            public static readonly string[] edgeContactModeNames = { "渐隐", "高亮",};
            public static readonly string[] alphaSourceNames = { "R", "G", "B", "A",};
        }

        #region Property
        
        MaterialProperty _BaseColor = null;
        MaterialProperty _BackColor = null;
        MaterialProperty _SubColor = null;
        MaterialProperty _BackSubColor = null;
        
        MaterialProperty _BaseMapAlphaMask = null;
        MaterialProperty _SubMapAlphaMask = null;
        MaterialProperty _BaseMapAlphaChannel = null;
        MaterialProperty _SubMapAlphaChannel = null;


        MaterialProperty _ZTestAlways = null;
        MaterialProperty _OverlayRender = null;
        MaterialProperty _BlendMode = null;
        MaterialProperty _CullMode = null;
        MaterialProperty _TextureBlendMode = null;

        MaterialProperty _BaseMap = null;
        MaterialProperty _SubMap = null;

        MaterialProperty _BaseMapUVSource = null;
        MaterialProperty _BaseMapUVAniSource = null;
        MaterialProperty _SubMapUVSource = null;
        MaterialProperty _DistortMap0UVSource = null;
        MaterialProperty _DistortMap1UVSource = null;
        MaterialProperty _UVSourceParam0 = null;
        
        MaterialProperty _MaskMapUVSource = null;
        MaterialProperty _DisplacementMapUVSource = null;
        MaterialProperty _DissolveMapUVSource = null;
        MaterialProperty _UVSourceParam1 = null;
        
        MaterialProperty _UseSubTexture = null;
        MaterialProperty _AlbedoUVAni = null;
        MaterialProperty _MainUVAni = null;
        MaterialProperty _SubUVAni = null;

        MaterialProperty _DistortMap0 = null;
        MaterialProperty _DistortMap1 = null;
        MaterialProperty _UseDistort = null;
        MaterialProperty _UseDistort1 = null;
        MaterialProperty _DistortUVAni = null;
        MaterialProperty _Distort0Factor = null;
        MaterialProperty _Distort1Factor = null;
        MaterialProperty _DistortParam = null;


        MaterialProperty _UseMask = null;
        MaterialProperty _MaskMap = null;
        MaterialProperty _MaskRotationAngle = null;
        MaterialProperty _MaskApplyDistort = null;
        MaterialProperty _MaskAffectAlpha = null;
        MaterialProperty _MaskAffectDissolve = null;
        MaterialProperty _MaskAffectDisplacement = null;
        MaterialProperty _MaskMapParam = null;

        MaterialProperty _UseRim = null;
        MaterialProperty _RimInverse = null;
        MaterialProperty _RimColorBlendMode = null;
        MaterialProperty _RimAlphaBlendMode = null;
        //MaterialProperty _RimAlphaSource = null;
        MaterialProperty _rimPower = null;
        MaterialProperty _rimColor = null;
        MaterialProperty _rimEdge = null;
        MaterialProperty _RimParam0 = null;
        MaterialProperty _RimParam1 = null;

        MaterialProperty _UseDissolve = null;
        MaterialProperty _DissolveFactor = null;
        MaterialProperty _DissolveMap = null;
        MaterialProperty _DissolveEdge = null;
        MaterialProperty _DissolveSoft = null;
        MaterialProperty _DissolveEdgeSoft = null;
        //MaterialProperty _DissolveEdgeMode = null;
        MaterialProperty _DissolveEdgeColor = null;
        MaterialProperty _DissolveAni = null;
        MaterialProperty _DissolveParam = null;

        MaterialProperty _UseParticleCustomData = null;
        MaterialProperty _Cutoff = null;

        MaterialProperty _CustomQueueOffset = null;
        MaterialProperty _TransparentZWrite = null;

        MaterialProperty _UseFog = null;
        MaterialProperty _FogIntensity = null;
        MaterialProperty _FogParam = null;
        
        MaterialProperty _UseEdgeContact = null;
        MaterialProperty _EdgeContactMode = null;
        MaterialProperty _EdgeContactFade = null;
        MaterialProperty _EdgeContactColor = null;
        //MaterialProperty _EdgeContactParam = null;
        
        MaterialProperty _UseDisplacementMap;
        MaterialProperty _DisplacementMap;
        MaterialProperty _DisplacementStrength;
        MaterialProperty _DisplacementUVAni;
        MaterialProperty _DisplacementParam;

        MaterialProperty _UseLighting = null;
        MaterialProperty _TowardCamera = null;
        MaterialProperty _IsUIEffect = null;
        MaterialProperty _Stencil = null;
        MaterialProperty _StencilComp = null;

        MaterialProperty _ReceiveFog = null;

        public void FindProperties(MaterialProperty[] props, Material material)
        {
            _BlendMode = FindProperty("_BlendMode", props);
            _ZTestAlways = FindProperty("_ZTestAlways", props);
            _OverlayRender = FindProperty("_OverlayRender", props);
            _CullMode = FindProperty("_CullMode", props);
            _TextureBlendMode = FindProperty("_TextureBlendMode", props);
            _IsUIEffect = FindProperty("_IsUIEffect", props);

            _BaseColor = FindProperty("_BaseColor", props);
            _BackColor = FindProperty("_BackColor", props);
            _SubColor = FindProperty("_SubColor", props);
            _BackSubColor = FindProperty("_BackSubColor", props);

            _BaseMap = FindProperty("_BaseMap", props);
            _SubMap = FindProperty("_SubMap", props);
            _UseSubTexture = FindProperty("_UseSubTexture", props);
            _AlbedoUVAni = FindProperty("_AlbedoUVAni", props);
            _MainUVAni = FindProperty("_MainUVAni", props);
            _SubUVAni = FindProperty("_SubUVAni", props);
            
            _BaseMapAlphaChannel = FindProperty("_BaseMapAlphaChannel", props);
            _SubMapAlphaChannel = FindProperty("_SubMapAlphaChannel", props);
            _BaseMapAlphaMask = FindProperty("_BaseMapAlphaMask", props);
            _SubMapAlphaMask = FindProperty("_SubMapAlphaMask", props);
            
            _BaseMapUVSource = FindProperty("_BaseMapUVSource", props);
            _BaseMapUVAniSource = FindProperty("_BaseMapUVAniSource", props);
            _SubMapUVSource = FindProperty("_SubMapUVSource", props);
            _DistortMap0UVSource = FindProperty("_DistortMap0UVSource", props);
            _DistortMap1UVSource = FindProperty("_DistortMap1UVSource", props);
            _UVSourceParam0 = FindProperty("_UVSourceParam0", props);
            
            _MaskMapUVSource = FindProperty("_MaskMapUVSource", props);
            _DisplacementMapUVSource = FindProperty("_DisplacementMapUVSource", props);
            _DissolveMapUVSource = FindProperty("_DissolveMapUVSource", props);
            _UVSourceParam1 = FindProperty("_UVSourceParam1", props);

            _DistortMap0 = FindProperty("_DistortMap0", props);
            _DistortMap1 = FindProperty("_DistortMap1", props);
            _UseDistort = FindProperty("_UseDistort", props);
            _UseDistort1 = FindProperty("_UseDistort1", props);
            _DistortUVAni = FindProperty("_DistortUVAni", props);
            _Distort0Factor = FindProperty("_Distort0Factor", props);
            _Distort1Factor = FindProperty("_Distort1Factor", props);
            _DistortParam = FindProperty("_DistortParam", props);

            _MaskMap = FindProperty("_MaskMap", props);
            _MaskRotationAngle = FindProperty("_MaskRotationAngle", props);
            _UseMask = FindProperty("_UseMask", props);
            _MaskApplyDistort = FindProperty("_MaskApplyDistort", props);
            _MaskAffectAlpha = FindProperty("_MaskAffectAlpha", props);
            _MaskAffectDissolve = FindProperty("_MaskAffectDissolve", props);
            _MaskAffectDisplacement = FindProperty("_MaskAffectDisplacement", props);
            _MaskMapParam = FindProperty("_MaskMapParam", props);

            _UseRim = FindProperty("_UseRim", props);
            _RimInverse = FindProperty("_RimInverse", props);
            _RimColorBlendMode = FindProperty("_RimColorBlendMode", props);
            _RimAlphaBlendMode = FindProperty("_RimAlphaBlendMode", props);
            //_RimAlphaSource = FindProperty("_RimAlphaSource", props);
            _rimPower = FindProperty("_rimPower", props);
            _rimColor = FindProperty("_rimColor", props);
            _rimEdge = FindProperty("_rimEdge", props);
            _RimParam0 = FindProperty("_RimParam0", props);
            _RimParam1 = FindProperty("_RimParam1", props);

            _UseDissolve = FindProperty("_UseDissolve", props);
            _DissolveFactor = FindProperty("_DissolveFactor", props);
            _DissolveMap = FindProperty("_DissolveMap", props);
            _DissolveEdge = FindProperty("_DissolveEdge", props);
            _DissolveSoft = FindProperty("_DissolveSoft", props);
            _DissolveEdgeSoft = FindProperty("_DissolveEdgeSoft", props);
            _DissolveEdgeColor = FindProperty("_DissolveEdgeColor", props);
            _DissolveAni = FindProperty("_DissolveAni", props);
            _DissolveParam = FindProperty("_DissolveParam", props);

            _UseParticleCustomData = FindProperty("_UseParticleCustomData", props);
            _Cutoff = FindProperty("_Cutoff", props);
            _CustomQueueOffset = FindProperty("_CustomQueueOffset", props);
            _TransparentZWrite = FindProperty("_TransparentZWrite", props);

            _UseFog = FindProperty("_UseFog", props);
            _FogIntensity = FindProperty("_FogIntensity", props);
            _FogParam = FindProperty("_FogParam", props);
            
            _UseEdgeContact = FindProperty("_UseEdgeContact", props);
            _EdgeContactMode = FindProperty("_EdgeContactMode", props);
            _EdgeContactFade = FindProperty("_EdgeContactFade", props);
            _EdgeContactColor = FindProperty("_EdgeContactColor", props);
            
            _UseDisplacementMap = FindProperty("_UseDisplacementMap", props);
            _DisplacementMap = FindProperty("_DisplacementMap", props);
            _DisplacementStrength = FindProperty("_DisplacementStrength", props);
            _DisplacementUVAni = FindProperty("_DisplacementUVAni", props);
            _DisplacementParam = FindProperty("_DisplacementParam", props);

            _UseLighting = FindProperty("_UseLighting", props);
            _TowardCamera = FindProperty("_TowardCamera", props);

            _Stencil = FindProperty("_Stencil", props);
            _StencilComp = FindProperty("_StencilComp", props);
            
            _ReceiveFog = FindProperty("_ReceiveFog", props);
        }
        #endregion


        MaterialEditor m_MaterialEditor;
        

        private string m_HeaderStateKey = null;
        private const string k_KeyPrefix = "BioumRP.Effect:Material:UI_State:";
        private SavedBool m_StateFoldout;
        private SavedBool m_BaseMapFoldout;
        private SavedBool m_SubMapFoldout;
        private SavedBool m_DistortFoldout;
        private SavedBool m_DisplacementFoldout;
        private SavedBool m_DissolveFoldout;
        private SavedBool m_MaskFoldout;
        private SavedBool m_RimFoldout;
        private SavedBool m_SoftParticleFoldout;
        private SavedBool m_ShowInfo;
        private string separate = "===============================================";
        
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            m_MaterialEditor = materialEditor;
            Material material = materialEditor.target as Material;

            m_HeaderStateKey = k_KeyPrefix + material.shader.name; // Create key string for editor prefs
            m_StateFoldout = new SavedBool($"{m_HeaderStateKey}.StateFoldout", true);
            m_BaseMapFoldout = new SavedBool($"{m_HeaderStateKey}.BaseMapFoldout", true);
            m_SubMapFoldout = new SavedBool($"{m_HeaderStateKey}.SubMapFoldout", true);
            m_DistortFoldout = new SavedBool($"{m_HeaderStateKey}.DistortFoldout", true);
            m_DisplacementFoldout = new SavedBool($"{m_HeaderStateKey}.DisplacementFoldout", true);
            m_DissolveFoldout = new SavedBool($"{m_HeaderStateKey}.DissolveFoldout", true);
            m_MaskFoldout = new SavedBool($"{m_HeaderStateKey}.MaskFoldout", true);
            m_RimFoldout = new SavedBool($"{m_HeaderStateKey}.RimFoldout", true);
            m_SoftParticleFoldout = new SavedBool($"{m_HeaderStateKey}.SoftParticle", true);
            m_ShowInfo = new SavedBool($"{m_HeaderStateKey}.ShowInfo", false);

            FindProperties(props, material);
            MaterialChanged(material);
            ShaderPropertiesGUI(material);
            UpdateKeyword(material);
        }

        void MaterialChanged(Material material)
        {
            SetupMaterialWithBlendMode(material, (BlendMode)_BlendMode.floatValue);
            SetupMaterialWithCullMode(material, (CullMode)_CullMode.floatValue);
        }

        int GetZTest() => _ZTestAlways.floatValue != 0 ? (int)UnityTestMode.Always : (int)UnityTestMode.LessEqual;
        void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
        {
            switch (blendMode)
            {
                case BlendMode.Blend:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_SrcBlend", (int)UnityBlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityBlendMode.OneMinusSrcAlpha);
                    material.SetInt("_ZWrite", (int)_TransparentZWrite.floatValue);
                    material.renderQueue = (int)RenderQueue.Transparent + (int)_CustomQueueOffset.floatValue;
                    break;
                case BlendMode.Additive:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_SrcBlend", (int)UnityBlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityBlendMode.OneMinusSrcAlpha);
                    material.SetInt("_ZWrite", (int)_TransparentZWrite.floatValue);
                    material.renderQueue = (int)RenderQueue.Transparent + (int)_CustomQueueOffset.floatValue;
                    break;
                case BlendMode.Opaque:
                    material.SetOverrideTag("RenderType", "Opaque");
                    material.SetInt("_SrcBlend", (int)UnityBlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityBlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    material.renderQueue = (int)RenderQueue.Geometry;
                    break;
                case BlendMode.AlphaTest:
                    material.SetOverrideTag("RenderType", "TransparentCutout");
                    material.SetInt("_SrcBlend", (int)UnityBlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityBlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    material.renderQueue = (int)RenderQueue.AlphaTest;
                    break;
                case BlendMode.UIFog:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_SrcBlend", (int)UnityBlendMode.DstAlpha);
                    material.SetInt("_DstBlend", (int)UnityBlendMode.OneMinusDstAlpha);
                    material.SetInt("_ZWrite", (int)_TransparentZWrite.floatValue);
                    material.renderQueue = (int)RenderQueue.Transparent + (int)_CustomQueueOffset.floatValue;
                    break;
            }
        }

        void SetupMaterialWithCullMode(Material material, CullMode cullMode)
        {
            switch (cullMode)
            {
                case CullMode.Front:
                    material.SetInt("_Cull", (int)UnityCullMode.Back);
                    break;
                case CullMode.Back:
                    material.SetInt("_Cull", (int)UnityCullMode.Front);
                    break;
                case CullMode.Double:
                    material.SetInt("_Cull", (int)UnityCullMode.Off);
                    break;
            }
        }

        private const int indent = 1;

        public void ShaderPropertiesGUI(Material material)
        {
            PerformanceArea(material);
            
            EditorGUILayout.Space();
            m_StateFoldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_StateFoldout.value, "状态设置");
            if (m_StateFoldout.value)
            {
                EditorGUI.indentLevel += indent;

                m_ShowInfo.value = EditorGUILayout.Toggle("显示说明", m_ShowInfo.value);
                
                EditorGUILayout.Space();
                m_MaterialEditor.Popup(_BlendMode, Styles.renderingMode, Styles.blendNames);
                
                if ((BlendMode)_BlendMode.floatValue == BlendMode.AlphaTest)
                    m_MaterialEditor.ShaderProperty(_Cutoff, "透贴强度", indent);
                
                if ((BlendMode)_BlendMode.floatValue == BlendMode.Additive ||
                    (BlendMode)_BlendMode.floatValue == BlendMode.Blend || (BlendMode)_BlendMode.floatValue == BlendMode.UIFog)
                {
                    EditorGUI.indentLevel += indent;
                    m_MaterialEditor.ShaderProperty(_TransparentZWrite, "深度写入");
                    if(m_ShowInfo.value)
                        EditorGUILayout.LabelField("半透明物体写入深度, 一定程度上改善排序错误, 但是只有在不开启\"忽略遮挡\"功能时才有效", EditorStyles.helpBox);
                    EditorGUI.indentLevel -= indent;
                }

                EditorGUILayout.Space();
                m_MaterialEditor.Popup(_CullMode, Styles.cullingMode, Styles.cullNames);
                
                EditorGUILayout.Space();
                m_MaterialEditor.ShaderProperty(_ZTestAlways, "忽略遮挡");
                if(m_ShowInfo.value)
                    EditorGUILayout.LabelField("开启后不会被不透明物体遮挡, 但是依然会被半透明物体遮挡", EditorStyles.helpBox);
                material.SetInt("_ZTest", GetZTest());
                
                EditorGUILayout.Space();
                m_MaterialEditor.ShaderProperty(_OverlayRender, "显示在最前");
                if(m_ShowInfo.value)
                    EditorGUILayout.LabelField("开启后显示在所有物体之前, 不被任何物体遮挡", EditorStyles.helpBox);
                if (_OverlayRender.floatValue != 0)
                {
                    _ZTestAlways.floatValue = 1;
                    material.renderQueue = (int)RenderQueue.Overlay - 50 + (int)_CustomQueueOffset.floatValue;
                }
                
                EditorGUILayout.Space();
                m_MaterialEditor.ShaderProperty(_UseParticleCustomData, "使用粒子发射器自定义数据");
                if(m_ShowInfo.value)
                    EditorGUILayout.LabelField("使用该功能需要先添加UV2, 再添加Custom1.xyzw, 再添加Custom2.xyzw \n具体通道数据在下方各功能模块内描述", 
                        EditorStyles.helpBox);

                // m_MaterialEditor.ShaderProperty(_UseFog, "接受雾");
                // if (_UseFog.floatValue != 0)
                //     m_MaterialEditor.ShaderProperty(_FogIntensity, "雾强度", indent);

                EditorGUILayout.Space();
                m_MaterialEditor.ShaderProperty(_UseLighting, "接受光照");
                EditorGUILayout.Space();
                m_MaterialEditor.ShaderProperty(_TowardCamera, "始终朝向摄像机");


                if ((BlendMode)_BlendMode.floatValue != BlendMode.AlphaTest &&
                    (BlendMode)_BlendMode.floatValue != BlendMode.Opaque)
                {
                    EditorGUILayout.Space();
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.PrefixLabel("自定义排序");
                    _CustomQueueOffset.floatValue =
                        EditorGUILayout.IntSlider((int)_CustomQueueOffset.floatValue, -50, 50);
                    EditorGUILayout.EndHorizontal();
                    if(m_ShowInfo.value)
                        EditorGUILayout.LabelField("设置RenderQueue, 数字大的遮挡数字小的, 数字相同时按照距离排序 \n大多数情况下不需要修改这个值", EditorStyles.helpBox);
                }
                m_MaterialEditor.ShaderProperty(_IsUIEffect, "UI特效");

                if (_IsUIEffect.floatValue != 0 && (BlendMode)_BlendMode.floatValue == BlendMode.UIFog)
                {
                    m_MaterialEditor.ShaderProperty(_Stencil, "UI裁剪值");
                    _StencilComp.floatValue = 3;
                }
                else
                {
                    _Stencil.floatValue = 0;
                    _StencilComp.floatValue = 8;
                }
                
                m_MaterialEditor.ShaderProperty(_ReceiveFog, "接收雾效");


                EditorGUI.indentLevel -= indent;
                EditorGUILayout.LabelField(separate, EditorStyles.centeredGreyMiniLabel);

                _FogParam.vectorValue = new Vector4(
                    _UseFog.floatValue, _FogIntensity.floatValue, _Cutoff.floatValue,
                    _UseParticleCustomData.floatValue);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();


            EditorGUILayout.Space();
            m_BaseMapFoldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_BaseMapFoldout.value, "主贴图");
            if (m_BaseMapFoldout.value)
            {
                EditorGUI.indentLevel += indent;
                BaseMapArea();
                EditorGUI.indentLevel -= indent;

                GUILayout.Label(separate, EditorStyles.centeredGreyMiniLabel);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();


            EditorGUILayout.Space();
            m_SubMapFoldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_SubMapFoldout.value, "副贴图");
            if (m_SubMapFoldout.value)
            {
                EditorGUI.indentLevel += indent;
                SubMapArea(material);
                EditorGUI.indentLevel -= indent;
                GUILayout.Label(separate, EditorStyles.centeredGreyMiniLabel);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            _AlbedoUVAni.vectorValue =
                new Vector4(_MainUVAni.vectorValue.x, _MainUVAni.vectorValue.y, _SubUVAni.vectorValue.x,
                    _SubUVAni.vectorValue.y);

            EditorGUILayout.Space();
            m_DissolveFoldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_DissolveFoldout.value, "溶解");
            if (m_DissolveFoldout.value)
            {
                EditorGUI.indentLevel += indent;
                DissolveArea(material);
                EditorGUI.indentLevel -= indent;
                GUILayout.Label(separate, EditorStyles.centeredGreyMiniLabel);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();


            EditorGUILayout.Space();
            m_DistortFoldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_DistortFoldout.value, "扰乱");
            if (m_DistortFoldout.value)
            {
                EditorGUI.indentLevel += indent;
                DistortArea(material);
                EditorGUI.indentLevel -= indent;
                GUILayout.Label(separate, EditorStyles.centeredGreyMiniLabel);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();


            EditorGUILayout.Space();
            m_MaskFoldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_MaskFoldout.value, "遮罩");
            if (m_MaskFoldout.value)
            {
                EditorGUI.indentLevel += indent;
                MaskArea(material);
                EditorGUI.indentLevel -= indent;
                GUILayout.Label(separate, EditorStyles.centeredGreyMiniLabel);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();


            EditorGUILayout.Space();
            m_RimFoldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_RimFoldout.value, "边缘光");
            if (m_RimFoldout.value)
            {
                EditorGUI.indentLevel += indent;
                RimArea(material);
                EditorGUI.indentLevel -= indent;
                GUILayout.Label(separate, EditorStyles.centeredGreyMiniLabel);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            _DistortParam.vectorValue = new Vector4(
                _Distort0Factor.floatValue, _Distort1Factor.floatValue, _MaskApplyDistort.floatValue);
            
            
            EditorGUILayout.Space();
            m_SoftParticleFoldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_SoftParticleFoldout.value, "接触边缘");
            if (m_SoftParticleFoldout.value)
            {
                EditorGUI.indentLevel += indent;
                EdgeContactArea(material);
                EditorGUI.indentLevel -= indent;
                GUILayout.Label(separate, EditorStyles.centeredGreyMiniLabel);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            
            EditorGUILayout.Space();
            m_DisplacementFoldout.value = EditorGUILayout.BeginFoldoutHeaderGroup(m_DisplacementFoldout.value, "置换");
            if (m_DisplacementFoldout.value)
            {
                EditorGUI.indentLevel += indent;
                DisplacementMapArea();
                EditorGUI.indentLevel -= indent;
                GUILayout.Label(separate, EditorStyles.centeredGreyMiniLabel);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            _UVSourceParam0.vectorValue = new Vector4(
                _BaseMapUVSource.floatValue, _SubMapUVSource.floatValue, 
                _DistortMap0UVSource.floatValue, _DistortMap1UVSource.floatValue);
            
            _UVSourceParam1.vectorValue = new Vector4(
                _MaskMapUVSource.floatValue, _DisplacementMapUVSource.floatValue, 
                _DissolveMapUVSource.floatValue, _BaseMapUVAniSource.floatValue);
        }

        void PerformanceArea(Material material)
        {
            int performanceLevel = UpdatePerformanceLevel(material);
            string levelString = "低";
            MessageType messageType = MessageType.Info;
            if (performanceLevel >= 6)
            {
                messageType = MessageType.Warning;
                levelString = "中";
            }
            if (performanceLevel >= 10)
            {
                messageType = MessageType.Error;
                levelString = "中高";
            }
            if (performanceLevel >= 14)
            {
                messageType = MessageType.Error;
                levelString = "高";
            }
            EditorGUILayout.HelpBox("预估性能消耗 : " + levelString, messageType);
        }
        
        void BaseMapArea()
        {
            if ((CullMode)_CullMode.floatValue != CullMode.Back)
                m_MaterialEditor.ColorProperty(_BaseColor, "颜色");
            if ((CullMode)_CullMode.floatValue != CullMode.Front)
                m_MaterialEditor.ShaderProperty(_BackColor, "背面颜色");
            
            m_MaterialEditor.ShaderProperty(_BaseMapUVSource, "使用2U");
            m_MaterialEditor.Popup(_BaseMapAlphaChannel, "Alpha通道", Styles.alphaSourceNames);
            m_MaterialEditor.ShaderProperty(_BaseMap, "主贴图");
            
            EditorGUILayout.Space();
            if (_UseParticleCustomData.floatValue != 0)
                m_MaterialEditor.ShaderProperty(_BaseMapUVAniSource, "使用粒子发射器数据");
            if (_UseParticleCustomData.floatValue != 0 && _BaseMapUVAniSource.floatValue != 0)
            {
                EditorGUILayout.LabelField("UV动画 : 使用粒子发射器 CustomData2.XY");
            }
            else
            {
                _MainUVAni.vectorValue =
                    EditorGUILayout.Vector2Field("UV动画",
                        new Vector2(_MainUVAni.vectorValue.x, _MainUVAni.vectorValue.y));
            }

            _BaseMapAlphaMask.vectorValue = GetAlphaSourceMask((int)_BaseMapAlphaChannel.floatValue);
        }

        void SubMapArea(Material material)
        {
            m_MaterialEditor.ShaderProperty(_UseSubTexture, "开关");
            if ((CullMode)_CullMode.floatValue != CullMode.Back)
                m_MaterialEditor.ColorProperty(_SubColor, "颜色");
            if ((CullMode)_CullMode.floatValue != CullMode.Front)
                m_MaterialEditor.ShaderProperty(_BackSubColor, "背面颜色");
            
            m_MaterialEditor.ShaderProperty(_SubMapUVSource, "使用2U");
            m_MaterialEditor.Popup(_SubMapAlphaChannel, "Alpha通道", Styles.alphaSourceNames);
            m_MaterialEditor.ShaderProperty(_SubMap, "副贴图");
            
            _SubUVAni.vectorValue =
                EditorGUILayout.Vector2Field("UV动画",
                    new Vector2(_SubUVAni.vectorValue.x, _SubUVAni.vectorValue.y));
            m_MaterialEditor.Popup(_TextureBlendMode, Styles.textureBlendMode, Styles.textureBlendNames);
            
            _SubMapAlphaMask.vectorValue = GetAlphaSourceMask((int)_SubMapAlphaChannel.floatValue);
        }

        void DistortArea(Material material)
        {
            m_MaterialEditor.ShaderProperty(_UseDistort, "开关");
            if (_UseParticleCustomData.floatValue == 0)
                m_MaterialEditor.ShaderProperty(_Distort0Factor, "扰乱强度");
            else
                EditorGUILayout.LabelField("扰乱强度 : 使用粒子发射器 CustomData1.Z");

            m_MaterialEditor.ShaderProperty(_DistortMap0UVSource, "使用2U");
            m_MaterialEditor.ShaderProperty(_DistortMap0, "扰乱贴图1");
            Vector2 m_Distort0Ani = EditorGUILayout.Vector2Field("UV动画",
                new Vector2(_DistortUVAni.vectorValue.x, _DistortUVAni.vectorValue.y));

            EditorGUILayout.Space();
            Vector2 m_Distort1Ani = Vector2.zero;
            m_MaterialEditor.ShaderProperty(_UseDistort1, "双贴图扰乱");
            if (_UseDistort1.floatValue != 0)
            {
                EditorGUILayout.Space();
                if (_UseParticleCustomData.floatValue == 0)
                    m_MaterialEditor.ShaderProperty(_Distort1Factor, "扰乱强度");
                else
                    EditorGUILayout.LabelField("扰乱强度 : 使用粒子发射器 CustomData1.W");
                
                m_MaterialEditor.ShaderProperty(_DistortMap1UVSource, "使用2U");
                m_MaterialEditor.ShaderProperty(_DistortMap1, "扰乱贴图2");
                m_Distort1Ani = EditorGUILayout.Vector2Field("UV动画",
                    new Vector2(_DistortUVAni.vectorValue.z, _DistortUVAni.vectorValue.w));
            }

            _DistortUVAni.vectorValue = new Vector4(m_Distort0Ani.x, m_Distort0Ani.y, m_Distort1Ani.x, m_Distort1Ani.y);
        }

        void DissolveArea(Material material)
        {
            m_MaterialEditor.ShaderProperty(_UseDissolve, "开关");
            //m_MaterialEditor.Popup(_DissolveEdgeMode, Styles.dissolveEdgeMode, Styles.dissolveEdgeNames);
            
            m_MaterialEditor.ShaderProperty(_DissolveMapUVSource, "使用2U");
            m_MaterialEditor.ShaderProperty(_DissolveMap, "贴图");

            Vector2 m_DissolveAni = EditorGUILayout.Vector2Field("UV动画",
                new Vector2(_DissolveAni.vectorValue.x, _DissolveAni.vectorValue.y));
            _DissolveAni.vectorValue = new Vector4(m_DissolveAni.x, m_DissolveAni.y, 0, 0);

            EditorGUILayout.Space();
            if (_UseParticleCustomData.floatValue == 0)
            {
                m_MaterialEditor.ShaderProperty(_DissolveFactor, "溶解强度");
                m_MaterialEditor.ShaderProperty(_DissolveSoft, "溶解硬度");
                
                EditorGUILayout.Space();
                m_MaterialEditor.ShaderProperty(_DissolveEdge, "亮边宽度");
            }
            else
            {
                EditorGUILayout.LabelField("溶解强度 : 使用粒子发射器 CustomData1.X");
                m_MaterialEditor.ShaderProperty(_DissolveSoft, "溶解硬度");
                
                EditorGUILayout.Space();
                EditorGUILayout.LabelField("亮边宽度 : 使用粒子发射器 CustomData1.Y");
            }
            m_MaterialEditor.ShaderProperty(_DissolveEdgeSoft, "亮边硬度");
            m_MaterialEditor.ShaderProperty(_DissolveEdgeColor, "亮边颜色");
            

            _DissolveParam.vectorValue =
                new Vector4(_DissolveFactor.floatValue, _DissolveEdge.floatValue, _DissolveSoft.floatValue,
                    _DissolveEdgeSoft.floatValue);
        }

        void MaskArea(Material material)
        {
            m_MaterialEditor.ShaderProperty(_UseMask, "开关");
            m_MaterialEditor.ShaderProperty(_MaskMapUVSource, "使用2U");
            m_MaterialEditor.ShaderProperty(_MaskMap, "贴图");
            m_MaterialEditor.ShaderProperty(_MaskRotationAngle, "遮罩旋转角度");
            m_MaterialEditor.ShaderProperty(_MaskApplyDistort, "遮罩受扰乱影响");
            m_MaterialEditor.ShaderProperty(_MaskAffectAlpha, "遮罩影响Alpha");
            m_MaterialEditor.ShaderProperty(_MaskAffectDissolve, "遮罩影响溶解");
            m_MaterialEditor.ShaderProperty(_MaskAffectDisplacement, "遮罩影响置换");
            _MaskMapParam.vectorValue = new Vector4(
                _MaskAffectAlpha.floatValue, _MaskAffectDissolve.floatValue, _MaskAffectDisplacement.floatValue
            );
        }

        void RimArea(Material material)
        {
            m_MaterialEditor.ShaderProperty(_UseRim, "开关");
            m_MaterialEditor.ShaderProperty(_RimInverse, "反向边缘光");
            m_MaterialEditor.Popup(_RimColorBlendMode, Styles.rimColorBlendMode, Styles.rimBlendNames);
            m_MaterialEditor.Popup(_RimAlphaBlendMode, Styles.rimAlphaBlendMode, Styles.rimAlphaBlendNames);
            //m_MaterialEditor.Popup(_RimAlphaSource, Styles.rimAlphaSource, Styles.rimAlphaSourceNames);

            m_MaterialEditor.ShaderProperty(_rimColor, "颜色");
            m_MaterialEditor.ShaderProperty(_rimPower, "宽度");
            m_MaterialEditor.ShaderProperty(_rimEdge, "硬度");
            
            _RimParam0.vectorValue = new Vector4(
                0, _RimInverse.floatValue, _rimPower.floatValue, _rimEdge.floatValue);

            float alphaBlend = (int)_RimAlphaBlendMode.floatValue == 2 ? -1 : _RimAlphaBlendMode.floatValue;
            _RimParam1.vectorValue = new Vector4(
                _RimColorBlendMode.floatValue, alphaBlend);
        }
        
        void EdgeContactArea(Material material)
        {
            m_MaterialEditor.ShaderProperty(_UseEdgeContact, "开关");
            m_MaterialEditor.Popup(_EdgeContactMode, "接触效果", Styles.edgeContactModeNames);
            m_MaterialEditor.ShaderProperty(_EdgeContactFade, "接触衰减");
            _EdgeContactFade.floatValue = Mathf.Max(0, _EdgeContactFade.floatValue);
            
            if(_EdgeContactMode.floatValue != 0)
                m_MaterialEditor.ShaderProperty(_EdgeContactColor, "高亮颜色");

            Color color = _EdgeContactColor.colorValue;
            color.a = _EdgeContactFade.floatValue;
            if (_EdgeContactMode.floatValue != 0)
                color.a = -color.a;
            _EdgeContactColor.colorValue = color;
        }

        void DisplacementMapArea()
        {
            m_MaterialEditor.ShaderProperty(_UseDisplacementMap, "开关");
            
            m_MaterialEditor.ShaderProperty(_DisplacementMapUVSource, "使用2U");
            m_MaterialEditor.ShaderProperty(_DisplacementMap, "置换贴图");
            
            
            if (_UseParticleCustomData.floatValue == 0)
            {
                m_MaterialEditor.ShaderProperty(_DisplacementStrength, "强度");
            }
            else
            {
                EditorGUILayout.LabelField("强度 : 使用粒子发射器 CustomData2.Z");
            }
            
            _DisplacementUVAni.vectorValue = EditorGUILayout.Vector2Field("UV动画",
                new Vector2(_DisplacementUVAni.vectorValue.x, _DisplacementUVAni.vectorValue.y));
            _DisplacementParam.vectorValue = new Vector4(
                _DisplacementUVAni.vectorValue.x, _DisplacementUVAni.vectorValue.y, _DisplacementStrength.floatValue);
        }


        void UpdateKeyword(Material material)
        {
            material.SetKeyword("_SUB_TEXTURE", _UseSubTexture.floatValue != 0 && _SubMap.textureValue != null);

            if (_UseDistort.floatValue != 0)
            {
                material.SetKeyword("_SINGLE_TEX_DISTORT",
                    _DistortMap0.textureValue != null && (_DistortMap1.textureValue == null || _UseDistort1.floatValue == 0));
                material.SetKeyword("_DOUBLE_TEX_DISTORT",
                    _DistortMap0.textureValue != null && _DistortMap1.textureValue != null && _UseDistort1.floatValue != 0);
            }
            else
            {
                material.SetKeyword("_SINGLE_TEX_DISTORT", false);
                material.SetKeyword("_DOUBLE_TEX_DISTORT", false);
            }

            material.SetKeyword("_DISSOLVE", _UseDissolve.floatValue != 0 && _DissolveMap.textureValue != null);
            material.SetKeyword("_MASK", _UseMask.floatValue != 0 && _MaskMap.textureValue != null);
            material.SetKeyword("_RIM", _UseRim.floatValue != 0);
            material.SetKeyword("_USE_FOG", _UseFog.floatValue != 0);
            material.SetKeyword("_EDGE_CONTACT", _UseEdgeContact.floatValue != 0);
            material.SetKeyword("_DISPLACEMENT", _UseDisplacementMap.floatValue != 0 && _DisplacementMap.textureValue != null);
            material.SetKeyword("_APPLY_LIGHTING", _UseLighting.floatValue != 0);
            material.SetKeyword("_TOWARDSCAMERA", _TowardCamera.floatValue != 0);
            material.SetKeyword("_UI_EFFECT", _IsUIEffect.floatValue != 0);
            material.SetKeyword("_RECEIVEFOG",_ReceiveFog.floatValue!=0);
        }

        int UpdatePerformanceLevel(Material material)
        {
            int level = 1;
            
            if (material.IsKeywordEnabled("_SUB_TEXTURE"))
                level += 1;
            
            if (material.IsKeywordEnabled("_RIM"))
                level += 1;
            
            if (material.IsKeywordEnabled("_SINGLE_TEX_DISTORT"))
                level += 3;
            if (material.IsKeywordEnabled("_DOUBLE_TEX_DISTORT"))
                level += 6;
            
            if (material.IsKeywordEnabled("_DISSOLVE"))
                level += 1;
            
            if (material.IsKeywordEnabled("_MASK"))
            {
                level += 1;
                if (_MaskAffectDisplacement.floatValue != 0 && material.IsKeywordEnabled("_DISPLACEMENT"))
                    level += 2;
                if (_MaskApplyDistort.floatValue != 0)
                    level += 2;
            }
            if (material.IsKeywordEnabled("_SOFT_PARTICLE"))
                level += 2;
            if (material.IsKeywordEnabled("_DISPLACEMENT"))
                level += 2;

            return level;
        }

        Vector4 GetAlphaSourceMask(int source)
        {
            Vector4 mask;
            switch (source)
            {
                case 0:
                    mask = new Vector4(1, 0, 0, 0);
                    break;
                case 1:
                    mask = new Vector4(0, 1, 0, 0);
                    break;
                case 2:
                    mask = new Vector4(0, 0, 1, 0);
                    break;
                case 3:
                    mask = new Vector4(0, 0, 0, 1);
                    break;
                default:
                    mask = new Vector4(0, 0, 0, 1);
                    break;
            }

            return mask;
        }
    }
    
    public static class MaterialUtility
    {
        public static void SetKeyword(this Material material, string keyWord, bool toggle)
        {
            if (toggle)
                material.EnableKeyword(keyWord);
            else
                material.DisableKeyword(keyWord);
        }
        
        public static void Popup(this MaterialEditor m_MaterialEditor, MaterialProperty property, string label, string[] names, int indent = 0)
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
    
    class SavedParameter<T> where T : IEquatable<T>
    {
        internal delegate void SetParameter(string key, T value);
        internal delegate T GetParameter(string key, T defaultValue);

        readonly string m_Key;
        bool m_Loaded;
        T m_Value;

        readonly SetParameter m_Setter;
        readonly GetParameter m_Getter;

        public SavedParameter(string key, T value, GetParameter getter, SetParameter setter)
        {
            Assert.IsNotNull(setter);
            Assert.IsNotNull(getter);

            m_Key = key;
            m_Loaded = false;
            m_Value = value;
            m_Setter = setter;
            m_Getter = getter;
        }

        void Load()
        {
            if (m_Loaded)
                return;

            m_Loaded = true;
            m_Value = m_Getter(m_Key, m_Value);
        }

        public T value
        {
            get
            {
                Load();
                return m_Value;
            }
            set
            {
                Load();

                if (m_Value.Equals(value))
                    return;

                m_Value = value;
                m_Setter(m_Key, value);
            }
        }
    }

    // Pre-specialized class for easier use and compatibility with existing code
    sealed class SavedBool : SavedParameter<bool>
    {
        public SavedBool(string key, bool value)
            : base(key, value, EditorPrefs.GetBool, EditorPrefs.SetBool) { }
    }

    sealed class SavedInt : SavedParameter<int>
    {
        public SavedInt(string key, int value)
            : base(key, value, EditorPrefs.GetInt, EditorPrefs.SetInt) { }
    }

    sealed class SavedFloat : SavedParameter<float>
    {
        public SavedFloat(string key, float value)
            : base(key, value, EditorPrefs.GetFloat, EditorPrefs.SetFloat) { }
    }

    sealed class SavedString : SavedParameter<string>
    {
        public SavedString(string key, string value)
            : base(key, value, EditorPrefs.GetString, EditorPrefs.SetString) { }
    }
}