using UnityEngine;
using DG.Tweening;
using System.Collections;
using System.Collections.Generic;

public class WindObject : MonoBehaviour
{
    protected class TreeData
    {
        public Renderer renderer;
        public Material material;
        public Vector4 sourceParam;
        public Vector4 windParam;
        float radian, x, y;

        public TreeData(Renderer renderer)
        {
            ReInit(renderer);
            windParam = Vector4.zero;
        }

        public void ReInit(Renderer renderer)
        {
            this.renderer = renderer;
            material = renderer.sharedMaterial;
            sourceParam = material.GetVector(WindParamID);
        }

        public void GetParam(AreaWind arg)
        {
            radian = arg.WindDirection * Mathf.Deg2Rad;
            x = Mathf.Cos(radian) * arg.WindIntensity;
            y = Mathf.Sin(radian) * arg.WindIntensity;
            windParam.x = x;
            windParam.y = y;
            windParam.z = sourceParam.z;
            windParam.w = sourceParam.w;
        }

        public void Clear()
        {
            material = null;
            renderer = null;
        }
    }
    protected static Queue<TreeData> dataCache = new Queue<TreeData>();
    private static TreeData tempTreeData;
    protected static TreeData GetTreeData(Renderer renderer)
    {
        if(dataCache.Count > 0)
        {
            tempTreeData = dataCache.Dequeue();
            tempTreeData.ReInit(renderer);
            return tempTreeData;
        }
        else
        {
            return new TreeData(renderer);
        }
    }

    protected static void RecycleTreeData(TreeData data)
    {
        dataCache.Enqueue(data);
        data.Clear();
    }

    [Header("启用区域风")]
    public bool Enable;
    [System.Serializable]
    public struct AreaWind
    {
        /*[Header("风紊乱")]
        public float WindScale;
        [Header("风速")]
        public float WindSpeed;*/
        [Header("风强度")]
        public float WindIntensity;
        [Header("风向")]
        public float WindDirection;
    }
    [Header("区域风参数")]
    public AreaWind areaWind;
    MaterialPropertyBlock windBlock;
    private static int WindParamID = Shader.PropertyToID("_WindParam");

    Dictionary<Renderer, TreeData> PlantRendererDic = new Dictionary<Renderer, TreeData>();
    private Renderer tempRenderer;

    void Awake()
    {
        windBlock = new MaterialPropertyBlock();
    }

    public void SetWindData(AreaWind areaWind)
    {
        this.areaWind = areaWind;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!Enable)
        {
            return;
        }
        tempRenderer = other.GetComponent<Renderer>();
        if (tempRenderer != null)
        {
            TreeData tree = GetTreeData(tempRenderer);
            if (!PlantRendererDic.ContainsKey(tempRenderer))
                PlantRendererDic.Add(tempRenderer, tree);
            tree.GetParam(areaWind);
            DOTween.Kill(tempRenderer);
            var tween = DOTween.To(() => tree.sourceParam, curParam =>
            {
                windBlock.SetVector(WindParamID, curParam); tree.renderer.SetPropertyBlock(windBlock);
            }, tree.windParam, 0.5f);
            tween.SetTarget(tempRenderer);
        }

    }
    private void OnTriggerExit(Collider other)
    {
        tempRenderer = other.GetComponent<Renderer>();
        if (!PlantRendererDic.ContainsKey(tempRenderer))
            return;
        TreeData tree = PlantRendererDic[tempRenderer];
        PlantRendererDic.Remove(tempRenderer);
        DOTween.Kill(tempRenderer);
        var tween = DOTween.To(() => tree.windParam, curParam =>
        {
            windBlock.SetVector(WindParamID, curParam); tree.renderer.SetPropertyBlock(windBlock);
        }, tree.sourceParam, 2f);
        tween.SetTarget(tempRenderer);
        tween.onComplete = () => { RecycleTreeData(tree); };
    }
    private void OnDisable()
    {
        foreach(var tree in PlantRendererDic.Values)
        {
            windBlock.SetVector(WindParamID, tree.sourceParam);
            tree.renderer.SetPropertyBlock(windBlock);
            DOTween.Kill(tree.renderer);
            RecycleTreeData(tree);
        }
        PlantRendererDic.Clear();
    }

}
