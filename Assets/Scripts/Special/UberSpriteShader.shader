Shader "CalebUtils/UberSpriteShader"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0

		// [Header(Pixelate)]
		[Toggle(USE_PIXELATE)] _UsePixelate("Use Pixel Style", Int) = 0
		_PixelResolution ("_PixelResolution", Range(4,512)) = 4

		// [Header(Blur)]
		[Toggle(USE_BLUR)] _UseBlur("Use Blur Style", Int) = 0
		_BlurIntensity ("_BlurIntensity", Range(0,1)) = 0

		// [Header(Desaturate)]
		[Toggle(USE_DESATURATE)] _UseDesaturate("Use Desaturate Style", Int) = 0
		_DesaturateFactor ("_DesaturateFactor", Range(0,1)) = 4

		// [Header(Shadow)]
		[Toggle(USE_SHADOW)] _UseShadow("Use Shadow Style", Int) = 0
		_ShadowColor ("_ShadowColor" ,Color) = (0,0,0,1)
		_ShadowOffset ("_ShadowOffset", Vector) = (0.1,0.1,0)

		// [Header(Chromatic Aberration)]
		[Toggle(USE_CHROMATIC_ABERRATION)] _UseChromaticAberration ("Use Chromatic Abberation" , int) =0
		_ChromaticAberrationFactor ("_ChromaticAberrationFactor", Range(0,1)) = 1
		_ChromaticAberrationAlpha ("__ChromaticAberrationAlpha" ,Range(0,1)) = 1

		// [Header(Outter Outline)]
		[Toggle(USE_OUTLINE)] _UseOutline ( "Use Outline" , Int) = 0 
		_OutlineColor ("_OutlineColor", Color) = (0,0,0,1)
		_OutlineWidth ("_OutlineWidth" ,Range(0,0.5)) = 0.001
		_OutlineAlpha ("_OutlineAlpha " ,Range (0,1)) =1
		_OutlineGlow  ("_OutlineGlow" , Range(0,10)) =10

		// [Header(Inner Outline)]
		[Toggle(USE_INNER_OUTLINE)] _UseInnerOutline("Use Inner Outline" ,Int) =0
		_InnerOutlineColor ("_InnerOutlineColor", Color) = (0,0,0,1)
		_InnerOutlineWidth ("_InnerOutlineWidth" ,Range(0,0.5)) = 0.001
		_InnerOutlineAlpha ("_InnerOutlineAlpha " ,Range (0,1)) =1
		_InnerOutlineGlow  ("_InnerOutlineGlow" , Range(0,10)) =10		
	}//Properties

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" 
		"IgnoreProjector"="True" 
		"RenderType"="Transparent" 
		"PreviewType"="Plane" 
		"CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		Pass
		{
		CGPROGRAM
			
			#pragma vertex SpriteVert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA

			// #include "UnityCG.cginc"
			#include "UnitySprites.cginc"
		    #include "PostProcess.cginc"

			#pragma shader_feature USE_PIXELATE
			#pragma shader_feature USE_BLUR
			#pragma shader_feature USE_SHADOW
			#pragma shader_feature USE_DESATURATE
			#pragma shader_feature USE_CHROMATIC_ABERRATION
			#pragma shader_feature USE_OUTLINE
			#pragma shader_feature USE_INNER_OUTLINE

		#ifdef USE_PIXELATE
			fixed _PixelResolution;
		#endif

		#ifdef USE_BLUR
			float _BlurIntensity;
		#endif

		#ifdef USE_SHADOW
			float4 _ShadowColor;
			float2 _ShadowOffset;
		#endif

		#ifdef USE_DESATURATE
			float _DesaturateFactor;
		#endif

		#ifdef USE_CHROMATIC_ABERRATION
			float _ChromaticAberrationAlpha;
			float _ChromaticAberrationFactor;
		#endif

		#ifdef USE_OUTLINE
			float4 _OutlineColor;
			float _OutlineGlow;
			float _OutlineAlpha;
			float _OutlineWidth;
		#endif

		#ifdef USE_INNER_OUTLINE
			float4 _InnerOutlineColor;
			float _InnerOutlineGlow;
			float _InnerOutlineAlpha;
			float _InnerOutlineWidth;
		#endif

			void UVOperate(inout float2 uv){
				float2 rawCol = uv;
				#ifdef USE_PIXELATE
				uv = Pixelate(rawCol,_PixelResolution);
				#endif
			}

			void ColorOperate(float2 rawUV,float4 inColor,inout float4 col){
				#ifdef USE_BLUR
				col = Blur(_MainTex,rawUV,_BlurIntensity); 
				#endif

				#ifdef USE_SHADOW
				col = Shadow2D(col,_MainTex,rawUV,_ShadowOffset,_ShadowColor);
				#endif

				#ifdef USE_DESATURATE
				col = Desaturate(col,_DesaturateFactor);
				#endif

				#ifdef USE_CHROMATIC_ABERRATION
				col = ChromaticAberration(col,_MainTex,rawUV,_Color * inColor, _ChromaticAberrationFactor,_ChromaticAberrationAlpha);
				#endif

				#ifdef USE_OUTLINE
				col = DrawOutline(col,_MainTex,rawUV,_OutlineColor,_OutlineWidth,_OutlineAlpha,_OutlineGlow);
				#endif

				#ifdef USE_INNER_OUTLINE
				col = DrawInnerOutline(col,_MainTex,rawUV,_InnerOutlineColor,_InnerOutlineWidth,_InnerOutlineAlpha,_InnerOutlineGlow);
				#endif
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				float2 uv=IN.texcoord;
				float2 rawUV = uv;
				UVOperate(uv);

				fixed4 c = SampleSpriteTexture (uv) * IN.color;
				ColorOperate(rawUV,IN.color,c);

				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}//Pass
	}//SubShader
	CustomEditor "Caleb.UberSpriteGUI"
}//Shader
