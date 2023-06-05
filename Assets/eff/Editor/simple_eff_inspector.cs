using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
[UnityEditor.CustomEditor(typeof(posteff_simple))]
public class simple_eff_inspector : Editor
{
    public override void OnInspectorGUI()
    {
        GUILayout.Label("==这东西配置杂乱，用自定义面板替代");
        posteff_simple obj = (target as posteff_simple);
        //base.OnInspectorGUI();
        if (obj.effInfo == null || obj.allEffects == null || obj.effInfo.Count != obj.allEffects.Count)
        {
            //auto reset
            (target as posteff_simple).ResetEffect();
        }
        bool bRepaint = false;
        for (var i = 0; i < obj.effInfo.Count; i++)
        {
            var eff = obj.allEffects[i];
            var info = obj.effInfo[i];
            if (info.mats != null)
            {
                var e = GUILayout.Toggle(info.Enable, "Effect " + info.name + " 是否生效");
                if (e != info.Enable)
                {
                    info.Enable = e;
                    bRepaint = true;
                }
                if (info.Enable && eff.MatEdit)//有些效果，材质需要配置
                {

                    for (var j = 0; j < info.mats.Length; j++)
                    {
                        var mat = info.mats[j];
                        GUILayout.Label("----Effect mats[" + j + "]:" + mat.shader.name + ":" + info.name);

                        UnityEditor.MaterialEditor matEditor = UnityEditor.Editor.CreateEditor(mat) as UnityEditor.MaterialEditor;
                        matEditor.PropertiesGUI();
                    }
                }

            }
        }

        if (GUILayout.Button("Reset Effect") || bRepaint)
        {
            (target as posteff_simple).ResetEffect();
            RePaintGame();
        }
    }

    void RePaintGame()
    {
        var game = EditorWindow.GetWindow(System.Type.GetType("UnityEditor.GameView,UnityEditor"));
        game.Repaint();
    }
}
