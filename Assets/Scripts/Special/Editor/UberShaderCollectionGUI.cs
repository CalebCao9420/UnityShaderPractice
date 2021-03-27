using UnityEngine;
using UnityEditor;

public class UberShaderCollectionGUI : ShaderGUI {
    private Material _target;
    private MaterialEditor _editor;
    private MaterialProperty[] _properties;
    private int _lastBlendMode = -1;

    public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties) {
        this._editor = editor;
        this._target = this._editor.target as Material;
        this._properties = properties;

        this.ShowMain();
        //this.ShowUVFlow();
        this.ShowMask();
        this.ShowDistort();
        this.ShowDissolve();
        this.ShowSoftParticle();
        this.ShowRenderMode();
    }

    private void ShowMain() {
        ShowPropertys("_TintColor");
        ShowPropertys("_MainTex");
    }

    private void ShowPropertys(string name) {
        var property = ShaderGUI.FindProperty(name, this._properties);
        this._editor.ShaderProperty(property, property.displayName);
    }

    //private void ShowUVFlow() {
    //    ShowPropertys("_UseUVFlow");
    //    var property = ShaderGUI.FindProperty("_UseUVFlow", this._properties);
    //    if (property.floatValue > 0.5) {
    //        ShowPropertys("_FlowSpeed");
    //    }

    //}

    private void ShowDistort() {
        ShowBlock("_DistortTex", "USE_DISTORT", () => {
            ShowPropertys("_DistortTex");
            ShowPropertys("_DistortSpeed2_Factor2");
            ShowPropertys("_DistortUVFactor2_RotateSpeed1");
        });
    }
    private void ShowDissolve() {
        ShowBlock("_DissolveTex", "USE_DISSOLVE", () => {
            ShowPropertys("_DissolveTex");
            ShowPropertys("_DissolveProgress");
            ShowPropertys("_DissolveColor");
            ShowPropertys("_DissolveRange");
        });
    }

    private void ShowMask() {
        ShowBlock("_MaskTex", "USE_MASK", () => {
            ShowPropertys("_MaskTex");
            //ShowVector2("_MainSpeed2_MaskSpeed2", "MaskTexture FlowSpeed", 2,3);
        });
    }

    private void ShowSoftParticle() {
        var _UseSoftParticle = ShaderGUI.FindProperty("_UseSoftParticle", this._properties);
        this._editor.ShaderProperty(_UseSoftParticle, _UseSoftParticle.displayName);
        if (_UseSoftParticle.floatValue > 0.5f) {
            ShowPropertys("_InvFade");
        }
    }


    private void ShowRenderMode() {
        ShowPropertys("_CullMode");
        var _BlendMode = ShaderGUI.FindProperty("_BlendMode", this._properties);
        this._editor.ShaderProperty(_BlendMode, _BlendMode.displayName);

        var blendMode = (BlendMode)Mathf.RoundToInt(_BlendMode.floatValue);
        SetupMaterialWithBlendMode(this._target, blendMode, this._lastBlendMode != -1 && this._lastBlendMode != (int)blendMode);
        this._lastBlendMode = (int)blendMode;
        this._editor.RenderQueueField();
    }

    private void ShowBlock(string name, string macroName, System.Action callback) {
        MaterialProperty map = FindProperty(name);
        EditorGUI.BeginChangeCheck();
        if (map.textureValue != null) {
            //GUILayout.Label(name, EditorStyles.boldLabel);
            //EditorGUI.indentLevel += 1;
            callback();
            //EditorGUI.indentLevel -= 1;
            GUILayout.Space(10);
        } else {
            this._editor.TexturePropertySingleLine(MakeLabel(map, name), map, null);
        }
        if (EditorGUI.EndChangeCheck()) {
            SetKeyword(macroName, map.textureValue);
        }
    }
    private MaterialProperty FindProperty(string name) {
        return FindProperty(name, this._properties);
    }

    private void SetKeyword(string keyword, bool state) {
        if (state) {
            foreach (Material m in this._editor.targets) {
                m.EnableKeyword(keyword);
            }
        } else {
            foreach (Material m in this._editor.targets) {
                m.DisableKeyword(keyword);
            }
        }
    }


    static GUIContent staticLabel = new GUIContent();
    static GUIContent MakeLabel(MaterialProperty property, string tooltip = null) {
        staticLabel.text = property.displayName;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    #region RenderMode Implement
    public enum BlendMode {
        //Blend,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
        //Transparent, // Physically plausible transparency mode, implemented as alpha pre-multiply
        Additive, Blend, Opaque, Cutout, Transparent, Subtractive, Modulate
    }

    public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode, bool isResetRenderQueue) {
        switch (blendMode) {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "");
                material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                if (isResetRenderQueue) material.renderQueue = 2000;
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                if (isResetRenderQueue) material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
            case BlendMode.Blend:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                if (isResetRenderQueue) material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                if (isResetRenderQueue) material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Additive:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_ZWrite", 0);
                if (isResetRenderQueue) material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Subtractive:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.ReverseSubtract);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_ZWrite", 0);
                if (isResetRenderQueue) material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Modulate:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                if (isResetRenderQueue) material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
        }
    }

    #endregion
}
