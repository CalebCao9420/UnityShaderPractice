using UnityEditor;
using UnityEngine;

namespace Caleb {
    public class UberSpriteGUI : BaseShaderGUI {

        protected override void ShowGUI() {
            this.ShowMain();
            this.ShowPixelate();
            this.ShowBlur();
            this.ShowDesaturate();
            this.ShowShadow();
            this.ShowChromaticAberration();
            this.ShowOutterOutline();
            this.ShowInnterOutline();
        }

        private GUIContent MakeLabel(MaterialProperty property, string tooltip = null) {
            _StaticLabel.text = property.displayName;
            _StaticLabel.tooltip = tooltip;
            return _StaticLabel;
        }

        private void ShowMain() {
            var prop = ShaderGUI.FindProperty("_MainTex", _Properties);
            var prop2 = ShaderGUI.FindProperty("_Color", _Properties);
            base._Editor.TexturePropertySingleLine(MakeLabel(prop), prop, prop2);
            GUILayout.Space(15);
        }
        private void ShowPixelate() {
            ShowToggleBlock("_UsePixelate", "USE_PIXELATE", () => {
                ShowPropertys("_PixelResolution");
            });
        }

        private void ShowBlur() {
            ShowToggleBlock("_UseBlur", "USE_BLUR", () => {
                ShowPropertys("_BlurIntensity");
            });
        }

        private void ShowDesaturate() {
            ShowToggleBlock("_UseDesaturate", "USE_DESATURATE", () => {
                ShowPropertys("_DesaturateFactor");
            });
        }

        private void ShowShadow() {
            ShowToggleBlock("_UseShadow", "USE_SHADOW", () => {
                ShowPropertys("_ShadowColor");
                ShowPropertys("_ShadowOffset");
            });
        }

        private void ShowChromaticAberration() {
            ShowToggleBlock("_UseChromaticAberration", "USE_CHROMATIC_ABERRATION", () => {
                ShowPropertys("_ChromaticAberrationFactor");
                ShowPropertys("_ChromaticAberrationAlpha");
            });
        }

        private void ShowOutterOutline() {
            ShowToggleBlock("_UseOutline", "USE_OUTLINE", () => {
                ShowPropertys("_OutlineColor");
                ShowPropertys("_OutlineWidth");
                ShowPropertys("_OutlineAlpha");
                ShowPropertys("_OutlineGlow");
            });
        }
        private void ShowInnterOutline() {
            ShowToggleBlock("_UseInnerOutline", "USE_INNER_OUTLINE", () => {
                ShowPropertys("_InnerOutlineColor");
                ShowPropertys("_InnerOutlineWidth");
                ShowPropertys("_InnerOutlineAlpha");
                ShowPropertys("_InnerOutlineGlow");
            });
        }
    }
}