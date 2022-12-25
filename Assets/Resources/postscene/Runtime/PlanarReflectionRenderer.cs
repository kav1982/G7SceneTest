using System;
using System.Collections.Generic;
using BioumRP;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Serialization;


[ExecuteInEditMode]
public class PlanarReflectionRenderer : MonoBehaviour
{
    public Dictionary<Camera, Camera> reflectionCameras = new Dictionary<Camera, Camera>();
    
    //Rendering
    [Tooltip("Set the layers that should be rendered into the reflection. The \"Water\" layer is always excluded")]
    public LayerMask cullingMask = -1;
    [Tooltip("The renderer used by the reflection camera. It's recommend to create a separate renderer, so any custom render features aren't executed for the reflection")]
    public int rendererIndex = -1;

    public float offset = 0.00f;
    [Tooltip("When disabled, the skybox reflection comes from a Reflection Probe. This has the benefit of being omni-directional rather than flat/planar. Enabled this to render the skybox into the planar reflection anyway")]
    public bool includeSkybox;

    //Quality
    [Tooltip("Objects beyond this range aren't rendered into the reflection. Note that this may causes popping for large/tall objects.")]
	public float renderRange = 200f;
    [Range(0.1f, 1f)] 
    [Tooltip("A multiplier for the rendering resolution, based on the current screen resolution")]
	public float renderScale = 0.5f;

    List<PlanarReflectionObject> reflectionObjects = new List<PlanarReflectionObject>();
    [HideInInspector]
    public Bounds bounds;

    private Camera reflectionCamera;
    private static RenderTexture currentBuffer;
    private float m_renderScale = 1f;
    private float m_renderRange;
    private static bool m_reflectionsEnabled;
    public static bool ReflectionsEnabled { get { return m_reflectionsEnabled; } }
    private static int _PlanarReflectionsEnabledID = Shader.PropertyToID("_PlanarReflectionsEnabled");
    private static int _PlanarReflectionTextureID = Shader.PropertyToID("_PlanarReflectionTexture");
	private static UniversalAdditionalCameraData cameraData;
    
    private void OnEnable()
    {
        reflectionObjects = PlanarReflectionObjectList.instance.Get();
        RecalculateBounds();
        InitializeValues();

        //ShaderLevel.LevelChanged += SetQuality;
        PlanarReflectionObjectList.OnListChanged += ToggleMaterialReflectionSampling;
        PlanarReflectionObjectList.OnListChanged += RecalculateBounds;
        EnableReflections();
    }

    private void OnDisable()
    {
        //ShaderLevel.LevelChanged -= SetQuality;
        PlanarReflectionObjectList.OnListChanged -= ToggleMaterialReflectionSampling;
        PlanarReflectionObjectList.OnListChanged -= RecalculateBounds;
        DisableReflections();
    }

    public void InitializeValues()
    {
        m_renderScale = renderScale;
        m_renderRange = renderRange;
    }
    
    void SetQuality()
    {
        bool enableReflection = false;
        float renderScale = 1;
        float renderRange = 1;
        //switch (ShaderLevel.CurrentLevel)
        //{
        //    case ShaderLevel.Level.High:
        //        enableReflection = true;
        //        renderScale = 1;
        //        renderRange = 1;
        //        break;
        //    case ShaderLevel.Level.Medium:
        //        enableReflection = true;
        //        renderScale = 0.75f;
        //        renderRange = 0.75f;
        //        break;
        //    case ShaderLevel.Level.Low:
        //        enableReflection = false;
        //        renderScale = 0.5f;
        //        renderRange = 0.5f;
        //        break;
        //    default: 
        //        enableReflection = false;
        //        renderScale = 1;
        //        renderRange = 1;
        //        break;
        //}

        UpdateQuality(enableReflection, renderScale, renderRange);
    }

    void UpdateQuality(bool enableReflection, float renderScale, float renderRange)
    {
        //this.renderScale *= renderScale;
        //this.renderRange *= renderRange;
        //InitializeValues();

        if (enableReflection) 
            EnableReflections();
        else 
            DisableReflections();
    }

    private bool enableMaterialKeyword;
    public void EnableReflections()
    {
        if (m_reflectionsEnabled) return;

        RenderPipelineManager.beginCameraRendering += OnWillRenderCamera;
        enableMaterialKeyword = true;
        ToggleMaterialReflectionSampling();
        m_reflectionsEnabled = true;
    }

    public void DisableReflections()
    {
        if (!m_reflectionsEnabled) return;

        RenderPipelineManager.beginCameraRendering -= OnWillRenderCamera;
        enableMaterialKeyword = false;
        ToggleMaterialReflectionSampling();
        m_reflectionsEnabled = false;

        //Clear cameras
        foreach (var kvp in reflectionCameras)
        {
            if (kvp.Value == null) continue;

            if (kvp.Value)
            {
                RenderTexture.ReleaseTemporary(kvp.Value.targetTexture);
                DestroyImmediate(kvp.Value.gameObject);
            }
        }

        reflectionCameras.Clear();
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireCube(bounds.center, bounds.size);
    }

    Bounds CalculateBounds()
    {
        Bounds m_bounds = new Bounds(Vector3.zero, Vector3.zero);
        
        if (reflectionObjects == null) return m_bounds;
        if (reflectionObjects.Count == 0) return m_bounds;

        if (reflectionObjects.Count == 1) return reflectionObjects[0].Bounds;

        m_bounds = reflectionObjects[0].Bounds;

        for (int i = 1; i < reflectionObjects.Count; i++)
        {
            if (reflectionObjects[i]) m_bounds.Encapsulate(reflectionObjects[i].Bounds);
        }
        
        return m_bounds;
    }

    public void RecalculateBounds()
    {
        bounds = CalculateBounds();
    }

    private void OnWillRenderCamera(ScriptableRenderContext context, Camera camera)
    {
#if SWS_DEV
        UnityEngine.Profiling.Profiler.BeginSample("Planar Reflections");
#endif
        //Skip for any special use camera's (except scene view camera)
        if (camera.cameraType != CameraType.SceneView && (camera.cameraType == CameraType.Reflection ||
                                                          camera.cameraType == CameraType.Preview ||
                                                          camera.hideFlags != HideFlags.None)) return;

        //Note: Scene camera still rendering even if window not focused!
        
        if (IsVisible(camera) == false) return;

        cameraData = camera.GetComponent<UniversalAdditionalCameraData>();
        if (cameraData && cameraData.renderType == CameraRenderType.Overlay) return;

        reflectionCameras.TryGetValue(camera, out reflectionCamera);
        if (reflectionCamera == null) CreateReflectionCamera(camera);
        
        //It's possible it is destroyed at this point when disabling reflections
        if (!reflectionCamera) return;
        
        UpdateWaterProperties(reflectionCamera);
        
        if (Mathf.Abs(renderScale - m_renderScale) > 0.01f)
        {
            RenderTexture.ReleaseTemporary(reflectionCamera.targetTexture);

            RenderTexture currentBuffer = GetRenderTexture(camera.scaledPixelWidth, camera.scaledPixelHeight);
            
            reflectionCamera.targetTexture = currentBuffer;
            
            m_renderScale = renderScale;
        }
        
        UpdatePerspective(camera, reflectionCamera);

#if UNITY_EDITOR
        //Screen pos outside of frustrum
        if (Vector3.Dot(Vector3.forward, reflectionCamera.transform.forward) > 0.9999f) return;
#endif
        reflectionCamera.clearFlags = includeSkybox ? CameraClearFlags.Skybox : CameraClearFlags.SolidColor;
        reflectionCamera.backgroundColor = Color.clear;
        
        GL.invertCulling = true;
        UniversalRenderPipeline.RenderSingleCamera(context, reflectionCamera);
        GL.invertCulling = false;
        
#if SWS_DEV
        UnityEngine.Profiling.Profiler.EndSample();
#endif
    }

    private float GetRenderScale()
    {
        return Mathf.Clamp(renderScale * UniversalRenderPipeline.asset.renderScale, 0.1f, 1f);
    }

    /// <summary>
    /// Should the renderer index be changed at runtime, this function must be called to update any reflection cameras
    /// </summary>
    /// <param name="index"></param>
    public void SetRendererIndex(int index)
    {
        index = PipelineUtilities.ValidateRenderer(index);

        foreach (var kvp in reflectionCameras)
        {
            if (kvp.Value == null) continue;
            
            cameraData = kvp.Value.GetComponent<UniversalAdditionalCameraData>();
            cameraData.SetRenderer(index);
        }
    }

    int GetCullingMask()
    {
        cullingMask = ~(1 << 4) & cullingMask;
        return cullingMask;
    }

    private void CreateReflectionCamera(Camera source)
    {
        GameObject go = new GameObject(source.name + "_PlanarReflectionCamera");
        go.hideFlags = HideFlags.HideAndDontSave;
        Camera newCamera = go.AddComponent<Camera>();
        newCamera.hideFlags = HideFlags.DontSave;
        newCamera.CopyFrom(source);
        //Always exclude water layer
        newCamera.cullingMask = GetCullingMask();
        //newCamera.cameraType = CameraType.Reflection; //Will cause shadow pass to execute twice?!
        newCamera.depth = -99f;
        newCamera.rect = new Rect(0,0,1,1);
        newCamera.enabled = false;
        newCamera.clearFlags = includeSkybox ? CameraClearFlags.Skybox : CameraClearFlags.SolidColor;
        newCamera.useOcclusionCulling = false;
        newCamera.backgroundColor = Color.clear;

        UniversalAdditionalCameraData data = newCamera.gameObject.AddComponent<UniversalAdditionalCameraData>();
        data.requiresDepthTexture = false;
        data.requiresColorTexture = false;
        data.renderShadows = false;

        rendererIndex = PipelineUtilities.ValidateRenderer(rendererIndex);
        data.SetRenderer(rendererIndex);


        currentBuffer = GetRenderTexture(source.scaledPixelWidth, source.scaledPixelHeight);
        newCamera.targetTexture = currentBuffer;
        //newCamera.forceIntoRenderTexture = true;
        
        reflectionCameras[source] = newCamera;
    }

    RenderTexture GetRenderTexture(int sourceWidth, int sourceHeight)
    {
        return RenderTexture.GetTemporary(
            Mathf.RoundToInt(sourceWidth * GetRenderScale()),
            Mathf.RoundToInt(sourceHeight * GetRenderScale()), 
            16, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
    }

    private static readonly Plane[] frustrumPlanes = new Plane[6];
    
    public bool IsVisible(Camera camera)
    {
        GeometryUtility.CalculateFrustumPlanes(camera.projectionMatrix, frustrumPlanes);

        return GeometryUtility.TestPlanesAABB(frustrumPlanes, bounds);
    }

    private void ToggleMaterialReflectionSampling()
    {
        if (reflectionObjects == null) return;

        for (int i = 0; i < reflectionObjects.Count; i++)
        {
            if (reflectionObjects[i] == null) continue;
            
            reflectionObjects[i].SetReflectionState(enableMaterialKeyword);
        }
    }

    //Assigns the render target of the current reflection camera
    private void UpdateWaterProperties(Camera cam)
    {
        for (int i = 0; i < reflectionObjects.Count; i++)
        {
            if (reflectionObjects[i] == null) continue;
            
            reflectionObjects[i].SetReflectionTexture(_PlanarReflectionTextureID, cam.targetTexture);
        }
    }

    private static Vector4 reflectionPlane;
    private static Matrix4x4 reflectionBase;
    private static Vector3 oldCamPos;

    private static Matrix4x4 worldToCamera;
    private static Matrix4x4 viewMatrix;
    private static Matrix4x4 projectionMatrix;
    private static Vector4 clipPlane;
    private static readonly float[] layerCullDistances = new float[32];
    
    private void UpdatePerspective(Camera source, Camera reflectionCamera)
    {
        if (!source || !reflectionCamera) return;

        Vector3 position = bounds.center;
        position.y = bounds.center.y - (bounds.size.y * 0.5f);
        position += Vector3.up * offset;

        var d = -Vector3.Dot(Vector3.up, position);
        reflectionPlane = new Vector4(Vector3.up.x, Vector3.up.y, Vector3.up.z, d);

        reflectionBase = Matrix4x4.identity;
        reflectionBase *= Matrix4x4.Scale(new Vector3(1, -1, 1));

        // View
        CalculateReflectionMatrix(ref reflectionBase, reflectionPlane);
        oldCamPos = source.transform.position - new Vector3(0, position.y * 2, 0);
        reflectionCamera.transform.forward = Vector3.Scale(source.transform.forward, new Vector3(1, -1, 1));

        worldToCamera = source.worldToCameraMatrix;
        viewMatrix = worldToCamera * reflectionBase;

        //Reflect position
        oldCamPos.y = -oldCamPos.y;
        reflectionCamera.transform.position = oldCamPos;

        clipPlane = CameraSpacePlane(reflectionCamera.worldToCameraMatrix, position - Vector3.up * 0.1f,
            Vector3.up, 1.0f);
        projectionMatrix = source.CalculateObliqueMatrix(clipPlane);
        
        //Settings
        reflectionCamera.cullingMask = GetCullingMask();

        //Only re-apply on value change
        if (m_renderRange != renderRange)
        {
            m_renderRange = renderRange;
            
            for (int i = 0; i < layerCullDistances.Length; i++)
            {
                layerCullDistances[i] = renderRange;
            }
        }
        
        reflectionCamera.projectionMatrix = projectionMatrix;
        reflectionCamera.worldToCameraMatrix = viewMatrix;
        reflectionCamera.layerCullDistances = layerCullDistances;
        reflectionCamera.layerCullSpherical = true;
    }

    // Calculates reflection matrix around the given plane
    private void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane)
    {
        reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
        reflectionMat.m01 = (-2F * plane[0] * plane[1]);
        reflectionMat.m02 = (-2F * plane[0] * plane[2]);
        reflectionMat.m03 = (-2F * plane[3] * plane[0]);

        reflectionMat.m10 = (-2F * plane[1] * plane[0]);
        reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
        reflectionMat.m12 = (-2F * plane[1] * plane[2]);
        reflectionMat.m13 = (-2F * plane[3] * plane[1]);

        reflectionMat.m20 = (-2F * plane[2] * plane[0]);
        reflectionMat.m21 = (-2F * plane[2] * plane[1]);
        reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
        reflectionMat.m23 = (-2F * plane[3] * plane[2]);

        reflectionMat.m30 = 0F;
        reflectionMat.m31 = 0F;
        reflectionMat.m32 = 0F;
        reflectionMat.m33 = 1F;
    }
    
    // Given position/normal of the plane, calculates plane in camera space.
    private Vector4 CameraSpacePlane(Matrix4x4 worldToCameraMatrix, Vector3 pos, Vector3 normal, float sideSign)
    {
        var offsetPos = pos + normal * offset;
        var cameraPosition = worldToCameraMatrix.MultiplyPoint(offsetPos);
        var cameraNormal = worldToCameraMatrix.MultiplyVector(normal).normalized * sideSign;
        return new Vector4(cameraNormal.x, cameraNormal.y, cameraNormal.z,
            -Vector3.Dot(cameraPosition, cameraNormal));
    }
}
