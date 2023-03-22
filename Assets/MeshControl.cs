using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[ExecuteInEditMode]
public class MeshControl : MonoBehaviour
{
    public enum ModifyType
    {
        ScaleX,
        ScaleY,
        ScaleZ,
        X,
        Y,
        Z
    }

    [System.Serializable]
    public class ModifyDataGroup
    {
        public string name;
        [Range(0,1)]
        public float value = 0.5f;
        public ModifyData[] modifys;
    }

    [System.Serializable]
    public class ModifyData
    {
        [DragName]
        public string name;
        public ModifyType type;
        public float min;
        public float max;
        public AnimationCurve curve;
    }
    public bool drawGizmos = true;
    public ModifyDataGroup[] modifyDataGroup;
    public Transform[] bakeFilter;

    Transform[] bones;
    SkinnedMeshRenderer[] smrs;
    HashSet<Transform> skinBoneSet;

    public bool IsSkinTransform(Transform trans)
    {
        return skinBoneSet.Contains(trans);
    }

    private void OnDrawGizmos()
    {
        if (drawGizmos)
        {
            foreach (Transform trans in bones)
            {
                if (IsSkinTransform(trans))
                {
                    Handles.color = Color.red;
                    Handles.DrawWireCube(trans.position, trans.localScale * 0.005f);
                }

                if (trans.parent != null)
                {
                    Handles.color = Color.white;
                    Handles.DrawLine(trans.parent.position, trans.position);
                }
            }
        }
    }

    private void OnEnable()
    {
        this.bones = GetComponentsInChildren<Transform>();
        this.smrs = GetComponentsInChildren<SkinnedMeshRenderer>();
        this.skinBoneSet = new HashSet<Transform>();

        foreach (SkinnedMeshRenderer smr in smrs)
        {
            var bones = smr.bones;
            int boneCount = bones.Length;
            for (int i = 0; i < boneCount; i++)
            {
                skinBoneSet.Add(bones[i]);
            }
        }
        UpdateBones();
    }

    private void OnValidate()
    {
        UpdateBones();
    }

    public void UpdateBones()
    {
        foreach (var modifyGroup in modifyDataGroup)
        {
            foreach (var modify in modifyGroup.modifys)
            {
                GameObject go = GameObject.Find(modify.name);
                if (go != null)
                {
                    Transform trans = go.transform;

                    float value = modifyGroup.value;
                    if (modify.curve != null)
                        value = modify.curve.Evaluate(value);

                    value = Mathf.Lerp(modify.min, modify.max, value);
                    switch (modify.type)
                    {
                        case ModifyType.ScaleX:
                            trans.localScale = new Vector3(value, trans.localScale.y, trans.localScale.z);
                            break;
                        case ModifyType.ScaleY:
                            trans.localScale = new Vector3(trans.localScale.x, value, trans.localScale.z);
                            break;
                        case ModifyType.ScaleZ:
                            trans.localScale = new Vector3(trans.localScale.x, trans.localScale.y, value);
                            break;
                        case ModifyType.X:
                            trans.localPosition = new Vector3(value, trans.localPosition.y, trans.localPosition.z);
                            break;
                        case ModifyType.Y:
                            trans.localPosition = new Vector3(trans.localPosition.x, value, trans.localPosition.z);
                            break;
                        case ModifyType.Z:
                            trans.localPosition = new Vector3(trans.localPosition.x, trans.localPosition.y, value);
                            break;
                    }
                }
            }
        }
    }
}

[CustomEditor(typeof(MeshControl))]
public class MeshControlEditor : Editor
{
    class Entity
    {
        public SkinnedMeshRenderer smr;
        public int blendMeshSelectIndex;
        public string[] names;
    }
    SkinnedMeshRenderer[] smrs;
    List<Entity> entitys;

    private void OnEnable()
    {
        smrs = (target as MeshControl).GetComponentsInChildren<SkinnedMeshRenderer>();
        entitys = new List<Entity>();
        foreach (var smr in smrs)
        {
            int count = smr.sharedMesh.blendShapeCount;
            string[] names = new string[count];
            for (int i = 0; i < count; i++)
            {
                names[i] = smr.sharedMesh.GetBlendShapeName(i).Replace(".", "/");
            }
            entitys.Add( new Entity() { smr = smr, names = names, blendMeshSelectIndex = -1 });
        }
    }

    private void OnSceneGUI()
    {
        Handles.color = Color.red;
        if ((target as MeshControl).drawGizmos)
        {
            foreach (Transform trans in (target as MeshControl).GetComponentsInChildren<Transform>())
            {
                if ((target as MeshControl).IsSkinTransform(trans)) 
                {
                    if (Handles.Button(trans.position, trans.rotation, 0.005f, 0.005f, (int controlID, Vector3 position, Quaternion rotation, float size, EventType eventType) =>
                    {
                        if (Event.current.type == EventType.Layout)
                            Handles.RectangleHandleCap(controlID, position, rotation, size, eventType);
                        Handles.DrawWireCube(trans.position, trans.localScale * 0.005f);
                    }))
                    {
                        Selection.activeGameObject = trans.gameObject;
                        Event.current.Use();
                    }
                }
            }
        }
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        foreach (Entity e in entitys)
        {
            var smr = e.smr;
            e.blendMeshSelectIndex = EditorGUILayout.Popup("Blend Shape", e.blendMeshSelectIndex, e.names);
            SelectBlendMesh(smr, e.blendMeshSelectIndex);
        }

        if (GUILayout.Button("Reset"))
        {
            foreach (var smr in smrs)
            {
                MeshBakeUtil.ResetBones(smr);
            }
        }
        if (GUILayout.Button("Bake"))
        {
            foreach (Entity e in entitys)
            {
                var smr = e.smr;
                HashSet<Transform> filter = null;
                var bakeFilter = (target as MeshControl).bakeFilter;
                if (bakeFilter != null && bakeFilter.Length > 0)
                {
                    filter = new HashSet<Transform>(bakeFilter);
                }
                smr.sharedMesh = MeshBakeUtil.BakeMesh(smr, filter);
            }
        }
    }

    void SelectBlendMesh(SkinnedMeshRenderer smr, int index)
    {
        int count = smr.sharedMesh.blendShapeCount;
        for (int i = 0; i < count; i++)
        {
            smr.SetBlendShapeWeight(i, index == i ? 100f : 0);
        }
    }
}

//提供拖动GameObject名称到输入框的功能
public class DragNameAttribute : PropertyAttribute { };

[CustomPropertyDrawer(typeof(DragNameAttribute))]
public class DragNameDrawer : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        EditorGUI.PropertyField(position, property, false);

        if (position.Contains(Event.current.mousePosition))
        {
            if (Event.current.type == EventType.DragPerform)
            {
                property.stringValue = DragAndDrop.objectReferences[0].name;
            }
            else if (Event.current.type == EventType.DragUpdated)
            {
                if (DragAndDrop.objectReferences.Length > 0)
                {
                    DragAndDrop.visualMode = DragAndDropVisualMode.Link;
                    DragAndDrop.AcceptDrag();
                }
            }
        }
    }
}
