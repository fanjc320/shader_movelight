using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[Serializable]
public class EffInfo
{
    [DisplayOnly]
    public string name;
    public bool Enable;
    public Material[] mats;
}



public class DisplayOnly : PropertyAttribute
{

}
public interface IEffect
{
    string Name
    {
        get;

    }
    bool MatEdit
    {
        get;
    }
    Shader[] shaders
    {
        get;
    }
    void UpdateMat(Material mat, int index = 0);
    public abstract void OnRenderImage(RenderTexture source, RenderTexture destination, RenderTexture custom);
}

//SingleEffect 简单的根据shader名创建一个材质
public class SingleEffect : IEffect
{
    public string Name
    {
        get;
        private set;
    }
    public bool MatEdit
    {
        get;
        private set;
    }
    public Shader[] shaders
    {
        private set;
        get;
    }
    public void UpdateMat(Material mat, int index = 0)
    {
        this.mat.CopyPropertiesFromMaterial(mat);
        this.mat.shader = shaders[0];

    }
    public SingleEffect(string name, string shadername, bool matEditor = false)
    {
        shaders = new Shader[1] { Shader.Find(shadername) };
        this.mat = new Material(shaders[0]);
        this.MatEdit = matEditor;
        Name = name;
    }

    Material mat;

    public void OnRenderImage(RenderTexture source, RenderTexture destination, RenderTexture custom)
    {
        mat.SetTexture("_customTex", custom);
        Graphics.Blit(source, destination, mat);
    }
}