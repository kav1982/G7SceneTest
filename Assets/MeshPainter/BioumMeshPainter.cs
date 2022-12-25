//#undef UNITY_EDITOR

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.Rendering;
#endif
using UnityEngine;
using UnityEngine.Internal;
using UnityEngine.SceneManagement;
using Random = UnityEngine.Random;

namespace BArtLib
{

    [ExecuteAlways]
    [RequireComponent (typeof (MeshCollider))]
    public class BioumMeshPainter : MonoBehaviour
    {
#if UNITY_EDITOR
        [CustomEditor (typeof (BioumMeshPainter))]
        public class BioumMeshPainterEditor : Editor
        {
            enum PaintMode
            {
                Texture,
                //Model,
                //WaterMask,
            }
            static PaintMode paintMode;

            string contolTexName = "";

            bool isPaint;
            bool oldIsPaint;
            private bool isUndo;

            static float brushSize = 25f;
            static float brushStronger = 0.5f;
            static Quaternion brushQua = Quaternion.identity;

            static GameObject prefab;
            static float prefabSizeRandom = 0;
            static float prefabRotateRandomX = 0;
            static float prefabRotateRandomY = 0;
            static float prefabRotateRandomZ = 0;
            static bool rotateFollowTerrain = true;
            Texture[] brushTex;
            Texture[] texLayer; // = new Texture[4];

            float[] brushAlphas;
            bool needUpdateBrushInfo = true;
            int currBrushCacheSize;
            int brushWidth;
            int brushHeight;
            float meshSize = 100f;

            int selBrush = 0;
            int selTex = 0;

            int brushSizeInPourcent;
            Texture2D controlTex;
            void OnSceneGUI ()
            {
                if (isPaint)
                {
                    Painter ();
                    SetBrushParam ();
                }
            }

            public override void OnInspectorGUI ()
            {
                GUILayout.Space (10);
                GUILayout.BeginHorizontal ();
                GUILayoutOption[] options = new GUILayoutOption[] { GUILayout.Width (100) };
                EditorGUILayout.LabelField ("绘制模式选择", options);
                paintMode = (PaintMode) EditorGUILayout.EnumPopup (paintMode);
                GUILayout.EndHorizontal ();

                GUILayout.Space (10);

                GUILayout.BeginHorizontal ();
                GUILayout.FlexibleSpace ();
                GUIStyle boolBtnOn = new GUIStyle (GUI.skin.GetStyle ("Button")); //得到Button样式
                oldIsPaint = isPaint;
                isPaint = GUILayout.Toggle (isPaint, "点击开始绘制", boolBtnOn, GUILayout.Width (100), GUILayout.Height (25)); //编辑模式开关
                if(oldIsPaint != isPaint)
                {
                    OnIsPaintChange();
                }
                
                //if(paintMode == PaintMode.WaterMask)
                //    isUndo = GUILayout.Toggle (isUndo, "擦除", boolBtnOn, GUILayout.Width (100), GUILayout.Height (25));
                GUILayout.FlexibleSpace ();
                GUILayout.EndHorizontal ();

                GUILayout.Space (10);

                BrushParamInspector ();

                switch (paintMode)
                {
                    case PaintMode.Texture:
                        TextureModeInspector ();
                        break;
                    //case PaintMode.Model:
                    //    ModelModeInspector ();
                    //    break;
                    //case PaintMode.WaterMask:
                    //    MaskModeInspector();
                    //    break;

                }
            }

            private float tempFloat;
            void BrushParamInspector ()
            {
                tempFloat = EditorGUILayout.Slider ("笔刷大小", brushSize, 0.5f, 100f); //笔刷大小
                if(tempFloat != brushSize)
                {
                    brushSize = tempFloat;
                    needUpdateBrushInfo = true;
                }
                brushStronger = EditorGUILayout.Slider ("笔刷强度", brushStronger, 0, 1); //笔刷强度
            }

            private Vector2 brushScroll = Vector2.zero;
            private int tempOld;
            //绘制刷贴图模式的面板
            void TextureModeInspector ()
            {
                if (Cheak (paintMode, Selection.activeTransform))
                {
                    IniBrush ();
                    layerTex ();
                    GUILayout.BeginHorizontal ();
                    GUILayout.FlexibleSpace ();
                    GUILayout.BeginHorizontal ("box", GUILayout.Width (340));
                    selTex = GUILayout.SelectionGrid (selTex, texLayer, 4, "gridlist", GUILayout.Width (340), GUILayout.Height (86));
                    GUILayout.EndHorizontal ();
                    GUILayout.FlexibleSpace ();
                    GUILayout.EndHorizontal ();

                    GUILayout.BeginHorizontal ();
                    GUILayout.FlexibleSpace ();
                    GUILayout.BeginHorizontal ("box", GUILayout.Width (318));
                    brushScroll = GUILayout.BeginScrollView(brushScroll, GUILayout.Width(380), GUILayout.Height(120));
                    tempOld = selBrush;
                    selBrush = GUILayout.SelectionGrid (selBrush, brushTex, 9, "gridlist", GUILayout.Width (340), GUILayout.Height (Mathf.CeilToInt(brushTex.Length / 9.0f) * 40));
                    if (tempOld != selBrush) needUpdateBrushInfo = true;
                    GUILayout.EndScrollView();
                    GUILayout.EndHorizontal ();
                    GUILayout.FlexibleSpace ();
                    GUILayout.EndHorizontal ();
                }
            }

            //快捷键设置笔刷
            void SetBrushParam ()
            {
                Event e = Event.current;

                if (e.keyCode == KeyCode.LeftBracket)
                {
                    brushSize -= brushSize / 20;
                    brushSize = Mathf.Max (0.01f, brushSize);
                    needUpdateBrushInfo = true;
                }
                else if (e.keyCode == KeyCode.RightBracket)
                {
                    brushSize += brushSize / 20;
                    needUpdateBrushInfo = true;
                }
                else if (e.keyCode == KeyCode.Minus)
                {
                    brushStronger = Mathf.Clamp01 (brushStronger -= 0.02f);
                }
                else if (e.keyCode == KeyCode.Equals)
                {
                    brushStronger = Mathf.Clamp01 (brushStronger += 0.02f);
                }
            }

            //获取材质球中的贴图
            void layerTex ()
            {
                Transform Select = Selection.activeTransform;
                Material mat = Select.GetComponent<MeshRenderer> ().sharedMaterial;
                int texCount = (int) mat.GetFloat ("_TexCount");
                texLayer = new Texture[texCount];
                switch (texCount)
                {
                    case 2:
                        texLayer[0] = AssetPreview.GetAssetPreview (mat.GetTexture ("_Splat0")) as Texture;
                        texLayer[1] = AssetPreview.GetAssetPreview (mat.GetTexture ("_Splat1")) as Texture;
                        break;
                    case 3:
                        texLayer[0] = AssetPreview.GetAssetPreview (mat.GetTexture ("_Splat0")) as Texture;
                        texLayer[1] = AssetPreview.GetAssetPreview (mat.GetTexture ("_Splat1")) as Texture;
                        texLayer[2] = AssetPreview.GetAssetPreview (mat.GetTexture ("_Splat2")) as Texture;
                        break;
                    case 4:
                        texLayer[0] = AssetPreview.GetAssetPreview (mat.GetTexture ("_Splat0")) as Texture;
                        texLayer[1] = AssetPreview.GetAssetPreview (mat.GetTexture ("_Splat1")) as Texture;
                        texLayer[2] = AssetPreview.GetAssetPreview (mat.GetTexture ("_Splat2")) as Texture;
                        texLayer[3] = AssetPreview.GetAssetPreview (mat.GetTexture ("_Splat3")) as Texture;
                        break;
                }
            }

            //获取笔刷  
            void IniBrush ()
            {
                if (brushTex == null)
                {
                    string[] CS_GUID = AssetDatabase.FindAssets ("BioumMeshPainter");
                    string CS_Path = AssetDatabase.GUIDToAssetPath (CS_GUID[0]);
                    string MeshPaintEditorFolder = CS_Path.Remove (CS_Path.Length - 19); //  .../folder/BioumMeshPainter.cs  =>  .../folder/
                    ArrayList BrushList = new ArrayList ();
                    Texture BrushesTL;
                    int BrushNum = 0;
                    do
                    {
                        BrushesTL = (Texture) AssetDatabase.LoadAssetAtPath (MeshPaintEditorFolder + "Brushes/Brush" + BrushNum + ".png", typeof (Texture));

                        if (BrushesTL)
                        {
                            BrushList.Add (BrushesTL);
                        }
                        BrushNum++;
                    } while (BrushesTL);
                    brushTex = BrushList.ToArray (typeof (Texture)) as Texture[];
                }
            }

            //检查
            bool Cheak (PaintMode mode, Transform tran)
            {
                bool Cheak = false;
                Material mat = tran.GetComponent<MeshRenderer>().sharedMaterial;
                if (mat.shader.name.Contains ("Scene/SceneTerrianMask"))
                {
                    Texture ControlTex = mode == PaintMode.Texture ? mat.GetTexture ("_Control") : mat.GetTexture ("_WaterMaskMap");
                    if (ControlTex == null)
                    {
                        EditorGUILayout.HelpBox ("当前模型材质球中未找到Mask贴图，绘制功能不可用！", MessageType.Error);

                        if (GUILayout.Button ("创建Mask贴图(256)"))
                        {
                            creatContolTex (256, mode);
                        }
                        if (GUILayout.Button ("创建Mask贴图(512)"))
                        {
                            creatContolTex (512, mode);
                        }
                        if (GUILayout.Button ("创建Mask贴图(1024)"))
                        {
                            creatContolTex (1024, mode);
                        }
                        // if (GUILayout.Button ("创建Mask贴图(2048)"))
                        // {
                        //     creatContolTex (2048);
                        // }
                    }
                    else
                    {
                        Cheak = true;
                    }
                }
                else
                {
                    EditorGUILayout.HelpBox ("shader错误, 请使用'Bioum/Scene/SceneTerrianMask'", MessageType.Error);
                }
                return Cheak;
            }

            //创建Contol贴图
            void creatContolTex (int texelSize, PaintMode mode)
            {
                Scene scene = SceneManager.GetActiveScene ();
                EditorSceneManager.SaveScene (scene);

                //检查目录
                string ControlTexFolder = scene.path.Remove (scene.path.Length - scene.name.Length - 7) + "/textures/"; //  .../folder/sceneName.unity  =>  .../folder/textures/
                if (!Directory.Exists (ControlTexFolder))
                {
                    Directory.CreateDirectory (ControlTexFolder);
                    AssetDatabase.Refresh ();
                }

                //创建一个新的Contol贴图
                TextureFormat format = mode == PaintMode.Texture ? TextureFormat.ARGB32 : TextureFormat.RGB24;
                Texture2D newControlTex = new Texture2D (texelSize, texelSize, format, false);
                Color[] colorBase = new Color[texelSize * texelSize];
                for (int t = 0; t < colorBase.Length; t++)
                {
                    colorBase[t] = mode == PaintMode.Texture ? new Color(1,0,0,0) : Color.black;
                }
                newControlTex.SetPixels (colorBase);

                string name = mode == PaintMode.Texture ? "_Control" : "_WaterMaskMap";

                //判断是否重名
                bool exporNameSuccess = true;
                for (int num = 1; exporNameSuccess; num++)
                {
                    string Next = scene.name + name + num;
                    if (!File.Exists (ControlTexFolder + scene.name + ".tga"))
                    {
                        contolTexName = scene.name + name;
                        exporNameSuccess = false;
                    }
                    else if (!File.Exists (ControlTexFolder + Next + ".tga"))
                    {
                        contolTexName = Next;
                        exporNameSuccess = false;
                    }
                }

                //保存贴图
                string path = ControlTexFolder + contolTexName + ".tga";
                byte[] bytes = newControlTex.EncodeToTGA();
                File.WriteAllBytes (path, bytes);
                AssetDatabase.ImportAsset (path, ImportAssetOptions.ForceUpdate);

                //control贴图导入设置
                TextureImporter textureIm = AssetImporter.GetAtPath (path) as TextureImporter;
                textureIm.textureCompression = TextureImporterCompression.Uncompressed;
                textureIm.isReadable = true;
                textureIm.anisoLevel = 1;
                textureIm.mipmapEnabled = false;
                textureIm.wrapMode = TextureWrapMode.Clamp;
                textureIm.sRGBTexture = false;
                AssetDatabase.ImportAsset (path, ImportAssetOptions.ForceUpdate); //刷新
                setContolTex (path, name); //设置Contol贴图
            }

            //设置Contol贴图
            void setContolTex (string peth, string name)
            {
                Texture2D ControlTex = (Texture2D) AssetDatabase.LoadAssetAtPath (peth, typeof (Texture2D));
                Selection.activeTransform.gameObject.GetComponent<MeshRenderer> ().sharedMaterial.SetTexture (name, ControlTex);
            }


            private MeshRenderer tempMeshRenderer;
            private float minDis;
            private RaycastHit minDisHit;
            private HashSet<Texture2D> drawTexs = new HashSet<Texture2D>();

            void Painter ()
            {
                Transform currentSelect = Selection.activeTransform;
                //GameObject currentSelect = Selection.activeGameObject; //针对project面板的预制体或文件操作有可能报错

                MeshFilter temp = currentSelect.GetComponent<MeshFilter> (); //获取当前模型的MeshFilter
                float orthographicSize = (brushSize * currentSelect.transform.localScale.x) * 0.1f; //笔刷在模型上的正交大小

                Event e = Event.current; //检测输入
                HandleUtility.AddDefaultControl (0);
                Ray terrain = HandleUtility.GUIPointToWorldRay (e.mousePosition); //从鼠标位置发射一条射线
                MeshCollider collider = currentSelect.GetComponent<MeshCollider> ();
                if(e.type == EventType.KeyDown && e.alt == false && e.shift == false && e.control == false)
                {
                    if (e.keyCode == KeyCode.O)
                    {
                        brushQua = Quaternion.AngleAxis(Mathf.RoundToInt(brushQua.eulerAngles.y) / 90 * 90 , Vector3.up);
                        brushQua *= Quaternion.AngleAxis(90, Vector3.up);
                        needUpdateBrushInfo = true;
                    }
                }
                if(e.isScrollWheel && e.shift && e.alt == false&& e.control == false)
                {
                    e.Use();
                    brushQua *= Quaternion.AngleAxis(e.delta.y * 2, Vector3.up);
                    needUpdateBrushInfo = true;
                }

                minDis = float.MaxValue;
                foreach (RaycastHit hit in Physics.RaycastAll(terrain, Mathf.Infinity))
                {
                    tempMeshRenderer = hit.transform.GetComponent<MeshRenderer>();
                    if(tempMeshRenderer!= null && tempMeshRenderer.sharedMaterial.shader.name.Contains("Scene/SceneTerrianMask"))
                    {
                        if(hit.distance < minDis)
                        {
                            minDis = hit.distance;
                            minDisHit = hit;
                        }
                    }
                }
                if(minDis!= float.MaxValue)
                {
                    DrawCircle(minDisHit.point, minDisHit.normal, orthographicSize); // 在鼠标位置绘制一个圆
                    if (e.type == EventType.MouseDown && IsOnDrawing(e))
                    {
                        drawTexs.Clear();
                    }
                    switch (paintMode)
                    {
                        case PaintMode.Texture:
                            DrawTexture(e, minDisHit, minDisHit.transform.gameObject, paintMode, Vector3.zero);
                            break;
                            //case PaintMode.Model:
                            //    DrawModel (e, raycastHit, currentSelect, orthographicSize);
                            //    break;
                            //case PaintMode.WaterMask:
                            //    DrawTexture (e, raycastHit, currentSelect, paintMode);
                            //    break;
                    }
                    //看下笔刷有没有跨地块
                    if (IsOnDrawing(e))
                    {
                        HashSet<Transform> checkedHS = new HashSet<Transform>();
                        checkedHS.Add(minDisHit.transform);
                        Vector3 offset = new Vector3(0, 0, 0.5f);
                        Vector3 center = minDisHit.point;
                        center.y = 10;
                        if (_brushDrawTran != null) offset *= _brushDrawTran.localScale.x;
                        terrain.direction = Vector3.down;
                        List<RaycastHit> hits = new List<RaycastHit>();
                        HashSet<Transform> addedHS = new HashSet<Transform>();
                        for (int i = 0; i < 360; i += 20)
                        {
                            terrain.origin = center + Quaternion.AngleAxis(i, Vector3.up) * offset;
                            minDis = float.MaxValue;
                            foreach (RaycastHit hit in Physics.RaycastAll(terrain, Mathf.Infinity))
                            {
                                if (!checkedHS.Contains(hit.transform))
                                {
                                    string texName = paintMode == PaintMode.Texture ? "_Control" : "_WaterMaskMap";
                                    tempMeshRenderer = hit.transform.GetComponent<MeshRenderer>();
                                    if (tempMeshRenderer != null 
                                        && tempMeshRenderer.sharedMaterial.shader.name.Contains("Scene/SceneTerrianMask")
                                        && tempMeshRenderer.sharedMaterial.GetTexture(texName) != minDisHit.transform.GetComponent<MeshRenderer>().sharedMaterial.GetTexture(texName))
                                    {
                                        if (hit.distance < minDis)
                                        {
                                            minDis = hit.distance;
                                            minDisHit = hit;
                                        }
                                    }
                                    else
                                    {
                                        checkedHS.Add(hit.transform);
                                    }
                                }
                            }
                            if (minDis != float.MaxValue)
                            {
                                if (!addedHS.Contains(minDisHit.transform))
                                {
                                    addedHS.Add(minDisHit.transform);
                                    hits.Add(minDisHit);
                                }
                            }
                        }
                        foreach (RaycastHit hit in hits)
                        {
                            switch (paintMode)
                            {
                                case PaintMode.Texture:
                                    DrawTexture(e, hit, hit.transform.gameObject, paintMode, hit.point - center);
                                    break;
                                    //case PaintMode.Model:
                                    //    DrawModel (e, raycastHit, currentSelect, orthographicSize);
                                    //    break;
                                    //case PaintMode.WaterMask:
                                    //    DrawTexture (e, raycastHit, currentSelect, paintMode);
                                    //    break;
                            }
                        }
                    }
                }

                //if (collider.Raycast (terrain, out raycastHit, Mathf.Infinity))
                //{
                //    DrawCircle (raycastHit.point, raycastHit.normal, orthographicSize); // 在鼠标位置绘制一个圆

                //    switch (paintMode)
                //    {
                //        case PaintMode.Texture:
                //            DrawTexture (e, raycastHit, currentSelect, paintMode);
                //            break;
                //        //case PaintMode.Model:
                //        //    DrawModel (e, raycastHit, currentSelect, orthographicSize);
                //        //    break;
                //        //case PaintMode.WaterMask:
                //        //    DrawTexture (e, raycastHit, currentSelect, paintMode);
                //        //    break;
                //    }

                //}
            }

            bool ToggleF = false;
            private bool IsOnDrawing(Event e)
            {
                return (e.type == EventType.MouseDrag || e.type == EventType.MouseDown) && e.alt == false && e.shift == false && e.control == false && e.button == 0;
            }
            //画混合贴图
            void DrawTexture (Event e, RaycastHit raycastHit, GameObject currentSelect, PaintMode mode, Vector3 offset)
            {
                if (!Cheak (paintMode, currentSelect.transform))
                {
                    return;
                }

                string texName = mode == PaintMode.Texture ? "_Control" : "_WaterMaskMap";
                controlTex = (Texture2D) currentSelect.gameObject.GetComponent<MeshRenderer> ().sharedMaterial.GetTexture (texName); //从材质球中获取Control贴图
                MeshFilter temp = currentSelect.GetComponent<MeshFilter> (); //获取当前模型的MeshFilter
                float orthographicSize = (brushSize * currentSelect.transform.localScale.x) * 0.1f; //笔刷在模型上的正交大小
                if(offset == Vector3.zero)
                    brushSizeInPourcent = (int) Mathf.Round ((orthographicSize * controlTex.width) / 40); //笔刷在模型上的大小

                //鼠标点击或按下并拖动进行绘制
                if (IsOnDrawing(e))
                {
                    //选择绘制的通道
                    Color targetColor = new Color (1f, 0f, 0f, 0f);

                    if (mode == PaintMode.Texture)
                    {
                        switch (selTex)
                        {
                            case 0:
                                targetColor = new Color(1f, 0f, 0f, 0f);
                                break;
                            case 1:
                                targetColor = new Color(0f, 1f, 0f, 0f);
                                break;
                            case 2:
                                targetColor = new Color(0f, 0f, 1f, 0f);
                                break;
                            case 3:
                                targetColor = new Color(0f, 0f, 0f, 1f);
                                break;

                        }
                    }
                    else
                    {
                        targetColor = isUndo ? Color.clear : targetColor;
                    }

                    Vector2 pixelUV = raycastHit.textureCoord;
                    if (offset != Vector3.zero)
                    {
                        offset = currentSelect.transform.rotation * offset;
                        MeshFilter meshFilter = currentSelect.GetComponent<MeshFilter>();
                        float mSize = meshSize;
                        if (meshFilter)
                            mSize = meshFilter.sharedMesh.bounds.size.x;
                        pixelUV -= new Vector2(offset.x, offset.z) / mSize;
                        //brushSizeInPourcent = (int)Mathf.Round((brushSize * controlTex.width ) / 2000);

                    }
                    if (needUpdateBrushInfo || currBrushCacheSize != brushSizeInPourcent)
                    {
                        needUpdateBrushInfo = false;
                        currBrushCacheSize = brushSizeInPourcent;
                        float angle = (Quaternion.AngleAxis(180, Vector3.forward) * brushQua).eulerAngles.y + 90;
                        float halfSize = brushSizeInPourcent / 2.0f;

                        float sina = Mathf.Sin(Mathf.Deg2Rad * angle) * halfSize;
                        float cosa = Mathf.Cos(Mathf.Deg2Rad * angle) * halfSize;
                        Vector2 nLt, nRt, nLb, nRb;
                        nLt = new Vector2(-cosa + sina, sina + cosa);
                        nRt = new Vector2(cosa + sina, -sina + cosa);
                        nLb = new Vector2(-cosa - sina, sina - cosa);
                        nRb = new Vector2(cosa - sina, -sina - cosa);

                        brushWidth = Mathf.CeilToInt(Mathf.Max(Mathf.Abs(nRb.x - nLt.x), Mathf.Abs(nRt.x - nLb.x)));
                        brushHeight = Mathf.CeilToInt(Mathf.Max(Mathf.Abs(nRb.y - nLt.y), Mathf.Abs(nRt.y - nLb.y)));

                        brushAlphas = new float[brushWidth * brushHeight];
                        Texture2D TBrush = brushTex[selBrush] as Texture2D; //获取笔刷性状贴图

                        float ux, uy;
                        sina = Mathf.Sin(Mathf.Deg2Rad * (360 - angle));
                        cosa = Mathf.Cos(Mathf.Deg2Rad * (360 - angle));
                        for (int i = 0; i < brushHeight; i++)
                        {
                            for (int j = 0; j < brushWidth; j++)
                            {
                                ux = (j - brushWidth / 2) * cosa + (-i + brushHeight / 2) * sina + halfSize;
                                uy = -(j - brushWidth / 2) * sina + (-i + brushHeight / 2) * cosa + halfSize;
                                if (ux > brushSizeInPourcent || ux < 0 || uy > brushSizeInPourcent || uy < 0)
                                {
                                    brushAlphas[i * brushWidth + j] = 0;
                                    continue;
                                }
                                brushAlphas[i * brushWidth + j] = TBrush.GetPixelBilinear(uy / brushSizeInPourcent, ux / brushSizeInPourcent, 0).a;
                            }
                        }
                    }

                    int halfH = brushWidth / 2;
                    int halfW = brushHeight / 2;
                    //计算笔刷所覆盖的区域
                    int PuX = Mathf.FloorToInt (pixelUV.x * controlTex.width);
                    int PuY = Mathf.FloorToInt (pixelUV.y * controlTex.height);
                    int x = Mathf.Clamp (PuX - halfW, 0, controlTex.width - 1);
                    int y = Mathf.Clamp (PuY - halfH, 0, controlTex.height - 1);
                    int width = Mathf.Clamp (PuX + halfW, 0, controlTex.width) - x;
                    int height = Mathf.Clamp (PuY + halfH, 0, controlTex.height) - y;

                    Color[] terrainBay = controlTex.GetPixels (x, y, width, height, 0); //获取Control贴图被笔刷所覆盖的区域的颜色

                    int fixX, fixY;
                    int index;
                    float brushA;
                    int sX = PuX - halfW;
                    int sY = PuY - halfH;
                    //Debug.LogErrorFormat("{0},{1},{2},{3}", sX, sY, width, height);
                    //根据笔刷贴图计算笔刷的透明度
                    for (int i = 0; i < brushHeight; i++)
                    {
                        fixY = sY + i;
                        if (fixY < 0 || fixY >= controlTex.height) continue;
                        if (sY < 0) fixY = i + sY;
                        else fixY = i;
                        for (int j = 0; j < brushWidth; j++)
                        {
                            fixX = sX + j;
                            if (fixX >= 0 && fixX < controlTex.width)
                            {
                                if (sX < 0) fixX = j + sX;
                                else fixX = j;
                                brushA = brushAlphas[i * brushWidth + j];
                                if (brushA > 0)
                                {
                                    index = fixY * width + fixX;
                                    if(index < terrainBay.Length)
                                        terrainBay[index] = Color.Lerp(terrainBay[index], targetColor, brushA * brushStronger);
                                }
                            }
                        }
                    }
                    if (!drawTexs.Contains(controlTex))
                    {
                        drawTexs.Add(controlTex);
                        Undo.RegisterCompleteObjectUndo(controlTex, "meshPaint"); //保存历史记录以便撤销
                    }                        

                    controlTex.SetPixels (x, y, width, height, terrainBay, 0); //把绘制后的Control贴图保存起来
                    controlTex.Apply ();
                    ToggleF = true;
                }
                else if (e.type == EventType.MouseUp && e.alt == false && ToggleF == true)
                {
                    SaveTexture (); //绘制结束保存Control贴图
                    ToggleF = false;
                }
            }

            float time = 0;
            //在地表刷模型
            void DrawModel (Event e, RaycastHit raycastHit, GameObject currentSelect, float randomRange)
            {
                if (prefab == null)
                {
                    return;
                }
                //鼠标按下或者拖动
                if ((e.type == EventType.MouseDrag || e.type == EventType.MouseDown) && e.alt == false && e.shift == false && e.control == false && e.button == 0)
                {
                    time += Time.deltaTime;
                    float timeThe = (1 - brushStronger) * 5;
                    if (time > timeThe)
                    {
                        Vector3 pos = raycastHit.point + new Vector3 (Random.Range (-randomRange, randomRange), 0, Random.Range (-randomRange, randomRange));

                        Quaternion rot;
                        if (rotateFollowTerrain)
                        {
                            rot = Quaternion.LookRotation (raycastHit.normal);
                        }
                        else
                        {
                            rot = Quaternion.LookRotation (Vector3.up);
                        }
                        GameObject go = Instantiate (prefab, pos, rot);
                        go.transform.parent = currentSelect.transform;

                        //随机旋转
                        float randomRangeX = prefabRotateRandomX * 90;
                        float randomRangeY = prefabRotateRandomY * 90;
                        float randomRangeZ = prefabRotateRandomZ * 90;
                        Vector3 randomRot = new Vector3 (Random.Range (-randomRangeX, randomRangeX), Random.Range (-randomRangeY, randomRangeY), Random.Range (-randomRangeZ, randomRangeZ));
                        go.transform.Rotate (randomRot);

                        //随机大小
                        go.transform.localScale *= Random.Range (1 - prefabSizeRandom, 1 + prefabSizeRandom);

                        time = 0;
                    }

                }
            }

            void DrawCircle (Vector3 center, Vector3 normal, float size)
            {
                Handles.color = Color.yellow; //颜色
                Handles.DrawWireDisc (center, normal, size); //根据笔刷大小在鼠标位置显示一个圆
                Handles.color = new Color (1, 0.2f, 0.2f, 1); //颜色
                Handles.DrawWireArc (center, normal, Vector3.right, brushStronger * 360, size + size * 0.05f);
                Handles.color = Color.white;
                Vector3 lineCenter = center + brushQua * Vector3.back * size * 1.1f;
                Handles.DrawLine(lineCenter + brushQua * Vector3.left * size / 2, lineCenter + brushQua * Vector3.right * size / 2);
                if (_brushDrawTran)
                {
                    _brushDrawTran.transform.position = center + _brushShowOffset;
                    _brushMaterial.SetTexture(_brushTexId, brushTex[selBrush]);
                    _brushDrawTran.transform.localScale = Vector3.one * brushSizeInPourcent / 12f;
                    _brushDrawTran.transform.rotation = brushQua * _brushShowRot;
                }
            }
            public void SaveTexture ()
            {
                foreach (Texture2D tex in drawTexs)
                {
                    var path = AssetDatabase.GetAssetPath(tex);
                    var bytes = tex.EncodeToTGA();
                    File.WriteAllBytes(path, bytes);
                    //AssetDatabase.Refresh();
                    //AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);//刷新
                    AssetDatabase.SaveAssets();
                }
                drawTexs.Clear();
            }

            private Transform _brushDrawTran = null;
            private Material _brushMaterial;
            private Vector3 _brushShowOffset = new Vector3(0, 0.1f, 0);
            private Quaternion _brushShowRot = Quaternion.AngleAxis(90, Vector3.right);
            private int _brushTexId = Shader.PropertyToID("_BaseMap");

            private void OnDestroy()
            {
                isPaint = false;
                OnIsPaintChange();
            }

            private void OnIsPaintChange()
            {
                needUpdateBrushInfo = true;
                if (isPaint)
                {
                    if(_brushDrawTran == null)
                    {
                        GameObject bGo = GameObject.Find("_brush");
                        if(bGo == null)
                        {
                            bGo = Instantiate(AssetDatabase.LoadAssetAtPath<GameObject>("Assets/MeshPainter/Brush.prefab"));
                            bGo.name = "_brush";
                            _brushDrawTran = bGo.transform;
                        }
                        else
                        {
                            _brushDrawTran = bGo.transform;
                        }
                        _brushMaterial = _brushDrawTran.GetComponent<MeshRenderer>().sharedMaterial;
                    }
                    Transform Select = Selection.activeTransform;
                    MeshFilter meshFilter = Select.GetComponent<MeshFilter>();
                    if (meshFilter)
                        meshSize = meshFilter.sharedMesh.bounds.size.x;
                }
                else
                {
                    if(_brushDrawTran!= null)
                    {
                        GameObject.DestroyImmediate(_brushDrawTran.gameObject);
                        _brushDrawTran = null;
                    }
                    else
                    {
                        GameObject bGo = GameObject.Find("_brush");
                        if(bGo!= null)
                        {
                            GameObject.DestroyImmediate(bGo);
                        }
                    }
                }
            }
        }
#endif
    }

}