using System;
using UnityEditor;
using UnityEngine;

namespace BArtLib
{
    public class LowPolySceneCommonGUI : ShaderGUI
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
            Front,
            Double,
        }
        
        public enum StencilMode
        {
            Obj,
            Mountain,
            Scene,
            Buliding,
        }

        public enum ChickMode { Chick, Unchick };

        private static class Styles
        {          
            public static string blendMode = "混合模式";
            public static string cullingMode = "裁剪模式";
            public static string stencilMode = "蒙版模式";
            public static readonly string[] blendNames = { "不透明", "透贴", "半透明", "预乘Alpha半透明" };
            public static readonly string[] cullNames = { "正面显示", "背面显示", "双面显示" };
            public static readonly string[] stencilNames = { "地表", "山", "场景物件" ,"建筑物" };
            public static GUIContent baseMapText = new GUIContent ("颜色贴图");
            public static GUIContent matcapMapText = new GUIContent("Mat贴图");
            public static GUIContent maskMapText = new GUIContent("Mat遮罩");
            public static GUIContent addtionMapText = new GUIContent("雪遮罩");
            public static GUIContent emsMapText = new GUIContent ("(R)自发光");
            public static GUIContent lightmapText = new GUIContent ("(RGB)lightmap (A)AO"); 
            public static GUIContent skyText = new GUIContent ("天空映射");
        }

        MaterialProperty blendMode = null;
        MaterialProperty cullMode = null;
        MaterialProperty stencilMode = null;
        MaterialProperty mainColor = null;
        MaterialProperty addtionColor = null;
        MaterialProperty MatToggle = null;
        MaterialProperty matcapMap = null;
        MaterialProperty maskMap = null;
        MaterialProperty matStrength = null;
        MaterialProperty mixLerp = null;
         
        
        MaterialProperty EmiToggle = null;
        MaterialProperty emiColor = null;
        
        MaterialProperty baseMap = null;
        MaterialProperty maseMap = null;
        MaterialProperty addtionMap = null;
        MaterialProperty lightMap = null;       
        MaterialProperty cutoutStrength = null;
        MaterialProperty transparentStrength = null;
        MaterialProperty aoStrength = null;
        MaterialProperty addtionStrength = null;
        
        MaterialProperty skyToggle = null;
        MaterialProperty skyMap = null;
        MaterialProperty skyTile = null;
        MaterialProperty skyStrength = null;
        MaterialProperty skyDistort = null;
        MaterialProperty cloudSpeed = null;
        
        MaterialEditor m_MaterialEditor;

        public void FindProperties (MaterialProperty[] props, Material material)
        {
            blendMode = FindProperty ("_BlendMode", props);
            cullMode = FindProperty ("_CullMode", props);
            stencilMode = FindProperty ("_StencilMode", props);
            MatToggle = FindProperty("_MatToggle", props);
            matcapMap = FindProperty("_MatCap", props);
            maskMap = FindProperty("_MaskMap", props);
            mixLerp = FindProperty("_MixLerp", props);
            matStrength = FindProperty("_MatStrength", props);
            

            EmiToggle = FindProperty("_EmiToggle", props);
            emiColor = FindProperty ("_EmiColor", props);
            addtionColor = FindProperty ("_AddtionColor", props);
            
            baseMap = FindProperty ("_MainTex", props);
            maseMap = FindProperty ("_MAESTex", props);
            addtionMap = FindProperty ("_AddtionTex", props);
            lightMap = FindProperty ("_LightMap", props);         
            cutoutStrength = FindProperty ("_Cutoff", props);
            aoStrength = FindProperty ("_AOStrength", props);
            addtionStrength = FindProperty ("_AddtionStrength", props);
            transparentStrength = FindProperty ("_Transparent", props);
            
            skyToggle = FindProperty ("_SkyToggle", props);
            skyMap = FindProperty ("_SkyTex", props);
            skyTile = FindProperty ("_SkyTile", props);
            skyDistort = FindProperty ("_SkyDistort", props);
            skyStrength = FindProperty ("_SkyStrength", props);
            cloudSpeed = FindProperty ("_CloudSpeed", props);
        }

        public override void OnGUI (MaterialEditor materialEditor, MaterialProperty[] props)
        {
            Material material = materialEditor.target as Material;
            FindProperties (props, material);
            m_MaterialEditor = materialEditor;

            MaterialChanged (material);
            ShaderPropertiesGUI (material);

            EditorGUILayout.Space();
            m_MaterialEditor.RenderQueueField();
            m_MaterialEditor.EnableInstancingField();
            m_MaterialEditor.DoubleSidedGIField();
        }

        static void MaterialChanged (Material material)
        {
            SetupMaterialWithBlendMode (material, (BlendMode) material.GetFloat ("_BlendMode"));
            SetupMaterialWithCullMode (material, (CullMode) material.GetFloat ("_CullMode"));
            SetupMaterialWithStencilMode(material, (StencilMode) material.GetFloat ("_StencilMode"));
        }

        public static void SetupMaterialWithBlendMode (Material material, BlendMode blendMode)
        {
            switch (blendMode)
            {
                case BlendMode.Opaque:
                    material.SetOverrideTag ("RenderType", "Opaque");
                    material.DisableKeyword ("ENABLE_ALPHATEST");
                    material.DisableKeyword ("ENABLE_PREMULTI");
                    material.SetInt ("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.One);
                    material.SetInt ("_DstBlend", (int) UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt ("_ZWrite", 1);
                    material.SetFloat ("_Transparent", 1);
                    material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.Geometry;
                    break;
                case BlendMode.Cutout:
                    material.SetOverrideTag ("RenderType", "TransparentCutout");
                    material.EnableKeyword ("ENABLE_ALPHATEST");
                    material.DisableKeyword ("ENABLE_PREMULTI");
                    material.SetInt ("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.One);
                    material.SetInt ("_DstBlend", (int) UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt ("_ZWrite", 1);
                    material.SetFloat ("_Transparent", 1);
                    material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
                case BlendMode.Transparent:
                    material.SetOverrideTag ("RenderType", "Transparent");
                    material.DisableKeyword ("ENABLE_ALPHATEST");
                    material.DisableKeyword ("ENABLE_PREMULTI");
                    material.SetInt ("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt ("_DstBlend", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    material.SetInt ("_ZWrite", 0);
                    material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
                case BlendMode.PreMultiply:
                    material.SetOverrideTag ("RenderType", "Transparent");
                    material.DisableKeyword ("ENABLE_ALPHATEST");
                    material.EnableKeyword ("ENABLE_PREMULTI");
                    material.SetInt ("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.One);
                    material.SetInt ("_DstBlend", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    material.SetInt ("_ZWrite", 0);
                    material.renderQueue = (int) UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
            }
        }

        public static void SetupMaterialWithCullMode (Material material, CullMode cullMode)
        {
            switch (cullMode)
            {
                case CullMode.Back:
                    material.SetInt ("_Cull", (int) UnityEngine.Rendering.CullMode.Back);
                    break;
                case CullMode.Front:
                    material.SetInt ("_Cull", (int) UnityEngine.Rendering.CullMode.Front);
                    break;
                case CullMode.Double:
                    material.SetInt ("_Cull", (int) UnityEngine.Rendering.CullMode.Off);
                    break;
            }
        }
        public static void SetupMaterialWithStencilMode (Material material, StencilMode stencilMode)
        {
            switch (stencilMode)
            {
                case StencilMode.Obj:
                    material.SetInt ("_StencilMode", (int) StencilMode.Obj);
                    break;
                case StencilMode.Mountain:
                    material.SetInt ("_StencilMode", (int) StencilMode.Mountain);
                    break;
                case StencilMode.Scene:
                    material.SetInt ("_StencilMode", (int) StencilMode.Scene);
                    break;
                case StencilMode.Buliding:
                    material.SetInt ("_StencilMode", (int) StencilMode.Buliding);
                    break;
                
            }
        }
        

        public void ShaderPropertiesGUI (Material material)
        {
            SceneShaderGUI (material);

            //EditorGUILayout.Space();
            //m_MaterialEditor.RenderQueueField();
            //m_MaterialEditor.EnableInstancingField();
            //m_MaterialEditor.DoubleSidedGIField();
        }

        void SceneShaderGUI (Material material)
        {
            BlendModePopup ();
            //mainColor.colorValue = new Color (mainColor.colorValue.r, mainColor.colorValue.g, mainColor.colorValue.b, 1);
            if ((BlendMode) blendMode.floatValue == BlendMode.Cutout)
            {
                m_MaterialEditor.ShaderProperty (cutoutStrength, "透贴强度", MaterialEditor.kMiniTextureFieldLabelIndentLevel);
            }
            else if ((BlendMode) blendMode.floatValue == BlendMode.Transparent ||
                (BlendMode) blendMode.floatValue == BlendMode.PreMultiply)
            {
                m_MaterialEditor.ShaderProperty (transparentStrength, "透明度", MaterialEditor.kMiniTextureFieldLabelIndentLevel);
            }

            CullModePopup ();
            StencilModePopup();
            EditorGUILayout.Space ();
            m_MaterialEditor.TexturePropertySingleLine (Styles.baseMapText, baseMap, mainColor);           
            m_MaterialEditor.TextureScaleOffsetProperty (baseMap);
           

            EditorGUILayout.Space();
            m_MaterialEditor.TexturePropertySingleLine (Styles.lightmapText, lightMap);
            //m_MaterialEditor.ShaderProperty(lightMapStrength, "光照图强度");
            m_MaterialEditor.ShaderProperty(aoStrength, "AO强度");
            
            EditorGUILayout.Space();
            m_MaterialEditor.TexturePropertySingleLine(Styles.addtionMapText, addtionMap);
            if (addtionMap.textureValue != null)
            {
                m_MaterialEditor.ShaderProperty(addtionColor, "雪颜色");
                m_MaterialEditor.ShaderProperty(addtionStrength, "雪强度");
            }
            
            EditorGUILayout.Space ();          
            m_MaterialEditor.ShaderProperty(EmiToggle, "自发光常亮");
            m_MaterialEditor.TexturePropertySingleLine(Styles.emsMapText, maseMap);
            m_MaterialEditor.ShaderProperty(emiColor, "自发光颜色");

            EditorGUILayout.Space();
            m_MaterialEditor.ShaderProperty(MatToggle, "MatCap开关");
            if (MatToggle.floatValue != 0)
            {                
                m_MaterialEditor.TexturePropertySingleLine(Styles.maskMapText, maskMap);
                m_MaterialEditor.TexturePropertySingleLine(Styles.matcapMapText, matcapMap);
                m_MaterialEditor.ShaderProperty(matStrength, "Mat强度");
                m_MaterialEditor.ShaderProperty(mixLerp, "Mat混合");
            }
            
            EditorGUILayout.Space();
            m_MaterialEditor.ShaderProperty(skyToggle, "SkyMap开关");
            if (skyToggle.floatValue != 0)
            {                
                m_MaterialEditor.TexturePropertySingleLine(Styles.skyText, skyMap);
                m_MaterialEditor.ShaderProperty(skyStrength, "Sky强度");
                m_MaterialEditor.ShaderProperty(skyTile, "Sky平铺");
                m_MaterialEditor.ShaderProperty(skyDistort, "Sky偏移");
                m_MaterialEditor.ShaderProperty(cloudSpeed, "sky移动");
            }
            
          
            
            //m_MaterialEditor.ShaderProperty (aoStrength, "AO强度");

        }

        void BlendModePopup ()
        {
            EditorGUI.showMixedValue = blendMode.hasMixedValue;
            var mode = (BlendMode) blendMode.floatValue;

            EditorGUI.BeginChangeCheck ();
            mode = (BlendMode) EditorGUILayout.Popup (Styles.blendMode, (int) mode, Styles.blendNames);

            if (EditorGUI.EndChangeCheck ())
            {
                m_MaterialEditor.RegisterPropertyChangeUndo ("Rendering Mode");
                blendMode.floatValue = (float) mode;
            }

            EditorGUI.showMixedValue = false;
        }
        void CullModePopup ()
        {
            EditorGUI.showMixedValue = cullMode.hasMixedValue;
            var mode = (CullMode) cullMode.floatValue;

            EditorGUI.BeginChangeCheck ();
            mode = (CullMode) EditorGUILayout.Popup (Styles.cullingMode, (int) mode, Styles.cullNames);

            if (EditorGUI.EndChangeCheck ())
            {
                m_MaterialEditor.RegisterPropertyChangeUndo ("Culling Mode");
                cullMode.floatValue = (float) mode;
            }

            EditorGUI.showMixedValue = false;
        }
        void StencilModePopup ()
        {
            EditorGUI.showMixedValue = stencilMode.hasMixedValue;
            var mode = (StencilMode) stencilMode.floatValue;

            EditorGUI.BeginChangeCheck ();
            mode = (StencilMode) EditorGUILayout.Popup (Styles.stencilMode, (int) mode, Styles.stencilNames);

            if (EditorGUI.EndChangeCheck ())
            {
                m_MaterialEditor.RegisterPropertyChangeUndo ("stencil Mode");
                stencilMode.floatValue = (float) mode;
            }

            EditorGUI.showMixedValue = false;
        }
        

    }
}