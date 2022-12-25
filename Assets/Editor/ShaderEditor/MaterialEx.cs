using UnityEngine;

static public class MaterialEX
{
    public static void SetKeyword(this Material mat, string keyword, bool enable)
    {
        if (enable)
            mat.EnableKeyword(keyword);
        else
            mat.DisableKeyword(keyword);
    }
}