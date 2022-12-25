using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class StaticWindObject : MonoBehaviour
{
    //[SerializeField]
    //Animation animation;
    [SerializeField]
    GameObject animObj;
    [System.Serializable]
    public struct AreaWind
    {
        [Header("风紊乱")]
        [Min(0)]
        public float WindScale;
        [Header("风速")]
        public float WindSpeed;
        [Header("风强度")]
        public float WindIntensity;
        [Header("风向")]
        public float WindDirection;

        [HideInInspector]
        public Vector4 windParam;
        public void SetParam()
        {
            windParam = Vector4.zero;
            float radian = WindDirection * Mathf.Deg2Rad;
            windParam.x = Mathf.Cos(radian) * WindIntensity;
            windParam.y = Mathf.Sin(radian) * WindIntensity;
            windParam.z = WindScale;
            windParam.w = WindSpeed;
        }
    }
    [Header("启用区域风")] 
    [SerializeField] private bool enable;
    public bool Enable
    {
        get { return enable; }
        set
        {
            if (value)
            {
                m_Collider.enabled = true;
                animObj.SetActive(true);
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
                animObj.SetActive(false);
                ClearWindEff();
                m_Collider.enabled = false;
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
    [Header("起风参数")]
    [SerializeField]
    AreaWind areaWind;

    SphereCollider m_Collider;
    float ColliderRadius;
    float animLength;
    float percent;
    Vector4 curParam;
    private Renderer tempRenderer;
    MaterialPropertyBlock windBlock;
    private static int WindParamID = Shader.PropertyToID("_WindParam");
    private static int WindParam2ID = Shader.PropertyToID("_WindParam2");
    private List<Renderer> renderers = new List<Renderer>();
    

#if UNITY_EDITOR
    private void OnValidate()
    {
        if (!animObj)
        {
            Debug.Log(this.transform.parent.name + "(" + this.name + ")" + "面板未设置完全");
            return;
        }
        if(!m_Collider)
            m_Collider = this.GetComponent<SphereCollider>();

        Enable = enable;
        Refresh();
    }
    private void OnDrawGizmos()
    {
        if (!m_Collider)
            m_Collider = this.GetComponent<SphereCollider>();
        Gizmos.color = Color.blue;
        if (m_Collider)
        {
            ColliderRadius = m_Collider.radius * this.transform.lossyScale.x;
            Gizmos.DrawWireSphere(transform.position, ColliderRadius);
            Gizmos.color = Color.yellow;
            Vector3 endPos = transform.position + transform.forward * ColliderRadius * 0.75f;
            Vector3 arrow1 = endPos + (-transform.forward - transform.right) * ColliderRadius*0.3f;
            Vector3 arrow2 = endPos + (-transform.forward + transform.right) * ColliderRadius*0.3f;
            Gizmos.DrawLine(transform.position,endPos);
            Gizmos.DrawLine(endPos,arrow1);
            Gizmos.DrawLine(endPos,arrow2);
        }
    }
#endif
    // Start is called before the first frame update
    void Awake()
    {
        windBlock = new MaterialPropertyBlock();
        if(!m_Collider)
            m_Collider = this.GetComponent<SphereCollider>();
        ColliderRadius = m_Collider.radius * this.transform.lossyScale.x;
    }
    private void OnEnable()
    {
        areaWind.SetParam();
        Enable = false;
        Tween t = DOTween.To(x => { }, 0, StartTimes, StartTimes);
        t.SetTarget(this);
        t.onComplete = () => { Enable = true; t.Kill(); };
    }
    void ClearWindEff()
    {
        foreach (Renderer renderer in renderers)
        {
            if (!renderer)
                return;
            renderer.GetPropertyBlock(windBlock);
            windBlock.Clear();
            renderer.SetPropertyBlock(windBlock);
        }
        renderers.Clear();
    }

    private void OnTriggerEnter(Collider other)
    {
        tempRenderer = other.GetComponent<Renderer>();
        if (!tempRenderer)
            return;
        float dis = (tempRenderer.gameObject.transform.position - this.transform.position).magnitude;
        if (dis > ColliderRadius)
            dis = ColliderRadius;
        percent = 1 - dis / ColliderRadius;
        //Vector3 windDir = other.transform.position - (this.transform.position - transform.forward * ColliderRadius);
        //Vector2 realDir = new Vector2(windDir.x, windDir.z).normalized * areaWind.WindIntensity;
        
        Vector2 realDir = new Vector2(transform.forward.x, transform.forward.z) * areaWind.WindIntensity;
        Vector4 windParam2 = new Vector4(realDir.x, realDir.y, percent,1);
        if (!renderers.Contains(tempRenderer))
            renderers.Add(tempRenderer);
        SetWindBlock(tempRenderer,windParam2);
    }
    void SetWindBlock(Renderer renderer,Vector4 windParam2)
    {
        float percent = windParam2.z;
        curParam = renderer.sharedMaterial.GetVector(WindParamID);
        curParam = Vector4.Lerp(curParam,areaWind.windParam,percent);
        windBlock.SetVector(WindParamID, curParam);
        windBlock.SetVector(WindParam2ID,windParam2);
        renderer.SetPropertyBlock(windBlock);
    }
    private void OnTriggerExit(Collider other)
    {
        tempRenderer = other.GetComponent<Renderer>();
        if (!tempRenderer)
            return;
        tempRenderer.GetPropertyBlock(windBlock);
        windBlock.Clear();
        tempRenderer.SetPropertyBlock(windBlock);
        if (renderers.Contains(tempRenderer))
            renderers.Remove(tempRenderer);
    }

    private void OnDisable()
    {
        ClearWindEff();
    }

    void Refresh()
    {
        areaWind.SetParam();
        Vector2 realDir = new Vector2(transform.forward.x, transform.forward.z) * areaWind.WindIntensity;
        Vector4 windParam2 = new Vector4(realDir.x, realDir.y, percent,1);
        if (renderers.Count > 0)
        {
            foreach (var renderer in renderers)
            {
                SetWindBlock(renderer, windParam2);
            }
        }
    }

    public void SetAreaWindData(float WindScale, float WindSpeed, float WindIntensity, float WindDirection)
    {
        areaWind.WindScale = WindScale;
        areaWind.WindSpeed = WindSpeed;
        areaWind.WindIntensity = WindIntensity;
        areaWind.WindDirection = WindDirection;
        Refresh();
    }
}
