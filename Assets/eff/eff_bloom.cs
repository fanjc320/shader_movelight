using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;


class effect_bloom : IEffect
{

    public string Name => "bloom";

    public bool MatEdit => true;

    public Shader[] shaders
    {
        get;
        private set;
    }
    Material[] mats;

    public effect_bloom()
    {
        shaders = new Shader[4];

        shaders[0] = Shader.Find("Simple/Bloom_Gray");
        shaders[1] = Shader.Find("Simple/Bloom_Blur");
        shaders[2] = Shader.Find("Simple/Bloom_Blur");
        shaders[3] = Shader.Find("Simple/Bloom");
        mats = new Material[shaders.Length];
        for (var i = 0; i < shaders.Length;i++)
        {
            mats[i] = new Material(shaders[i]);
        }
    }
    public void OnRenderImage(RenderTexture source, RenderTexture destination, RenderTexture custom)
    {
        RenderTexture blur1 = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
        RenderTexture blur2 = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);

        Graphics.Blit(source, blur1, mats[0]);

        Graphics.Blit(blur1, blur2, mats[1]);
        Graphics.Blit(blur2, blur1, mats[2]);
        Graphics.Blit(blur1, blur2, mats[1]);
        Graphics.Blit(blur2, blur1, mats[2]);


        mats[3].SetTexture("_bloomTex", blur1);
        mats[3].SetTexture("_customTex", custom);
        Graphics.Blit(source, destination, mats[3]);
        
        RenderTexture.ReleaseTemporary(blur1);
        RenderTexture.ReleaseTemporary(blur2);
    }

    public void UpdateMat(Material mat, int index = 0)
    {
        mats[index].CopyPropertiesFromMaterial(mat);
    }
}

