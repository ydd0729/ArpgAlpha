﻿using UnityEditor;
using UnityEngine;

namespace Shared.Scene
{
    [CustomEditor(typeof(ChildrenLayout))]
    public class ChildrenLayoutEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();
            
            if (GUILayout.Button("Organize"))
            {
                ((ChildrenLayout)target).Organize();
            }
        }
    }
}