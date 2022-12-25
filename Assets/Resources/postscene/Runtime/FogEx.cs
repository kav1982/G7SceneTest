using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteAlways]
public class FogEx : MonoBehaviour
{
    [SerializeField] private float m_HeightStart = 0;
    [SerializeField] private float m_DistanceStart = 5;
    [SerializeField, Range(0.0001f, 1)]private float m_DistanceFalloff = 0.2f;
    [SerializeField, Range(0.0001f, 1)]private float m_HeightFalloff = 0.5f;
    [SerializeField, ColorUsage(false, true)]private Color m_FogColor = Color.gray;
    
    static readonly int FogParamID = Shader.PropertyToID("_Bioum_FogParam");
    static readonly int FogColorID = Shader.PropertyToID("_Bioum_FogColor");
    
    Vector4 fogParam = Vector4.zero;
    private void ApplyFog()
    {
        RenderSettings.fog = false;

        fogParam.x = m_DistanceStart;
        fogParam.y = m_HeightStart;
        fogParam.z = Mathf.Pow(m_DistanceFalloff, 4);
        fogParam.w = Mathf.Pow(m_HeightFalloff, 4);
        Shader.SetGlobalVector(FogParamID, fogParam);
        Shader.SetGlobalColor(FogColorID, m_FogColor);
    }
    private void OnValidate()
    {
        if(!Application.isPlaying)
            ApplyFog();
    }

    private void OnEnable()
    {
        Shader.EnableKeyword("_BIOUM_FOG_EX");
        ApplyFog();
    }

    private void OnDisable()
    {
        Shader.DisableKeyword("_BIOUM_FOG_EX");
    }

#if UNITY_EDITOR
    [MenuItem("GameObject/美术工具/自定义雾组件", false, 10)]
    static void CreateSelf()
    {
        string name = "SceneConfig";
        GameObject SceneConfigGO = GameObject.Find(name);
        if (!SceneConfigGO)
        {
            SceneConfigGO = new GameObject(name);
            SceneConfigGO.AddComponent<FogEx>();
        }

        FogEx fog = SceneConfigGO.GetComponent<FogEx>() ?? SceneConfigGO.AddComponent<FogEx>();
    }

    #region 编辑器界面
    [CustomEditor(typeof(FogEx))]
    class FogExEditor : Editor
    {
        static GUIContent m_HeightStart = new GUIContent("起始高度");
        static GUIContent m_DistanceStart = new GUIContent("起始距离");
        static GUIContent m_HeightFalloff = new GUIContent("高度衰减");
        static GUIContent m_DistanceFalloff = new GUIContent("距离衰减");
        static GUIContent m_FogColor = new GUIContent("雾颜色");
        
        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_FogColor"), m_FogColor);
            
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("距离雾参数");
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_DistanceStart"), m_DistanceStart);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_DistanceFalloff"), m_DistanceFalloff);
            
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("高度雾参数");
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_HeightStart"), m_HeightStart);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_HeightFalloff"), m_HeightFalloff);
            
            serializedObject.ApplyModifiedProperties();
        }
    }
    #endregion
    
#endif
}
