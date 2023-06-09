using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;
using System;

//Ϊɶ�����϶���?
//unity �༭mesh����λ�� https://blog.csdn.net/zgjllf1011/article/details/79305756
public class ModelMeshEditor : MonoBehaviour
{
    //���Ƶ�Ĵ�С
    public float pointScale = 1.0f;
    private float lastPointScale = 1.0f;
    Mesh mesh;
    //�����б�
    List<Vector3> positionList = new List<Vector3>();
    //������������б�
    List<GameObject> positionObjList = new List<GameObject>();
    /// <summary>/// key:�����ַ���/// value:�������б��е�λ��/// </summary>
    Dictionary<string, List<int>> pointmap = new Dictionary<string, List<int>>();
    // Use this for initialization
    void Start()
    {
        lastPointScale = pointScale;
        mesh = GetComponent<MeshFilter>().sharedMesh;
        CreateEditorPoint();
    }
    //�������Ƶ�
    public void CreateEditorPoint()
    {
        positionList = new List<Vector3>(mesh.vertices);
        //Debug.Log("CreateEditorPoint vertices.len:" + mesh.vertices.Length);
        for (int i = 0; i < mesh.vertices.Length; i++)
        {
            string vstr = Vector2String(mesh.vertices[i]);
            if (!pointmap.ContainsKey(vstr))
            {
                pointmap.Add(vstr, new List<int>());
            }
            pointmap[vstr].Add(i);
        }
        foreach (string key in pointmap.Keys)
        {
            GameObject editorpoint = (GameObject)Resources.Load("Prefabs/MeshEditor/MeshEditorPoint");
            editorpoint = Instantiate(editorpoint);
            editorpoint.transform.parent = transform;
            editorpoint.transform.localPosition = String2Vector(key);
            editorpoint.transform.localScale = new Vector3(1f, 1f, 1f);
            MeshEditorPoint editorPoint = editorpoint.GetComponent<MeshEditorPoint>();
            editorPoint.onMove = PointMove;
            editorPoint.pointid = key;
            positionObjList.Add(editorpoint);

            //Debug.Log("CreateEditorPoint editorPoint key:" + key);
        }
    }
    //�������屻�ƶ�ʱ���ô˷���
    public void PointMove(string pointid, Vector3 position)
    {
        if (!pointmap.ContainsKey(pointid))
        {
            return;
        }
        List<int> _list = pointmap[pointid];
        for (int i = 0; i < _list.Count; i++)
        {
            positionList[_list[i]] = position;
        }
        mesh.vertices = positionList.ToArray();
        mesh.RecalculateNormals();
    }
    // Update is called once per frame
    void Update()
    {
        //�����Ƶ�ߴ��Ƿ�ı�
        if (Math.Abs(lastPointScale - pointScale) > 0.1f)
        {
            lastPointScale = pointScale;
            for (int i = 0; i < positionObjList.Count; i++)
            {
                positionObjList[i].transform.localScale = new Vector3(pointScale, pointScale, pointScale);
            }
        }
    }
    string Vector2String(Vector3 v)
    {
        StringBuilder str = new StringBuilder();
        str.Append(v.x).Append(",").Append(v.y).Append(",").Append(v.z);
        return str.ToString();
    }
    Vector3 String2Vector(string vstr)
    {
        try
        {
            string[] strings = vstr.Split(',');
            return new Vector3(float.Parse(strings[0]), float.Parse(strings[1]), float.Parse(strings[2]));
        }
        catch (Exception e)
        {
            Debug.LogError(e.ToString());
            return Vector3.zero;
        }
    }
}