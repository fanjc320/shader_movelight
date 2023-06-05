using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using Unity.VisualScripting;
using UnityEngine;
using System.Reflection;
using static Unity.VisualScripting.Member;


[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class posteff_simple : MonoBehaviour
{
    Camera customcamera;
    Camera srccamera;
    private void OnPreRender()
    {
        if (customcamera == null)
        {
            srccamera = this.GetComponent<Camera>();
            srccamera.depthTextureMode = DepthTextureMode.None;
            customcamera = new GameObject("Test", typeof(Camera)).GetComponent<Camera>();
            customcamera.depthTextureMode = DepthTextureMode.None;
            customcamera.enabled = false;
            customcamera.renderingPath = RenderingPath.Forward;
            customcamera.gameObject.hideFlags = HideFlags.HideAndDontSave;
        }
        if (outputw > 0)
        {
            customcamera.CopyFrom(srccamera);
            cwrt = RenderTexture.GetTemporary(outputw, outputh, 24, outformat);
            customcamera.targetTexture = cwrt;

            customcamera.clearFlags = CameraClearFlags.SolidColor;
            customcamera.RenderWithShader(Shader.Find("Simple/CustomWrite"), "CustomWrite");
            customcamera.clearFlags = CameraClearFlags.Nothing;

            customcamera.targetTexture = null;
            RenderTexture.ReleaseTemporary(cwrt);
        }
    }
    RenderTexture cwrt;
    int outputw;
    int outputh;
    RenderTextureFormat outformat;
    RenderTexture myrt1;
    [ExecuteInEditMode]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (useEffects == null)
            return;

        outputw = source.width;
        outputh = source.height;
        outformat = source.format;
        myrt1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

        RenderTexture old = source;
        RenderTexture from = old;
        RenderTexture to = myrt1;
        int count = useEffects.Count;
        if (useEffects != null && count != 0)
        {
            for (var i = 0; i < count - 1; i++)
            {
                //this.GetComponent<Camera>().targetTexture = from;
                useEffects[i].OnRenderImage(from, to, cwrt);

                if (from == old) from = myrt1;
                else from = old;

                if (to == old) to = myrt1;
                else to = old;
            }
            useEffects[count - 1].OnRenderImage(from, destination, cwrt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
        RenderTexture.ReleaseTemporary(myrt1);

    }
    List<IEffect> useEffects;
    public List<EffInfo> effInfo;
    public List<IEffect> allEffects;

    // Start is called before the first frame update
    void Start()
    {
        ResetEffect();
    }
    void InitEffect()
    {
        if (allEffects == null)
        {//初始化alleffect
            allEffects = new List<IEffect>();
            allEffects.Add(new SingleEffect("water", "Simple/Water", true));
            allEffects.Add(new effect_bloom());
            allEffects.Add(new SingleEffect("gray", "Simple/Gray"));
        }

        //同步材质数据
        if (effInfo == null)
            effInfo = new List<EffInfo>();

        Dictionary<string, EffInfo> oldinfos = new Dictionary<string, EffInfo>();
        if (effInfo.Count > 0)
        {
            foreach (var info in effInfo)
            {
                oldinfos.Add(info.name, info);
            }
        }

        effInfo.Clear();
        for (var i = 0; i < allEffects.Count; i++)
        {
            var eff = allEffects[i];
            var b = oldinfos.TryGetValue(eff.Name, out EffInfo old);
            var einfo = b ? old : new EffInfo();
            if (einfo.name != eff.Name)
            {
                einfo.name = eff.Name;
                einfo.Enable = true;
            }

            if (einfo.mats == null || einfo.mats.Length != eff.shaders.Length)
            {
                einfo.mats = new Material[eff.shaders.Length];
                for (var j = 0; j < eff.shaders.Length; j++)
                {
                    einfo.mats[j] = new Material(eff.shaders[j]);
                }
            }
            //检查shader
            for (var j = 0; j < eff.shaders.Length; j++)
            {
                if (einfo.mats[j].shader != eff.shaders[j])
                    einfo.mats[j] = new Material(eff.shaders[j]);
            }

            effInfo.Add(einfo);
        }




    }
    public void ResetEffect()
    {
        InitEffect();
        if (useEffects == null)
            useEffects = new List<IEffect>();
        useEffects.Clear();
        //这个得保证顺序
        for (var i = 0; i < allEffects.Count; i++)
        {
            if (effInfo[i].Enable)
            {
                useEffects.Add(allEffects[i]);
            }
        }
    }
    // Update is called once per frame
    void Update()
    {
        if (allEffects == null)
            return;
        for (var i = 0; i < allEffects.Count; i++)
        {
            var eff = allEffects[i];

            if (eff.MatEdit)
            {
                var info = effInfo[i];
                for (var j = 0; j < info.mats.Length; j++)
                {
                    eff.UpdateMat(info.mats[j], j);
                }
            }
        }
    }
}




