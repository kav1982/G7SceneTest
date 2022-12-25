using System;
using System.Collections;
using System.Collections.Generic;
using BioumRP;
using UnityEngine;
using UnityEditor;

[ExecuteAlways]
public class EffectClipTest : MonoBehaviour
{
    public Vector4 positionMinMax = Vector4.zero;
    
    private void Update()
    {
        Renderer[] renderers = GetComponentsInChildren<Renderer>();
        for (int i = 0; i < renderers.Length; i++)
        {
            Material[] materials = renderers[i].sharedMaterials;
            for (int j = 0; j < materials.Length; j++)
            {
                materials[j].SetKeyword("_UI_CLIP", true);
                materials[j].SetVector("_ClipRect", positionMinMax);
            }
        }
    }
}
