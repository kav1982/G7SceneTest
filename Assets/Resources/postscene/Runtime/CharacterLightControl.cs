using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[ExecuteAlways]
public class CharacterLightControl : MonoBehaviour
{
    [SerializeField, Range(0, 4)]
    float LightIntensity = 1;

    [SerializeField, Range(0, 4)]
    float EnvironmentIntensity = 1;

    private static readonly int CharacterLightControlID = Shader.PropertyToID("g_CharacterLightControl");

    private void OnEnable()
    {
        SetLightControl();
    }

//#if UNITY_EDITOR
    private void Update()
    {
        SetLightControl();
    }
//#endif

    private Vector4 lightControl = Vector4.one;
    private void SetLightControl()
    {
        lightControl.x = LightIntensity;
        lightControl.y = EnvironmentIntensity;
        Shader.SetGlobalVector(CharacterLightControlID, lightControl);
    }
    
    
    
#if UNITY_EDITOR
    [MenuItem("GameObject/美术工具/角色光照调整", false, 10)]
    static void CreateSelf()
    {
        string name = "SceneConfig";
        GameObject SceneConfigGO = GameObject.Find(name);
        if (!SceneConfigGO)
        {
            SceneConfigGO = new GameObject(name);
            SceneConfigGO.AddComponent<FogEx>();
        }

        CharacterLightControl lightControl = SceneConfigGO.GetComponent<CharacterLightControl>() ?? SceneConfigGO.AddComponent<CharacterLightControl>();
    }

    #region 编辑器界面
    [CustomEditor(typeof(CharacterLightControl))]
    class CharacterLightControlEditor : Editor
    {
        static GUIContent m_LightIntensity = new GUIContent("灯光强度");
        static GUIContent m_EnvironmentIntensity = new GUIContent("环境光强度");
        
        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.PropertyField(serializedObject.FindProperty("LightIntensity"), m_LightIntensity);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("EnvironmentIntensity"), m_EnvironmentIntensity);
            
            serializedObject.ApplyModifiedProperties();
        }
    }
    #endregion
    
#endif
}
