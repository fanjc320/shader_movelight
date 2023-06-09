using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class MeshEditorPoint : MonoBehaviour
{//����id���������ʼλ��ת�ַ�����
    [HideInInspector] public string pointid;//��¼�������һ���ƶ���λ�ã������жϿ��Ƶ��Ƿ��ƶ�
    [HideInInspector] private Vector3 lastPosition;
    public delegate void MoveDelegate(string pid, Vector3 pos);//���Ƶ��ƶ�ʱ�Ļص�
    public MoveDelegate onMove = null;// Use this for initialization
    void Start()
    {
        lastPosition = transform.position;
    }
    // Update is called once per frame
    void Update()
    {
        if (transform.position != lastPosition)
        {
            if (onMove != null)
                onMove(pointid, transform.localPosition);
            lastPosition = transform.position;
        }
    }
}