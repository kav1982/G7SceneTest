using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class PostController : MonoBehaviour
{
    private VolumeProfile profile;
    //private RadialBlurVolume radialBlurVolume;

    private void OnEnable()
    {
        profile = GetComponent<Volume>().profile;
        //profile.TryGet(typeof(RadialBlurVolume), out radialBlurVolume);
        
        // radialBlurVolume.Toggle = 
        // radialBlurVolume.Intensity = 
        // radialBlurVolume.Range = 
    }
}
