using UnityEditor;
using UnityEngine;

namespace Caleb {

    public class UberParticleGUI : BaseShaderGUI {
        protected override void ShowGUI() {
            this.ShowMain();
            this.ShowMask();
            this.ShowDistort();
            this.ShowDissolve();
            this.ShowSoftParticle();
            this.ShowRenderMode();
        }

        private void ShowMain() {
            ShowPropertys("_TintColor");
            ShowPropertys("_ColorFactor");

            ShowPropertys("_MainTex");
            ShowVector2("_MainSpeed2_MaskSpeed2", "MainTexture FlowSpeed", 0, 1);
            GUILayout.Space(10);
        }
        private void ShowMask() {
            ShowBlock("_MaskTex", "USE_MASK", () => {
                ShowPropertys("_MaskTex");
                ShowVector2("_MainSpeed2_MaskSpeed2", "MaskTexture FlowSpeed", 2, 3);
            });
        }
        private void ShowDistort() {

            ShowBlock("_DistortTex", "USE_DISTORT", () => {
                ShowPropertys("_DistortTex");
                var isFlowDistort = ShowBool("_DistortUVFactor2_RotateSpeed1", "Is Flow Distort?", 3);
                if (isFlowDistort) {
                    ShowVector2("_DistortSpeed2_Factor2", "DistortTexture FlowSpeed", 0, 1);
                }
                ShowVector2("_DistortUVFactor2_RotateSpeed1", "Distort UV Strength", 0, 1);
                ShowFloat("_DistortUVFactor2_RotateSpeed1", "RotateSpeed", 2);
                SetKeyword("USE_FLOW_DISTORT", isFlowDistort);
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
        private void ShowSoftParticle() {
            var _UseSoftParticle = ShaderGUI.FindProperty("_UseSoftParticle", base._Properties);
            base._Editor.ShaderProperty(_UseSoftParticle, _UseSoftParticle.displayName);
            if (FloatEqual(_UseSoftParticle.floatValue, 1)) {
                ShowPropertys("_InvFade");
            }
        }
        private void ShowRenderMode() {
            ShowPropertys("_CullMode");
            var _BlendMode = ShaderGUI.FindProperty("_BlendMode", base._Properties);
            this._Editor.ShaderProperty(_BlendMode, _BlendMode.displayName);

            var blendMode = (BlendMode)Mathf.RoundToInt(_BlendMode.floatValue);
            SetupMaterialWithBlendMode(base._Target, blendMode, base._LastBlendMode != -1 && base._LastBlendMode != (int)blendMode);
            base._LastBlendMode = (int)blendMode;
        }
    }
}