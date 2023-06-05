using Assets;
using ES30;
using OpenTK.Graphics.ES30;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Rendering;

public class nativeRenderer : MonoBehaviour
{
    public RenderTexture rt;
    // Start is called before the first frame update
    void Start()
    {
        if (rt == null) 
            rt = new RenderTexture(256, 256, 32, RenderTextureFormat.ARGB32);
        Debug.Log("rtptr=" + rt.GetNativeTexturePtr());
        // if (Application.platform == RuntimePlatform.WindowsEditor)
        {//only for windows editor fornow.
            GLES3_Unity.OnInitUnsafe += OnRenderThreadInit;
            GLES3_Unity.OnRenderUnsafe += OnRenderThreadUpdate;
            GLES3_Unity.Init(rt);
        }
    }

    void OnRenderThreadInit()
    {
        var str = GLES3_Unity.R_GetVersion();
        Debug.Log("glGetString result=" + str);


    }
    void OnRenderThreadUpdate()
    {
        GLES3_Unity.R_Clear();
        Debug.Log("update");
    }
    void Update()
    {
        if (GLES3_Unity.Inited)
            GLES3_Unity.OnFrame();
    }

    private void OnGUI()
    {
        GUIUtility.ScaleAroundPivot(new Vector2(2, 2), Vector2.zero);
        GUILayout.Label("从project setting 里面 windows 可以切到GLES3，别的渲染器删掉，再来跑这个");
    }

}
