using System;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteAlways]
public class PerObjectCaustic : MonoBehaviour
{
    [SerializeField] private Texture2D m_CausticTexture;
    [SerializeField, ColorUsage(false, true)]private Color m_CausticColor = Color.cyan;
    [SerializeField] private float m_CausticAnimation = 0.05f;
    [SerializeField] private float m_CausticTilling = 0.5f;
    [SerializeField] private float m_CausticDistort = 0.1f;
    [SerializeField] private float m_CausticDistortTilling = 0.7f;
    
    static readonly int CausticParamID = Shader.PropertyToID("_Bioum_CausticParam");
    static readonly int CausticColorID = Shader.PropertyToID("_Bioum_CausticColor");
    static readonly int CausticTextureID = Shader.PropertyToID("_Bioum_CausticTexture");
    
    Vector4 causticParam = Vector4.zero;
    private void UpdateCaustic()
    {
        causticParam.x = m_CausticAnimation;
        causticParam.y = m_CausticDistort;
        causticParam.z = m_CausticTilling;
        causticParam.w = m_CausticDistortTilling;
        
        Shader.SetGlobalVector(CausticParamID, causticParam);
        Shader.SetGlobalColor(CausticColorID, m_CausticColor);
        Shader.SetGlobalTexture(CausticTextureID, m_CausticTexture);
    }

    private void OnEnable()
    {
        Shader.EnableKeyword("_PER_OBJECT_CAUSTIC");
        UpdateCaustic();
    }

    private void OnDisable()
    {
        Shader.DisableKeyword("_PER_OBJECT_CAUSTIC");
    }

#if UNITY_EDITOR
    private void Update()
    {
        UpdateCaustic();
    }
#endif

#if UNITY_EDITOR
    [MenuItem("GameObject/美术工具/焦散", false, 10)]
    static void CreateSelf()
    {
        string name = "SceneConfig";
        GameObject SceneConfigGO = GameObject.Find(name);
        if (!SceneConfigGO)
        {
            SceneConfigGO = new GameObject(name);
            SceneConfigGO.AddComponent<FogEx>();
        }

        var caustic = SceneConfigGO.GetComponent<PerObjectCaustic>() ?? SceneConfigGO.AddComponent<PerObjectCaustic>();
        Selection.activeTransform = SceneConfigGO.transform;
    }

    #region 编辑器界面
    [CustomEditor(typeof(PerObjectCaustic))]
    class FogExEditor : Editor
    {
        static GUIContent m_CausticColor = new GUIContent("颜色");
        static GUIContent m_CausticTexture = new GUIContent("焦散贴图");
        
        static GUIContent m_CausticAnimation = new GUIContent("位移");
        static GUIContent m_CausticTilling = new GUIContent("密度");
        static GUIContent m_CausticDistort = new GUIContent("扭曲");
        static GUIContent m_CausticDistortTilling = new GUIContent("扭曲密度");
        
        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.LabelField("贴图R通道为焦散, G通道为扭曲");
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_CausticTexture"), m_CausticTexture);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_CausticColor"), m_CausticColor);
            
            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_CausticAnimation"), m_CausticAnimation);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_CausticTilling"), m_CausticTilling);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_CausticDistort"), m_CausticDistort);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_CausticDistortTilling"), m_CausticDistortTilling);

            serializedObject.ApplyModifiedProperties();
        }
    }
    #endregion
    
#endif
}
