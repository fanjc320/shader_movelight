using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//https://zhuanlan.zhihu.com/p/447424772
public class ExtractBindPoseInfo : MonoBehaviour
{
    [HideInInspector]
    [SerializeField]
    public Matrix4x4[] bindPoses;
    [HideInInspector]
    public Vector3[] vertices;
    [HideInInspector]
    public Vector4[] tangents;
    [HideInInspector]
    public Vector3[] normals;
    [HideInInspector]
    public BoneWeight[] boneWeights;
    [HideInInspector]
    public int[] triangles;

    [HideInInspector]
    public Transform[] bones;

    public SkinnedMeshRenderer target;


    [ContextMenu("Extract Bind Pose")]
    void ExtractBindPose()
    {
        Debug.Log("ExtractBindPose target:" + target + " target.sharedMesh:" + target.sharedMesh);
        if (target && target.sharedMesh)
        {
            bindPoses = target.sharedMesh.bindposes;
            vertices = target.sharedMesh.vertices;
            boneWeights = target.sharedMesh.boneWeights;
            normals = target.sharedMesh.normals;
            tangents = target.sharedMesh.tangents;
            triangles = target.sharedMesh.triangles;
            bones = target.bones;


            Debug.Log("ExtractBindPose target.sharedMesh.bindposes.len:" + target.sharedMesh.bindposes.Length);
            Debug.Log("ExtractBindPose target.sharedMesh.vertices.len:" + target.sharedMesh.vertices.Length);
            Debug.Log("ExtractBindPose target.sharedMesh.boneWeights.len:"+ target.sharedMesh.boneWeights.Length);
            Debug.Log("ExtractBindPose target.sharedMesh.normals.len:" + target.sharedMesh.normals.Length);
            Debug.Log("ExtractBindPose target.sharedMesh.tangents.len:" + target.sharedMesh.tangents.Length);
            Debug.Log("ExtractBindPose target.sharedMesh.triangles.len:" + target.sharedMesh.triangles.Length);
            Debug.Log("ExtractBindPose target.bones.len:" + target.bones.Length);
        }
    }

    /// <summary>
    /// 蒙皮矩阵：每根骨骼对应一个蒙皮矩阵，把其影响的顶点从bindpose转换到目前的pose
    /// </summary>
    /// <returns></returns>
    Matrix4x4[] SkinningMatrices()
    {
        Matrix4x4[] skinningMatrices = new Matrix4x4[bindPoses.Length];
        for (int i = 0; i < bindPoses.Length; i++)
        {
            Transform bone = bones[i];
            Matrix4x4 currentBoneWorldTransformationMatrix;
            if (bone)
            {
                currentBoneWorldTransformationMatrix = bone.localToWorldMatrix;
            }
            else
            {
                currentBoneWorldTransformationMatrix = target.transform.localToWorldMatrix * bindPoses[i].inverse;
            }
            skinningMatrices[i] = currentBoneWorldTransformationMatrix * bindPoses[i];
        }
        return skinningMatrices;
    }

    void BakeOnCurrentPose(out Vector3[] poseVerts, out Vector3[] poseNormals, out Vector4[] poseTangents)
    {

        int numVerts = vertices.Length;
        poseVerts = new Vector3[numVerts];
        poseNormals = new Vector3[numVerts];
        poseTangents = new Vector4[numVerts];
        Matrix4x4[] skinningMatrices = SkinningMatrices();

        for (int i = 0; i < numVerts; i++)
        {
            Debug.Log("BakeOnCurrentPose boneWeights len:" + boneWeights.Length + " numVerts:" + numVerts);
            BoneWeight boneWeight = boneWeights[i];
            Vector4 vert = vertices[i];
            vert.w = 1;

            Matrix4x4 skinningMatrix0 = skinningMatrices[boneWeight.boneIndex0];
            Matrix4x4 skinningMatrix1 = skinningMatrices[boneWeight.boneIndex1];
            Matrix4x4 skinningMatrix2 = skinningMatrices[boneWeight.boneIndex2];
            Matrix4x4 skinningMatrix3 = skinningMatrices[boneWeight.boneIndex3];

            float weight0 = boneWeight.weight0;
            float weight1 = boneWeight.weight1;
            float weight2 = boneWeight.weight2;
            float weight3 = boneWeight.weight3;

            Vector3 pos0 = skinningMatrix0 * vert;
            Vector3 pos1 = skinningMatrix1 * vert;
            Vector3 pos2 = skinningMatrix2 * vert;
            Vector3 pos3 = skinningMatrix3 * vert;

            Vector3 pos = pos0 * weight0 + pos1 * weight1 + pos2 * weight2 + pos3 * weight3;

            Vector3 norm = normals[i];

            Vector3 normal0 = skinningMatrix0 * norm;
            Vector3 normal1 = skinningMatrix1 * norm;
            Vector3 normal2 = skinningMatrix2 * norm;
            Vector3 normal3 = skinningMatrix3 * norm;

            Vector3 normal = normal0 * weight0 + normal1 * weight1 + normal2 * weight2 + normal3 * weight3;

            Vector4 tan = tangents[i];

            Vector3 tangent0 = skinningMatrix0 * tan;
            Vector3 tangent1 = skinningMatrix1 * tan;
            Vector3 tangent2 = skinningMatrix2 * tan;
            Vector3 tangent3 = skinningMatrix3 * tan;

            Vector4 tangent = tangent0 * weight0 + tangent1 * weight1 + tangent2 * weight2 + tangent3 * weight3;
            tangent.w = tan.w;

            poseVerts[i] = pos;
            poseNormals[i] = normal;
            poseTangents[i] = tangent;
        }
    }

    bool drawEdges = true;
    bool drawTangents = false;
    bool drawNormals = false;
    private void OnDrawGizmos()
    {

        Vector3[] bakedVerts;
        Vector3[] bakedNormals;
        Vector4[] bakedTangents;

        BakeOnCurrentPose(out bakedVerts, out bakedNormals, out bakedTangents);

        if (drawEdges)
        {
            Gizmos.color = Color.gray;
            for (int i = 0; i < triangles.Length; i += 3)
            {
                int vertIndex0 = triangles[i];
                int vertIndex1 = triangles[i + 1];
                int vertIndex2 = triangles[i + 2];
                Gizmos.DrawLine(bakedVerts[vertIndex0], bakedVerts[vertIndex1]);
                Gizmos.DrawLine(bakedVerts[vertIndex1], bakedVerts[vertIndex2]);
                Gizmos.DrawLine(bakedVerts[vertIndex0], bakedVerts[vertIndex2]);
            }
        }
        if (drawTangents)
        {
            Gizmos.color = Color.blue;
            for (int i = 0; i < bakedVerts.Length; i++)
            {
                Gizmos.DrawRay(bakedVerts[i], bakedTangents[i] * 0.1f);
            }
        }
        if (drawNormals)
        {
            Gizmos.color = Color.green;
            for (int i = 0; i < bakedVerts.Length; i++)
            {
                Gizmos.DrawRay(bakedVerts[i], bakedNormals[i] * 0.1f);
            }
        }
    }
}
