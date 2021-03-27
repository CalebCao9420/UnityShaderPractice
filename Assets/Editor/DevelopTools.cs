using UnityEngine;
using UnityEditor;

public class DevelopTools : MonoBehaviour {
    [MenuItem("Tools/Common/ActiveObj &X")]
    public static void SetObjState() {
        var objs = Selection.gameObjects;
        int count = objs.Length;
        for (int i = 0; i < count; ++i) {
            bool isActive = objs[i].activeSelf;
            objs[i].SetActive(!isActive);
        }
    }
}
