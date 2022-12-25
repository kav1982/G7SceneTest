using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
#endif

namespace SOK.Terrain {

[ExecuteAlways]
public class CustomPigmentMap : MonoBehaviour
{
#if UNITY_EDITOR
    public Shader terrainShaderUnlit;//直接换上最大张数的
    [Header("拖入场景中地形")]
    [Tooltip("拖入场景中地形")]
    public Renderer[] terrains;
    [Header("地表layer层名")]
    [Tooltip("地表layer层名")]
    public LayerMask terrainLayer;
    [Range(1,4)]
    [Header("质量等级")]
    [Tooltip("质量等级")]
    public int mapResolustionLevel = 4;
    Camera pigmentCam;
#endif

    [HideInInspector] [SerializeField] Vector3 terrainsCorner;
    [HideInInspector] [SerializeField] float terrainsWidth;
    [HideInInspector] [SerializeField] float terrainsLength;
    [HideInInspector] [SerializeField] Texture2D pigmentMap;

#if UNITY_EDITOR
    [ContextMenu("generate")]
    void GeneratePigmentMap()
    {
        if(terrains == null)
        {
            Debug.LogError("生成地表颜色图之前，请先拖进导出后的地形（场景中）到CustomPigmentMap脚本！");
            return;
        }

        //正在进行中
        if (pigmentCam!=null)
            return;

        pigmentCam = new GameObject().AddComponent<Camera>();
        pigmentCam.name = "pigment cam";
        pigmentCam.orthographic = true;
        pigmentCam.transform.forward = Vector3.down;
        //pigmentCam.transform.right = Vector3.right;
        pigmentCam.clearFlags = CameraClearFlags.SolidColor;
        pigmentCam.backgroundColor = Color.black;
        pigmentCam.depth = -2;

        Bounds totalBounds = terrains[0].bounds;
        for(int i=1;i<terrains.Length;i++)
        {
            
            totalBounds.Encapsulate(terrains[i].bounds);
        }
       
        pigmentCam.aspect = (totalBounds.extents.x) / totalBounds.extents.z;
        pigmentCam.orthographicSize = totalBounds.extents.z;
        UnityEditor.Undo.RecordObject(this, "save data");
        terrainsLength = totalBounds.size.z;
        terrainsWidth = totalBounds.size.x ;
        terrainsCorner = totalBounds.min;
        Debug.Log(terrainsLength + "  +  " + terrainsWidth + "  +  " + terrainsCorner);
        pigmentCam.transform.position = new Vector3(totalBounds.center.x, totalBounds.center.y + totalBounds.extents.y + 25, totalBounds.center.z);

        pigmentCam.cullingMask = terrainLayer.value;
        RenderTexture rt = new RenderTexture((int)(1024 / mapResolustionLevel * pigmentCam.aspect), 1024 / mapResolustionLevel, 0, RenderTextureFormat.Default);
        RenderTexture.active = rt;
        
        pigmentCam.SetReplacementShader(terrainShaderUnlit, "RenderType");
        pigmentCam.targetTexture = rt;
        pigmentCam.Render();

        EditorUtility.DisplayProgressBar("CustomPigmentMap", "Saving texture...", 0);

        Texture2D temp = new Texture2D(rt.width, rt.height);
        temp.ReadPixels(new Rect(0, 0, temp.width, temp.height),0,0);
        pigmentCam.targetTexture = null;
        RenderTexture.active = null;
        DestroyImmediate(rt);
        byte[] bytes = temp.EncodeToPNG();
        EditorUtility.DisplayProgressBar("CustomPigmentMap", "Saving texture...", 0.75f);
        string savePath = EditorSceneManager.GetActiveScene().path.Replace(".unity", string.Empty) + "_pigmentmap.png";
        Debug.Log("pigmentmap path: " + savePath);
        File.WriteAllBytes(savePath, bytes);
        AssetDatabase.Refresh();
        pigmentMap = new Texture2D(temp.width, temp.height, TextureFormat.RGB24, true);
        pigmentMap = AssetDatabase.LoadAssetAtPath(savePath, typeof(Texture2D)) as Texture2D;

        EditorUtility.ClearProgressBar();
        DestroyImmediate(pigmentCam.gameObject);
        pigmentCam = null;

        UpdateShader();
    }
#endif

    private void OnEnable()
    {
        UpdateShader();
    }

    void UpdateShader()
    {
        if(pigmentMap!=null)
        {
            Shader.SetGlobalVector("_PigmentTrans", new Vector4(terrainsCorner.x, terrainsCorner.z, terrainsWidth, terrainsLength));
            Shader.SetGlobalTexture("_PigmentMap", pigmentMap);
        }
    }

}

}