using UnityEngine;
using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using Debug = UnityEngine.Debug;

public class MovingWindObject : MonoBehaviour
{
    protected class TreeData
    {
        public Renderer renderer;
        public Material material;
        public Vector2 windDir;
        public float enterPow;

        public TreeData(Renderer renderer)
        {
            ReInit(renderer);
        }

        public void ReInit(Renderer renderer)
        {
            this.renderer = renderer;
            material = renderer.sharedMaterial;
        }
        
        public void GetWindDir(Vector2 windDir,float enterPow)
        {
            this.windDir = windDir;
            this.enterPow = enterPow;
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
    [SerializeField]
    Animation animation;
    [SerializeField]
    GameObject animObj;
    [Header("启用区域风")] 
    [SerializeField] private bool enable;
    public bool Enable
    {
        get { return enable; }
        set
        {
            if (value)
            {
                animObj.SetActive(true);
                animation.Play();
                if (LoopTimes != 0 && animLength!=0)
                {
                    Tween t = DOTween.To(x => { }, 0, 1, LoopTimes * animLength);
                    t.SetTarget(this);
                    t.onComplete = () => { Enable = false;};
                }
            }
            else
            {
                DOTween.Kill(this);
                animation.Stop();
                animObj.SetActive(false);
                ClearWindEff();
            }
            enable = value;
        }
    }
    [Header("延迟启用时间")]
    [Min(0)]
    public float StartTimes;
    [Header("循环次数(为0则一直循环)")]
    [Min(0)]
    public int LoopTimes;

    [Header("区域风强度")]
    public float WindIntensity;
    [Header("起风缓冲时间")]
    [Min(0)]
    public float enterTime;
    [Header("风停缓冲时间")]
    [Min(0)]
    public float exitTime;
    MaterialPropertyBlock windBlock;
    //private static int WindParamID = Shader.PropertyToID("_WindParam");
    private static int WindParam2ID = Shader.PropertyToID("_WindParam2");
    Dictionary<Renderer, TreeData> PlantRendererDic = new Dictionary<Renderer, TreeData>();
    private Renderer tempRenderer;
    float animLength;
    float timer = 0;

#if UNITY_EDITOR
    private SphereCollider m_Collider;
    private void OnDrawGizmos()
    {
        if (!m_Collider)
           m_Collider = this.GetComponent<SphereCollider>();
        Gizmos.color = Color.red;
        if (m_Collider)
        {
            float realRadius = m_Collider.radius * this.transform.lossyScale.x;
            Gizmos.DrawWireSphere(transform.position, realRadius);
            Gizmos.color = Color.yellow;
            Vector3 endPos = transform.position + transform.forward * realRadius * 0.75f;
            Vector3 arrow1 = endPos + (-transform.forward - transform.right) * realRadius*0.3f;
            Vector3 arrow2 = endPos + (-transform.forward + transform.right) * realRadius*0.3f;
            Gizmos.DrawLine(transform.position,endPos);
            Gizmos.DrawLine(endPos,arrow1);
            Gizmos.DrawLine(endPos,arrow2);
        }
    }

    private void OnValidate()
    {
        if (!animation || !animObj)
        {
            Debug.Log(this.transform.parent.name + "(" + this.name + ")" + "面板未设置完全");
            return;
        }
        if (!m_Collider)
            m_Collider = this.GetComponent<SphereCollider>();

        Enable = enable;

        if (animation)
            animation.playAutomatically = false;
    }
#endif
    void Awake()
    {
        if (animation)
            animLength = animation.clip.length;
        windBlock = new MaterialPropertyBlock();
    }

    private void OnEnable()
    {
        Enable = false;
        Tween t = DOTween.To(x => { }, 0, StartTimes, StartTimes);
        t.SetTarget(this);
        t.onComplete = () => { Enable = true; t.Kill(); };
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
            Enable = !Enable;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!enable)
        {
            return;
        }
        tempRenderer = other.GetComponent<Renderer>();
        if (tempRenderer != null)
        {
            TreeData tree = GetTreeData(tempRenderer);
            Vector3 windDir = other.transform.position - this.transform.position;
            Vector2 realDir = new Vector2(windDir.x, windDir.z).normalized * WindIntensity;
            float enterPow = Mathf.Abs(realDir.y);
            if(tempRenderer.name == "xx")
                Debug.Log(enterPow);
            if (!PlantRendererDic.ContainsKey(tempRenderer))
                PlantRendererDic.Add(tempRenderer, tree);
            tree.GetWindDir(realDir,enterPow);
            DOTween.Kill(tempRenderer);
            var tween = DOTween.To(() => 0, curPercent =>
            {
                var windParam2 = new Vector4(tree.windDir.x * curPercent, tree.windDir.y * curPercent, curPercent,0);
                windBlock.SetVector(WindParam2ID, windParam2);
                tree.renderer.SetPropertyBlock(windBlock);
            }, enterPow, enterTime);
            tween.SetTarget(tempRenderer);
        }

    }
    private void OnTriggerExit(Collider other)
    {
        if (!enable)
        {
            return;
        }
        tempRenderer = other.GetComponent<Renderer>();
        if (!PlantRendererDic.ContainsKey(tempRenderer))
            return;
        TreeData tree = PlantRendererDic[tempRenderer];
        PlantRendererDic.Remove(tempRenderer);
        DOTween.Kill(tempRenderer);
        float enterPow = tree.enterPow;
        var tween = DOTween.To(() => enterPow, curPercent =>
        {
            var windParam2 = new Vector4(tree.windDir.x * curPercent, tree.windDir.y * curPercent, curPercent,0);
            windBlock.SetVector(WindParam2ID, windParam2);
            tree.renderer.SetPropertyBlock(windBlock);
        }, 0, exitTime);
        
        tween.SetTarget(tempRenderer);
        tween.onComplete = () => { RecycleTreeData(tree); };
    }

    void ClearWindEff()
    {
        foreach(var tree in PlantRendererDic.Values)
        {
            windBlock.Clear();
            tree.renderer.SetPropertyBlock(windBlock);
            DOTween.Kill(tree.renderer);
            RecycleTreeData(tree);
        }
        PlantRendererDic.Clear();
    }
    
    private void OnDisable()
    {
        ClearWindEff();
    }

}
