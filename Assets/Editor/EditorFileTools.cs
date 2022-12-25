using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class EditorFileTools
{

    // 读取文件文本内容
    public static string ReadFile(string file)
    {
        FileStream fs = new FileStream(file, FileMode.Open);
        StreamReader sr = new StreamReader(fs);
        string content = sr.ReadToEnd();
        sr.Close();
        fs.Close();
        return content;
    }

    // 创建文件所在的目录
    public static string CreateFolderForFile(string file)
    {
        DirectoryInfo folder = Directory.GetParent(file);
        if (folder.Exists == false)
        {
            folder.Create();
        }
        return file;
    }

    // 删除目录或文件
    public static string DeleteFileOrFolder(string path)
    {
        if (File.Exists(path))
        {
            new FileInfo(path).Delete();
        }
        else if (Directory.Exists(path))
        {
            new DirectoryInfo(path).Delete(true);
        }
        return path;
    }

    // 向文件写入文本内容
    public static bool WriteFile(string file, string content)
    {
        CreateFolderForFile(file);
        FileStream fs = new FileStream(file, FileMode.OpenOrCreate);
        StreamWriter sw = new StreamWriter(fs);
        sw.Write(content);
        sw.Flush();
        sw.Close();
        fs.Close();
        return true;
    }

    // 通过.meta文件获取guid
    public static string GetGuidFromMetaFile(string metaContent)
    {
        foreach (string line in metaContent.Split('\n'))
        {
            if (line.StartsWith("guid: "))
            {
                return line.Substring(5).Trim();
            }
        }
        throw new System.Exception("未能获取meta文件中的guid属性 ");
    }

    //获取资源的GUID
    public static string GetAssetGUID(string assetPath)
    {
        if (!assetPath.EndsWith(".meta"))
            assetPath = assetPath + ".meta";
        if (File.Exists(assetPath))
        {
            return GetGuidFromMetaFile(ReadFile(assetPath));
        }
        return string.Empty;
    }

    public static bool ChangeAssetGUID(string assetPath, string newGUID)
    {
        if (!assetPath.EndsWith(".meta"))
            assetPath = assetPath + ".meta";
        if (File.Exists(assetPath))
        {
            string content = ReadFile(assetPath);
            foreach (string line in content.Split('\n'))
            {
                if (line.StartsWith("guid: "))
                {
                    WriteFile(assetPath, content.Replace(line, "guid: " + newGUID.Trim()));
                    return true;
                }
            }
            throw new System.Exception("未能获取meta文件中的guid属性 ");
        }
        return false;
    }

    public static bool ChangeTextureColor(string texPath, float gamma = 1f, float bright = 0f, float contrast = 0f, float hue = 0.5f, float saturation = 1f, float value = 1f, float hsvFac = 0)
    {
        Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>(texPath);
        if (tex == null) return false;
        TextureImporter texImporte = TextureImporter.GetAtPath(texPath) as TextureImporter;
        if (texImporte.isReadable == false)
        {
            texImporte.isReadable = true;
            texImporte.SaveAndReimport();
        }

        Color c;

        float a, b, h, s, v;

        Texture2D newTex = new Texture2D(tex.width, tex.height);
        Color hsv;
        Color[] colors = tex.GetPixels();
        for (int i = 0; i < colors.Length; i++)
        {
            c = colors[i];
            c.r = Mathf.Pow(c.r, gamma);
            c.g = Mathf.Pow(c.g, gamma);
            c.b = Mathf.Pow(c.b, gamma);

            a = 1 + contrast;
            b = bright - contrast * 0.5f;
            c.r = Mathf.Clamp01(c.r * a + b);
            c.g = Mathf.Clamp01(c.g * a + b);
            c.b = Mathf.Clamp01(c.b * a + b);

            if (hsvFac != 0)
            {
                Color.RGBToHSV(c, out h, out s, out v);
                h = h + hue + 0.5f;
                h -= (int)h;
                s = Mathf.Clamp01(s * saturation);
                v *= value;
                hsv = Color.HSVToRGB(h, s, v);

                c.r = Mathf.Lerp(c.r, hsv.r, hsvFac);
                c.g = Mathf.Lerp(c.g, hsv.g, hsvFac);
                c.b = Mathf.Lerp(c.b, hsv.b, hsvFac);
            }
            c.r = Mathf.Clamp01(c.r);
            c.g = Mathf.Clamp01(c.g);
            c.b = Mathf.Clamp01(c.b);
            colors[i] = c;
        }
        newTex.SetPixels(colors);
        newTex.Apply();
        byte[] bytes;
        if (texPath.ToLower().EndsWith(".tga"))
            bytes = newTex.EncodeToTGA();
        else
            bytes = newTex.EncodeToPNG();
        File.WriteAllBytes(texPath, bytes);
        AssetDatabase.SaveAssets();
        texImporte.isReadable = false;
        texImporte.SaveAndReimport();
        return true;
    }
}
