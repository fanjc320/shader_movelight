using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class drawinstance : MonoBehaviour
{

    public Material instanceMat;//参数输入：材质
    public Mesh instanceMesh;//参数输入：模型
    Matrix4x4[] matrices;//绘制位置
    //Vector4[] colors;
    MaterialPropertyBlock block;

    void BuildMatrixAndBlock()
    {
        block = new MaterialPropertyBlock();
        matrices = new Matrix4x4[1023];
        Vector4[] colors = new Vector4[1023];
        for (var i = 0; i < 32; i++)
        {
            for (var j = 0; j < 32; j++)
            {
                var ind = j * 32 + i;
                if (ind >= 1023) break;
                matrices[ind] = Matrix4x4.TRS(new Vector3(i, j, 0), Quaternion.identity, Vector3.one);
                colors[ind] = new Vector4(1 - i / 32.0f, 1 - j / 32.0f, 1, 1);

            }
        }
        block.SetVectorArray("_Color", colors);
    }
    bool option;
    private void OnGUI()
    {
        var support = SystemInfo.supportsInstancing;

        GUILayout.Label("是否支持Instance渲染 = " + support);
        bool newop = GUILayout.Toggle(option, "使用commandbuffer");
        if(newop!=option)
        {
            option = newop;
            if (option == true)
            {
                UnityEngine.Rendering.CommandBuffer buffer = new UnityEngine.Rendering.CommandBuffer();
                buffer.DrawMeshInstanced(instanceMesh, 0, instanceMat, 0, matrices, 1023, block);
                Camera.main.AddCommandBuffer(UnityEngine.Rendering.CameraEvent.AfterForwardOpaque, buffer);
            }
            else
            {
                Camera.main.RemoveAllCommandBuffers();
            }
        }
    }
    void Start()
    {
        BuildMatrixAndBlock();
        var support = SystemInfo.supportsInstancing;
        Debug.Log("是否支持Instance渲染 = " + support);
    }

    // Update is called once per frame
    void Update()
    {
        if(!option)
        {
            Graphics.DrawMeshInstanced(instanceMesh, 0, instanceMat, matrices, 1023, block,UnityEngine.Rendering.ShadowCastingMode.Off,false);
        }
    }
}
