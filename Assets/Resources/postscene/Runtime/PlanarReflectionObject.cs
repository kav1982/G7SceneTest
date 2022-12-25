using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BioumRP;

[ExecuteAlways]
public class PlanarReflectionObject : MonoBehaviour
{
    private Material[] m_Materials;
    public Material[] Materials => m_Materials;

    private Bounds m_Bounds;
    public Bounds Bounds => m_Bounds;

    public void RefreshMaterial()
    {
        MeshRenderer meshRenderer = GetComponent<MeshRenderer>();
        if (meshRenderer)
        {
            m_Materials = GetComponent<MeshRenderer>().sharedMaterials;
            m_Bounds = meshRenderer.bounds;
        }
    }

    private void OnEnable()
    {
        RefreshMaterial();
        PlanarReflectionObjectList.instance.Add(this);
        gameObject.layer = LayerMask.NameToLayer("Water");
    }

    private void OnDisable()
    {
        PlanarReflectionObjectList.instance.Remove(this);
    }

    public void SetReflectionState(bool state)
    {
        for (int i = 0; i < m_Materials.Length; i++)
        {
            m_Materials[i].SetKeyword("_PLANAR_REFLECTION", state);
        }
    }

    public void SetReflectionTexture(int id, Texture texture)
    {
        for (int i = 0; i < m_Materials.Length; i++)
        {
            m_Materials[i].SetTexture(id, texture);
        }
    }
}
