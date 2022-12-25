using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class CharacterDissolveTest : MonoBehaviour
{
    [Range(0, 1)]public float dissolveFac = 0;
    [Range(0, 1)]public float AttackFlash = 0;
    [Range(0, 1)]public float DitherTransparent = 0;


    private Vector4 dissolveVector;
    private Vector4 battleVector;
    // Update is called once per frame
    void Update()
    {
        //dissolveFac = Mathf.Sin(Time.time) * 0.5f + 0.5f;
        Renderer[] renderers = GetComponentsInChildren<Renderer>();
        for (int i = 0; i < renderers.Length; i++)
        {
            Material[] materials;
            if(Application.isPlaying)
                materials = renderers[i].materials;
            else
                materials = renderers[i].sharedMaterials;
            
            for (int j = 0; j < materials.Length; j++)
            {
                dissolveVector = materials[j].GetVector("_DissolveParam");
                dissolveVector.x = dissolveFac;
                materials[j].SetVector("_DissolveParam", dissolveVector);
                
                battleVector = materials[j].GetVector("_BattleParam");
                battleVector.y = AttackFlash;
                battleVector.x = DitherTransparent;
                materials[j].SetVector("_BattleParam", battleVector);
            }
        }
    }
}
