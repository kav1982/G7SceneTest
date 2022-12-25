using UnityEditor;
using UnityEngine;

public class StylizedWaterGUI : ShaderGUI
{
    public enum WorldSpaceUVType
    {
        MeshUV,
        WorldSpaceUV,
    }

    MaterialProperty _WaterColor; MaterialProperty _WaterColorNear; MaterialProperty _WaterColorFar;
    MaterialProperty _AnimationParams; MaterialProperty _WorldSpaceUV;
    MaterialProperty _WorldScale; MaterialProperty _FresnelPower;
    MaterialProperty _DepthVertical; MaterialProperty _DepthHorizontal;
    MaterialProperty _DepthExp; MaterialProperty _EdgeFade;
    MaterialProperty _EdgeFoamToggle; MaterialProperty _EdgeFoamTexture;
    MaterialProperty _EdgeFoamTiling; MaterialProperty _EdgeFoamBlend;
    MaterialProperty _EdgeFoamVisibility; MaterialProperty _EdgeFoamIntensity;
    MaterialProperty _EdgeFoamContrast; MaterialProperty _EdgeFoamColor;
    MaterialProperty _EdgeFoamSpeed; MaterialProperty _RiverToggle;
    MaterialProperty _waveEdgeLength; MaterialProperty _waveFalloff;
    //MaterialProperty _waveEdgeVector; MaterialProperty _WaveToggle;
    MaterialProperty _MaskFlow; MaterialProperty _IntersectionSource;
    MaterialProperty _IntersectionNoise; MaterialProperty _IntersectionColor;
    MaterialProperty _IntersectionFalloff; MaterialProperty _IntersectionRippleStrength;
    MaterialProperty _IntersectionTiling; MaterialProperty _IntersectionSpeed;
    MaterialProperty _IntersectionRippleDist; MaterialProperty _CausticsOn;
    MaterialProperty _CausticsTex; MaterialProperty _CausticsBrightness;
    MaterialProperty _CausticsTiling; MaterialProperty _CausticsSpeed;
    MaterialProperty _CausticsDistortion; MaterialProperty _FoamOn;
    MaterialProperty _FoamTex; MaterialProperty _FoamColor;
    MaterialProperty _FoamSize; MaterialProperty _FoamSpeed;
    MaterialProperty _FoamWaveMask; MaterialProperty _FoamWaveMaskExp; MaterialProperty _FoamTiling;

    MaterialProperty _FoamNoiseTex; MaterialProperty _FoamNoiseDistTex; MaterialProperty _FoamNoiseMix;
    MaterialProperty _FoamNoiseDistortion; MaterialProperty _FoamNoiseSpeed; MaterialProperty _CHPFoamWidth;
    MaterialProperty _CHPFoamNum; MaterialProperty _CHPFoamSpeed; MaterialProperty _CHPFoamStart;
    MaterialProperty _CHPFoamAtten; MaterialProperty _CHPFoamCol; MaterialProperty _CHPFoamParam1;
    MaterialProperty _CHPFoamParam2; MaterialProperty _CHPFoamToggle;

    MaterialEditor m_MaterialEditor;


    public void FindProperties(MaterialProperty[] props)
    {
        _WaterColor = FindProperty("_WaterColor", props); _WaterColorNear = FindProperty("_WaterColorNear", props); _WaterColorFar = FindProperty("_WaterColorFar", props);
        _AnimationParams = FindProperty("_AnimationParams", props); _WorldSpaceUV = FindProperty("_WorldSpaceUV", props);
        _WorldScale = FindProperty("_WorldScale", props); _FresnelPower = FindProperty("_FresnelPower", props);
        _DepthVertical = FindProperty("_DepthVertical", props); _DepthHorizontal = FindProperty("_DepthHorizontal", props);
        _DepthExp = FindProperty("_DepthExp", props); _EdgeFade = FindProperty("_EdgeFade", props);
        _EdgeFoamToggle = FindProperty("_EdgeFoamToggle", props); _EdgeFoamTexture = FindProperty("_EdgeFoamTexture", props);
        _EdgeFoamTiling = FindProperty("_EdgeFoamTiling", props); _EdgeFoamBlend = FindProperty("_EdgeFoamBlend", props);
        _EdgeFoamVisibility = FindProperty("_EdgeFoamVisibility", props); _EdgeFoamIntensity = FindProperty("_EdgeFoamIntensity", props);
        _EdgeFoamContrast = FindProperty("_EdgeFoamContrast", props); _EdgeFoamColor = FindProperty("_EdgeFoamColor", props);
        _EdgeFoamSpeed = FindProperty("_EdgeFoamSpeed", props); _RiverToggle = FindProperty("_RiverToggle", props);
        _waveEdgeLength = FindProperty("_waveEdgeLength", props); _waveFalloff = FindProperty("_waveFalloff", props);
        //_waveEdgeVector = FindProperty("_waveEdgeVector", props); _WaveToggle = FindProperty("_WaveToggle", props);
        _MaskFlow = FindProperty("_MaskFlow", props); _IntersectionSource = FindProperty("_IntersectionSource", props); 
        _IntersectionNoise = FindProperty("_IntersectionNoise", props); _IntersectionColor = FindProperty("_IntersectionColor", props);
        _IntersectionFalloff = FindProperty("_IntersectionFalloff", props); _IntersectionRippleStrength = FindProperty("_IntersectionRippleStrength", props);
        _IntersectionTiling = FindProperty("_IntersectionTiling", props); _IntersectionSpeed = FindProperty("_IntersectionSpeed", props);
        _IntersectionRippleDist = FindProperty("_IntersectionRippleDist", props); _CausticsOn = FindProperty("_CausticsOn", props);
        _CausticsTex = FindProperty("_CausticsTex", props); _CausticsBrightness = FindProperty("_CausticsBrightness", props);
        _CausticsTiling = FindProperty("_CausticsTiling", props); _CausticsSpeed = FindProperty("_CausticsSpeed", props);
        _CausticsDistortion = FindProperty("_CausticsDistortion", props); _FoamOn = FindProperty("_FoamOn", props);
        _FoamTex = FindProperty("_FoamTex", props); _FoamColor = FindProperty("_FoamColor", props);
        _FoamSize = FindProperty("_FoamSize", props); _FoamSpeed = FindProperty("_FoamSpeed", props);
        _FoamWaveMask = FindProperty("_FoamWaveMask", props); _FoamWaveMaskExp = FindProperty("_FoamWaveMaskExp", props);
        _FoamTiling = FindProperty("_FoamTiling", props);

        _FoamNoiseTex = FindProperty("_FoamNoiseTex", props); _FoamNoiseDistTex = FindProperty("_FoamNoiseDistTex", props);
        _FoamNoiseMix = FindProperty("_FoamNoiseMix", props); _FoamNoiseDistortion = FindProperty("_FoamNoiseDistortion", props);
        _FoamNoiseSpeed = FindProperty("_FoamNoiseSpeed", props); _CHPFoamWidth = FindProperty("_CHPFoamWidth", props);
        _CHPFoamNum = FindProperty("_CHPFoamNum", props); _CHPFoamSpeed = FindProperty("_CHPFoamSpeed", props);
        _CHPFoamStart = FindProperty("_CHPFoamStart", props); _CHPFoamAtten = FindProperty("_CHPFoamAtten", props);
        _CHPFoamCol = FindProperty("_CHPFoamCol", props); _CHPFoamParam1 = FindProperty("_CHPFoamParam1", props);
        _CHPFoamParam2 = FindProperty("_CHPFoamParam2", props); _CHPFoamToggle = FindProperty("_CHPFoamToggle", props); 

    }

    private static class Styles
    {
        public static readonly string[] WorldSpaceUVType = { "UV坐标", "世界空间XZ"};
        public static GUIContent EdgeFoamTextureText = new GUIContent("泡沫贴图");
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;
        FindProperties(properties);

        material.doubleSidedGI = true;
        ShaderPropertiesGUI(material);
    }


    public void ShaderPropertiesGUI(Material material)
    {
        EditorGUILayout.Space(10);
        m_MaterialEditor.ShaderProperty(_WaterColor, "水颜色");
        m_MaterialEditor.ShaderProperty(_WaterColorNear, "浅水区颜色");
        m_MaterialEditor.ShaderProperty(_WaterColorFar, "深水区颜色");
        m_MaterialEditor.ShaderProperty(_AnimationParams, "XY = Direction, Z = Speed, W = fallOff");
        _WorldSpaceUV.floatValue = (float)EditorGUILayout.Popup("UV坐标来源", (int)_WorldSpaceUV.floatValue, Styles.WorldSpaceUVType);
        m_MaterialEditor.ShaderProperty(_WorldScale, "场景缩放");
        m_MaterialEditor.ShaderProperty(_FresnelPower, "菲涅尔强度");
        m_MaterialEditor.ShaderProperty(_DepthVertical, "横向深度");
        m_MaterialEditor.ShaderProperty(_DepthHorizontal, "纵向深度");
        m_MaterialEditor.ShaderProperty(_DepthExp, "渐变指数");
        m_MaterialEditor.ShaderProperty(_EdgeFade, "边缘透明范围");

        m_MaterialEditor.ShaderProperty(_EdgeFoamToggle, "开启泡沫");
        if(_EdgeFoamToggle.floatValue != 0)
        {
            //m_MaterialEditor.TexturePropertySingleLine(Styles.EdgeFoamTextureText, _EdgeFoamTexture,_EdgeFoamTiling);
            m_MaterialEditor.ShaderProperty(_EdgeFoamTexture, "EdgeFoam Texture");
            m_MaterialEditor.ShaderProperty(_EdgeFoamTiling, "EdgeFoam Tiling");
            m_MaterialEditor.ShaderProperty(_EdgeFoamBlend, "EdgeFoam Blend");
            m_MaterialEditor.ShaderProperty(_EdgeFoamVisibility, "EdgeFoam Visibility");
            m_MaterialEditor.ShaderProperty(_EdgeFoamIntensity, "EdgeFoam Intensity");
            m_MaterialEditor.ShaderProperty(_EdgeFoamContrast, "EdgeFoam Contrast");
            m_MaterialEditor.ShaderProperty(_EdgeFoamColor, "EdgeFoam Color");
            m_MaterialEditor.ShaderProperty(_EdgeFoamSpeed, "EdgeFoam Speed");
        }
        EditorGUILayout.Space(20);
        m_MaterialEditor.ShaderProperty(_MaskFlow, "X = 亮度 Y = 阈值 Z = 缩放 W = 平移");
        AddDebugToggle("_DEBUGRIVERMASK", "Mask Debug");
        EditorGUILayout.Space(20);
        m_MaterialEditor.ShaderProperty(_RiverToggle, "开启湖面模式");
        if(_RiverToggle.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_waveEdgeLength, "边缘海浪距离");
            m_MaterialEditor.ShaderProperty(_waveFalloff, "WaveFalloff");
            m_MaterialEditor.ShaderProperty(_IntersectionSource, "Intersection source");
            m_MaterialEditor.ShaderProperty(_IntersectionNoise, "噪声贴图");
            m_MaterialEditor.ShaderProperty(_IntersectionTiling, "Noise Tiling");
            m_MaterialEditor.ShaderProperty(_IntersectionColor, "Color");
            m_MaterialEditor.ShaderProperty(_IntersectionFalloff, "Falloff");
            m_MaterialEditor.ShaderProperty(_IntersectionRippleStrength, "Ripple Strength");
            m_MaterialEditor.ShaderProperty(_IntersectionSpeed, "Speed multiplier");
            m_MaterialEditor.ShaderProperty(_IntersectionRippleDist, "Ripple distance");
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.Space(20);
        m_MaterialEditor.ShaderProperty(_CHPFoamToggle, "开启国画边缘");
        if (_CHPFoamToggle.floatValue != 0)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(_FoamNoiseTex, "粗细混合噪声");
            m_MaterialEditor.ShaderProperty(_FoamNoiseDistTex, "边缘扰动噪声");
            m_MaterialEditor.ShaderProperty(_FoamNoiseMix, "粗细混合");
            m_MaterialEditor.ShaderProperty(_FoamNoiseDistortion, "边缘扰动");
            m_MaterialEditor.ShaderProperty(_FoamNoiseSpeed, "噪声速度");
            m_MaterialEditor.ShaderProperty(_CHPFoamWidth, "边缘宽度");
            m_MaterialEditor.ShaderProperty(_CHPFoamNum, "边缘数量");
            m_MaterialEditor.ShaderProperty(_CHPFoamSpeed, "边缘移动速度");
            m_MaterialEditor.ShaderProperty(_CHPFoamStart, "边缘开始位置");
            m_MaterialEditor.ShaderProperty(_CHPFoamAtten, "边缘结束位置");
            m_MaterialEditor.ShaderProperty(_CHPFoamCol, "边缘颜色");
            EditorGUI.indentLevel--;
            _CHPFoamParam1.vectorValue = new Vector4(_FoamNoiseMix.floatValue, _FoamNoiseDistortion.floatValue,
                _FoamNoiseSpeed.floatValue, _CHPFoamWidth.floatValue);
            _CHPFoamParam2.vectorValue = new Vector4(_CHPFoamNum.floatValue, _CHPFoamSpeed.floatValue,
                _CHPFoamStart.floatValue, _CHPFoamAtten.floatValue);
        }
        EditorGUILayout.Space(10);
        material.SetKeyword("_CHPFOAM", _CHPFoamToggle.floatValue != 0);
        m_MaterialEditor.ShaderProperty(_CausticsOn, "Caustics ON");
        if(_CausticsOn.floatValue != 0)
        {
            m_MaterialEditor.ShaderProperty(_DepthVertical, "Vertical Depth");
            m_MaterialEditor.ShaderProperty(_DepthHorizontal, "Horizontal Depth");
            m_MaterialEditor.ShaderProperty(_DepthExp, "Caustics Mask");
            m_MaterialEditor.ShaderProperty(_CausticsTex, "Exponential Blend");
            m_MaterialEditor.ShaderProperty(_CausticsBrightness, "Brightness");
            m_MaterialEditor.ShaderProperty(_CausticsTiling, "Tiling");
            m_MaterialEditor.ShaderProperty(_CausticsSpeed, "Speed multiplier");
            m_MaterialEditor.ShaderProperty(_CausticsDistortion, "Distortion");
        }
        m_MaterialEditor.ShaderProperty(_FoamOn, "Foam ON");
        if(_FoamOn.floatValue != 0)
        {
            m_MaterialEditor.ShaderProperty(_FoamTex, "Foam Mask");
            m_MaterialEditor.ShaderProperty(_FoamTiling, "Tiling");
            m_MaterialEditor.ShaderProperty(_FoamColor, "Foam Color");
            m_MaterialEditor.ShaderProperty(_FoamSize, "Cutoff");
            m_MaterialEditor.ShaderProperty(_FoamSpeed, "Speed multiplier");
            m_MaterialEditor.ShaderProperty(_FoamWaveMask, "Wave mask");
            m_MaterialEditor.ShaderProperty(_FoamWaveMaskExp, "Wave mask exponent");
        }

        void AddDebugToggle(string KeyWord,string toggleName)
        {
            GUIStyle debugToggleStyle = new GUIStyle(GUI.skin.toggle);
            debugToggleStyle.fontSize = 15;
            GUI.color = Color.red;
            bool riverMASKDebug = GUILayout.Toggle(material.IsKeywordEnabled(KeyWord), toggleName, debugToggleStyle);
            material.SetKeyword(KeyWord, riverMASKDebug);
            GUI.color = Color.white;
            EditorGUILayout.Space(10);
        }
    }

}
