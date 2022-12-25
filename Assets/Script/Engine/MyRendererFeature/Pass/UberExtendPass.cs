using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameEngine.MyRendererFeature
{
    public class UberExtendPass<T> where T: VolumeComponent, IPostProcessComponent
    {
        protected T m_Config;

        public virtual bool AddRenderPasses(RenderingData renderingData)
        {
            if (m_Config == null)
            {
                m_Config = (T)VolumeManager.instance.stack.GetComponent(typeof(T));
            }
            if (m_Config.IsActive())
            {
                renderingData.postProcessingSetMat.Enqueue(SetMaterial);
                return true;
            }
            return false;
        }

        protected virtual void SetMaterial(Material mat)
        {
        }
    }
}
