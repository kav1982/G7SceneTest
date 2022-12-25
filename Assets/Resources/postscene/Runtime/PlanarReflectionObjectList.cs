using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanarReflectionObjectList : MonoBehaviour
{
    static readonly Lazy<PlanarReflectionObjectList> s_Instance = new Lazy<PlanarReflectionObjectList>(() => new PlanarReflectionObjectList());
    public static PlanarReflectionObjectList instance => s_Instance.Value;
    
    
    public static event Action OnListChanged;
    
    
        
    private List<PlanarReflectionObject> objects;

    public PlanarReflectionObjectList()
    {
        objects = new List<PlanarReflectionObject>();
    }

    public List<PlanarReflectionObject> Get() => objects;

    public void Add(PlanarReflectionObject obj)
    {
        if (!objects.Contains(obj))
        {
            objects.Add(obj);
            OnListChanged?.Invoke();
        }
    }
        
    public void Remove(PlanarReflectionObject obj)
    {
        objects.Remove(obj);
        OnListChanged?.Invoke();
    }
}
