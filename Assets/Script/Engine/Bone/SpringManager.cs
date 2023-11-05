//
//SpingManager.cs for unity-chan!
//
//Original Script is here:
//ricopin / SpingManager.cs
//Rocket Jump : http://rocketjump.skr.jp/unity3d/109/
//https://twitter.com/ricopin416
//
//Revised by N.Kobayashi 2014/06/24
//           Y.Ebata
//
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace UnityChan {
    public class SpringManager : MonoBehaviour
    //#if !SCENE_DEBUG
    //        , Battle.IEvent
    //#endif
    {
        //Kobayashi
        // DynamicRatio is paramater for activated level of dynamic animation 
        // DynamicRatio是动态动画激活等级的参数
        public static bool UseSpring = true;
        public float dynamicRatio = 1.0f;

        //Ebata stuffnessForce 刚硬度
        public float stiffnessForce;
        public AnimationCurve stiffnessCurve;
        public float dragForce;
        public AnimationCurve dragCurve;
        public SpringBone[] springBones;
        

        void Start() {
            var sbList = GetComponentsInChildren<UnityChan.SpringBone>();
            springBones = sbList;

            for (int i = 0; i < springBones.Length; i++) {
                if (springBones[i] == null) {
                    Debug.LogError("SpringManager 有空骨骼 go=" + BoneManage.GetFullGoPath(this.gameObject.transform));
                }
            }

#if UNITY_EDITOR
            UpdateParameters();
#endif

#if !SCENE_DEBUG
            Animator animator = GetComponent<Animator>();
            if (animator != null) {
                AnimatorClipInfo[] infos = animator.GetCurrentAnimatorClipInfo(0);
                if (infos != null && infos.Length != 0 && infos[0].clip != null)
                    OnAniChange(infos[0].clip.name);
            }
#endif
        }

#if UNITY_EDITOR
        void Update() {

            //Kobayashi
            if (dynamicRatio >= 1.0f)
                dynamicRatio = 1.0f;
            else if (dynamicRatio <= 0.0f)
                dynamicRatio = 0.0f;
            //Ebata
            UpdateParameters();
        }
#endif

        private void LateUpdate() {
            if (!currentEnabled && disableCoroutine == null)
                return;
            if (UseSpring) {
                //Kobayashi
                if (dynamicRatio != 0.0f) {
                    for (int i = 0; i < springBones.Length; i++) {
                        if (springBones[i] == null)
                            continue;
                        if (dynamicRatio > springBones[i].threshold) {
                            springBones[i].UpdateSpring();
                        }
                    }
                }
            }
        }

#if !SCENE_DEBUG
        [SerializeField]
        float disableSpeed = 0.5f;

        

        void OnAniChange(string playAni) {
            bool isEnable = UpdateCurrentEnable(playAni);
            if (currentEnabled != isEnable) {
                currentEnabled = isEnable;
                if (!currentEnabled) {
                    SetDisable(disableSpeed);
                } else {
                    CannelDisable();
                }
            }
        }

        
#endif

        [SerializeField]
        [HideInInspector]
        bool isType = true; // 过滤的类型true,在列表当中的不运算，false在列表当中的参与运算

        [SerializeField]
        string[] disableAnims;// 不播放动画列表

        [HideInInspector]
        public bool currentEnabled = true;

#if UNITY_EDITOR
        [HideInInspector]
        [System.NonSerialized]
        public string currentAnimName;
#endif

        Coroutine disableCoroutine;

        void CannelDisable() {
            if (disableCoroutine != null) {
                StopCoroutine(disableCoroutine);
                dynamicRatio = 1f;
                disableCoroutine = null;
            }
        }

        public void SetDisable(float speed = 0.5f) {
            CannelDisable();
            disableCoroutine = StartCoroutine(UpdateDisable(speed));
        }

        IEnumerator UpdateDisable(float speed) {
            speed = dynamicRatio / speed;
            while (true) {
                if (dynamicRatio <= 0) {
                    dynamicRatio = 1f;
                    disableCoroutine = null;
                    yield break;
                }

                float delay = Time.deltaTime;
                dynamicRatio -= delay * speed;
                yield return 0;
            }
        }

        bool UpdateCurrentEnable(string currentAnim) {
#if UNITY_EDITOR
            currentAnimName = currentAnim;
#endif
            // 过滤的类型true,在列表当中的不运算，false在列表当中的参与运算
            if (isType == true) {
                for (int i = 0; i < disableAnims.Length; ++i) {
                    if (currentAnim == disableAnims[i])
                        return false;
                }
                return true;
            } else {
                for (int i = 0; i < disableAnims.Length; ++i) {
                    if (currentAnim == disableAnims[i])
                        return true;
                }

                return false;
            }
        }

#if UNITY_EDITOR
        private void UpdateParameters() {
            UpdateParameter("stiffnessForce", stiffnessForce, stiffnessCurve);
            UpdateParameter("dragForce", dragForce, dragCurve);
            //stiffnessForce刚度力
            //dragForce阻力
        }

        private void UpdateParameter(string fieldName, float baseValue, AnimationCurve curve) {
            if (curve.length <= 0) {
                return;
            }
            var start = curve.keys[0].time;
            var end = curve.keys[curve.length - 1].time;
            //var step	= (end - start) / (springBones.Length - 1);

            var prop = springBones[0].GetType().GetField(fieldName, System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public);

            for (int i = 0; i < springBones.Length; i++) {
                if (springBones[i] == null)
                    continue;
                //Kobayashi
                if (!springBones[i].isUseEachBoneForceSettings) {
                    var scale = curve.Evaluate(start + (end - start) * i / (springBones.Length - 1));
                    prop.SetValue(springBones[i], baseValue * scale);
                }
            }

        }
#endif
    }
}