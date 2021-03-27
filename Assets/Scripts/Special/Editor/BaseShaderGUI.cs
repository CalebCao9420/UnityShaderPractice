using UnityEngine;
using UnityEditor;
using System;

namespace Caleb {
    public class BaseShaderGUI : ShaderGUI {
        static float TOLERANCE = 0.01f;
        protected GUIContent _StaticLabel = new GUIContent();
        protected Material _Target;
        protected MaterialEditor _Editor;
        protected MaterialProperty[] _Properties;
        protected int _LastBlendMode = -1;

        private static GUIStyle _style;

        protected static GUIStyle BoldStyle {
            get {
                if (_style == null) {
                    _style = new GUIStyle();
                    _style.fontStyle = FontStyle.Bold;
                }
                return _style;
            }
        }

        public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties) {
            this._Editor = editor;
            this._Target = this._Editor.target as Material;
            this._Properties = properties;
            this.ShowGUI();
            this._Editor.RenderQueueField();
#if UNITY_5_6_OR_NEWER
            //每个材质能独立实例化，与主材质之间不产生影响
            this._Editor.EnableInstancingField();
            this._Target.enableInstancing = true;
#endif

        }

        protected virtual void ShowGUI() { }

        protected void ShowBlock(string name, string macroName, System.Action callback) {
            MaterialProperty map = FindProperty(name);
            EditorGUI.BeginChangeCheck();
            if (map.textureValue != null) {
                //GUILayout.Label(name, EditorStyles.boldLabel);
                //EditorGUI.indentLevel += 1;
                callback();
                //EditorGUI.indentLevel -= 1;
                GUILayout.Space(10);
            } else {
                this._Editor.TexturePropertySingleLine(MakeLabel(map, name), map, null);
            }
            if (EditorGUI.EndChangeCheck()) {
                SetKeyword(macroName, map.textureValue);
            }
        }

        protected void ShowToggleBlock(string name, string macroname, System.Action callback) {
            EditorGUI.BeginChangeCheck();
            ShowPropertys(name);
            var property = ShaderGUI.FindProperty(name, this._Properties);
            //if (property.floatValue > 0.5) {
            //    property.floatValue = GUILayout.Toggle(property.floatValue > 0.5, property.displayName, BoldStyle)?1:0;
            //}
            //else {
            //    property.floatValue = GUILayout.Toggle(property.floatValue > 0.5, property.displayName)?1:0;
            //}

            if (property.floatValue > 0.5) {
                //GUILayout.Label(name, EditorStyles.boldLabel);
                EditorGUI.indentLevel += 1;
                callback();
                EditorGUI.indentLevel -= 1;
                GUILayout.Space(15);
            }

            if (EditorGUI.EndChangeCheck()) {
                SetKeyword(macroname, property.floatValue > 0.5);
            }
        }

        #region Utils Func

        protected Vector4 ShowVector4(string name) {
            var property = ShaderGUI.FindProperty(name, this._Properties);
            var res = this._Target.GetVector(name);
            var val = EditorGUILayout.Vector4Field(property.displayName, res);
            this._Target.SetVector(name, val);
            return res;
        }

        protected Vector4 ShowVector2(string name, string tips, int idx1, int idx2) {
            var res = this._Target.GetVector(name);
            var val = EditorGUILayout.Vector2Field(tips, new Vector2(res[idx1], res[idx2]));
            res[idx1] = val.x;
            res[idx2] = val.y;
            this._Target.SetVector(name, res);
            return res;
        }

        protected bool ShowBool(string name, string tips, int idx) {
            var res = this._Target.GetVector(name);
            var val = EditorGUILayout.Toggle(tips, res[idx] > 0.5f);
            res[idx] = val ? 1 : 0;
            this._Target.SetVector(name, res);
            return val;
        }

        protected float ShowFloat(string name, string tips, int idx) {
            var res = this._Target.GetVector(name);
            var val = EditorGUILayout.FloatField(tips, res[idx]);
            res[idx] = val;
            this._Target.SetVector(name, res);
            return val;
        }

        protected bool FloatEqual(float valA, float valB) {
            return Math.Abs(valA - valB) < TOLERANCE;
        }

        protected MaterialProperty FindProperty(string name) {
            return FindProperty(name, this._Properties);
        }

        protected GUIContent MakeLabel(MaterialProperty property, string tooltip = null) {
            this._StaticLabel.text = property.displayName;
            this._StaticLabel.tooltip = tooltip;
            return this._StaticLabel;
        }

        protected void ShowPropertys(string name) {
            var property = ShaderGUI.FindProperty(name, this._Properties);
            this._Editor.ShaderProperty(property, property.displayName);
        }

        protected void SetKeyword(string keyword, bool state) {
            if (state) {
                foreach (Material m in this._Editor.targets) {
                    m.EnableKeyword(keyword);
                }
            } else {
                foreach (Material m in this._Editor.targets) {
                    m.DisableKeyword(keyword);
                }
            }
        }

        protected bool IsKeywordEnabled(string keyword) {
            return this._Target.IsKeywordEnabled(keyword);
        }

        protected void RecordAction(string label) {
            this._Editor.RegisterPropertyChangeUndo(label);
        }

        #endregion //Utils Func

        #region RenderMode Implement
        public enum BlendMode {
            //Blend,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
            //Transparent, // Physically plausible transparency mode, implemented as alpha pre-multiply
            Additive,
            Blend,
            Opaque,
            Cutout,
            Transparent,
            Subtractive,
            Modulate
        }

        protected static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode,
                bool isResetRenderQueue) {
            switch (blendMode) {
                case BlendMode.Opaque:
                    material.SetOverrideTag("RenderType", "");
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    if (isResetRenderQueue) { material.renderQueue = 2000; }
                    break;
                case BlendMode.Cutout:
                    material.SetOverrideTag("RenderType", "TransparentCutout");
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    if (isResetRenderQueue) { material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest; }
                    break;
                case BlendMode.Blend:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    material.SetInt("_ZWrite", 0);
                    if (isResetRenderQueue) { material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent; }
                    break;
                case BlendMode.Transparent:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    material.SetInt("_ZWrite", 0);
                    if (isResetRenderQueue) { material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent; }
                    break;
                case BlendMode.Additive:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_ZWrite", 0);
                    if (isResetRenderQueue) { material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent; }
                    break;
                case BlendMode.Subtractive:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.ReverseSubtract);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_ZWrite", 0);
                    if (isResetRenderQueue) { material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent; }
                    break;
                case BlendMode.Modulate:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    material.SetInt("_ZWrite", 0);
                    if (isResetRenderQueue) { material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent; }
                    break;
            }
        }
        #endregion
    }
}