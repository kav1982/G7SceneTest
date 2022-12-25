using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace GameEngine.MyRendererFeature
{
    //残影拖尾
    public class AfterImage : MonoBehaviour
    {
        public bool RandomColor;
        public float delay;
        public Material aniMaterial;
        [Range(1, 20)]
        public int poolSize = 10;
        [Range(0, 3)]
        public float fadeSpeed = 3f;
        public SkinnedMeshRenderer skinRenderer;


        private float[] fadeTimers;
        private float timer;
        private Renderer[] renderers;
        private Material[] materials;
        private List<GameObject> objectPool;
        private MeshFilter[] poolMeshFilters;
        private Vector3 prePos = Vector3.negativeInfinity;
        private Vector3 curPos;
        private int curIndex = -1;
        private int fadePropertyID = 0;

        void Start()
        {
            prePos = transform.position;
            fadePropertyID = Shader.PropertyToID("_Fade");
            if (skinRenderer == null)
                skinRenderer = transform.GetComponent<SkinnedMeshRenderer>();
            if (skinRenderer == null)
            {
                this.enabled = false;
                return;
            }

            objectPool = new List<GameObject>();
            poolMeshFilters = new MeshFilter[poolSize];
            renderers = new Renderer[poolSize];
            materials = new Material[poolSize];
            fadeTimers = new float[poolSize];

            GameObject presetObj = new GameObject("AfterImage");
            poolMeshFilters[0] = presetObj.AddComponent<MeshFilter>();
            renderers[0] = presetObj.AddComponent<MeshRenderer>();
            renderers[0].sharedMaterial = aniMaterial;
            materials[0] = renderers[0].material;
            presetObj.SetActive(false);
            objectPool.Add(presetObj);
            for (int i = 1; i < poolSize; i++)
            {
                tempGo = Instantiate(presetObj);
                poolMeshFilters[i] = tempGo.GetComponent<MeshFilter>();
                renderers[i] = tempGo.GetComponent<Renderer>();
                materials[i] = renderers[i].material;
                tempGo.SetActive(false);
                objectPool.Add(tempGo);
            }
        }


        float tempDt;
        void Update()
        {
            timer -= Time.deltaTime;

            if (timer < 0)
            {
                curPos = transform.position;
                if (!Vector3.Equals(curPos, prePos))
                {
                    prePos = curPos;
                    timer = delay;
                    CreateAfterImage();
                }
            }

            tempDt = Time.deltaTime * fadeSpeed;
            for (int i = 0; i < poolSize; i++)
            {
                if (fadeTimers[i] > 0)
                {
                    fadeTimers[i] -= tempDt;
                    materials[i].SetFloat(fadePropertyID, fadeTimers[i]);
                    if (fadeTimers[i] <= 0)
                        objectPool[i].SetActive(false);
                }
            }

        }


        private GameObject tempGo;
        private int tempIndex;
        public void GetPooledObject()
        {
            curIndex++;
            if (curIndex >= poolSize) curIndex = 0;
            tempGo = objectPool[curIndex];
            tempIndex = curIndex;
        }

        void CreateAfterImage()
        {
            GetPooledObject();

            fadeTimers[tempIndex] = 1f;
            materials[tempIndex].SetFloat(fadePropertyID, fadeTimers[tempIndex]);
            if (RandomColor)
            {
                materials[tempIndex].SetColor("_Color", Random.ColorHSV(0, 1, 0.5f, 1, 1, 1));
            }
            skinRenderer.BakeMesh(poolMeshFilters[tempIndex].mesh);

            tempGo.transform.position = transform.position;
            tempGo.transform.rotation = transform.rotation;
            tempGo.SetActive(true);
        }

        private void OnDestroy()
        {
            for (int i = 0; i < poolSize; i++)
            {
                tempGo = objectPool[i];
                DestroyImmediate(tempGo);
            }
        }
    }
}