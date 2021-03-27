// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "12Blur"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_BlurData ("Blur Data" ,Range(0,1))  = 0.1
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		
	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			float _BlurData;
			
			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}


			// float4 Blur(sampler2D sam,float2 rawUV,float offset)
			// {
			//     const int num =12;
			// 	const float2 divi[12] = {float2(-0.326212f, -0.40581f),
			// 	float2(-0.840144f, -0.07358f),
			// 	float2(-0.695914f, 0.457137f),
			// 	float2(-0.203345f, 0.620716f),
			// 	float2(0.96234f, -0.194983f),
			// 	float2(0.473434f, -0.480026f),
			// 	float2(0.519456f, 0.767022f),
			// 	float2(0.185461f, -0.893124f),
			// 	float2(0.507431f, 0.064425f),
			// 	float2(0.89642f, 0.412458f),
			// 	float2(-0.32194f, -0.932615f),
			// 	float2(-0.791559f, -0.59771f)};
			// 	float4 col = float4(0,0,0,0);
			// 	for(int i=0;i<num;i++)
			// 	{
			// 		float2 uv = rawUV + offset * divi[i];
			// 		uv = saturate(uv);
			// 		float4 c = tex2D(sam,uv);
			// 		col += c;
			// 	}
			// 	col /= num;
			// 	return col;
			// }

			float4 Blur (sampler2D sam,float2 rawUV,float offset){
				const int num =8;
				const float2 divi[8]= {float2(-0.30980, -0.62313),
					float2(-0.609809,0),
					float2(0.6098089,0),
					float2(0.398790,-0.6907978),
					float2(-0.5987987,0.579879),
					float2(0,0.50989),
					float2(0.78979867,0.47899678),
					float2(0,-0.98797899)
				};

				float4 col=float4(0,0,0,0);
				for (int i = 0; i < num; ++i)
				{
					float2 uv=rawUV + offset * divi[i];
					uv=saturate(uv);
					float4 c= tex2D(sam,uv);
					col += c;
				}
				
				col /= num;
				return col;
			}
			

			fixed4 frag(v2f IN  ) : SV_Target
			{
				
				fixed4 c = SampleSpriteTexture (IN.texcoord) * IN.color;
				c=Blur(_MainTex,IN.texcoord,_BlurData);
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17500
0;21;1303;1383;651.5;691.5;1;True;True
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;1;12Blur;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
ASEEND*/
//CHKSM=D63C3D0893B5DDD988CB4F99C537A4C39CDBE3B5