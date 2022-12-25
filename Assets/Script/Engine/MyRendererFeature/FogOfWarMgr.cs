using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class FogOfWarMgr
    {
        private static FogOfWarMgr _instance;

        public static FogOfWarMgr Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new FogOfWarMgr();
                }
                return _instance;
            }
        }

        public static void NeedUpdateFog()
        {
            FogOfWarMaskPass.NeedUpdateFog();
        }

        public void KeepUpdateInTime(float time)
        {
            FogOfWarMaskPass.KeepUpdateInTime(time);
        }
    }
}
