using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//https://stackoverflow.com/questions/60267552/unity-creating-blendshape-from-script-problem
public class TestAddBlendShape : MonoBehaviour
{

    public SkinnedMeshRenderer source;
    public SkinnedMeshRenderer target;

    // Start is called before the first frame update
    void Start()
    {
        Vector3[] verts = new Vector3[target.sharedMesh.vertexCount];

        source.sharedMesh.ClearBlendShapes();
        target.sharedMesh.ClearBlendShapes();

        // Calculate delta verts from source to target
        for (int i = 0; i < verts.Length; i++)
            verts[i] = target.sharedMesh.vertices[i] - source.sharedMesh.vertices[i];

        source.sharedMesh.AddBlendShapeFrame("test", 1, verts, null, null);

        source.sharedMesh.RecalculateNormals();
        source.sharedMesh.RecalculateTangents();
    }

    Bounds _selection;
    // Start is called before the first frame update

    void AddMorph(GameObject _ref, GameObject selection_mesh)
    {
        Mesh _m = new Mesh();

        // _selection - Bounds for selecting group of vertices within.
        _selection = new Bounds(selection_mesh.transform.position, selection_mesh.transform.localScale);

        // movement delta for future group of vertices.
        Vector3 newDelta = new Vector3(0, -0.4f, 0);

        // name for the future blend shape.
        string MorphName = "Custom[50-250]";

        //
        // Convert Mesh Renderer to Skinned Mesh Renderer, and create and instance of the shared mesh.
        //
        if (_ref.GetComponent<SkinnedMeshRenderer>() == null && _ref.GetComponent<MeshRenderer>() != null)
        {
            _m = Instantiate(_ref.GetComponent<MeshFilter>().sharedMesh);
            Destroy(_ref.GetComponent<MeshRenderer>());
            Destroy(_ref.GetComponent<MeshFilter>());
            _ref.AddComponent<SkinnedMeshRenderer>();
            _ref.GetComponent<SkinnedMeshRenderer>().sharedMesh = _m;
        }
        else if (_ref.GetComponent<SkinnedMeshRenderer>() != null) // Create instance of shared mesh.
        {
            _m = Instantiate(_ref.GetComponent<SkinnedMeshRenderer>().sharedMesh);
            _ref.GetComponent<SkinnedMeshRenderer>().sharedMesh = _m;
        }
        else return; // if object has no renderer at all, stop the script execution.

        // Assign the new mesh we instantiated before.
        _ref.GetComponent<SkinnedMeshRenderer>().sharedMesh = _m;
        // create array with deltas.
        Vector3[] newVertexDeltas = new Vector3[_m.vertices.Length];

        for (int y = 0; y < newVertexDeltas.Length; y++)
        {
            if (_selection.Contains(_ref.transform.TransformPoint(_m.vertices[y])))
            {
                // each vertex found within the _selection bounds, gets the delta.
                newVertexDeltas[y] = newDelta;

                //GREEN draw line - current position of vertices.
                Debug.DrawLine(
                _ref.transform.TransformPoint(_m.vertices[y]), _ref.transform.TransformPoint(_m.vertices[y] + _m.normals[y] * 0.05f), Color.green, 1000000.0f);

                //MAGENTA draw line - path of each vertex from initial position to delta position.
                Debug.DrawLine(
                _ref.transform.TransformPoint(_m.vertices[y]), _ref.transform.TransformPoint(_m.vertices[y] + newDelta), Color.magenta, 1000000.0f);

                //BLUE draw line - position of each vertex in it's delta position.
                Debug.DrawLine(
                _ref.transform.TransformPoint(_m.vertices[y] + newDelta), _ref.transform.TransformPoint((_m.vertices[y] - _m.normals[y] * 0.05f) + newDelta), Color.blue, 1000000.0f);
            }
            else
            {
                //RED draw line - position of each vertex that are not within the _selection bounds.
                newVertexDeltas[y] = Vector3.zero;
                Debug.DrawLine(
                _ref.transform.TransformPoint(_m.vertices[y]), _ref.transform.TransformPoint(_m.vertices[y] - _m.normals[y] * 0.05f), Color.red, 1000000.0f);
            }
        }

        // Create the new blendshape with vertecies deltas.
        _m.AddBlendShapeFrame(MorphName, 100f, newVertexDeltas, null, null);
        _m.RecalculateNormals();
        _m.RecalculateTangents();
    }
}
