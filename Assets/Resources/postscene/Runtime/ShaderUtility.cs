using UnityEditor;
using UnityEngine;

namespace BioumRP
{
    public static class BioumRPUtility
    {
        public static void SetKeyword(this Material material, string keyWord, bool toggle)
        {
            if (toggle)
                material.EnableKeyword(keyWord);
            else
                material.DisableKeyword(keyWord);
        }
    }
}
