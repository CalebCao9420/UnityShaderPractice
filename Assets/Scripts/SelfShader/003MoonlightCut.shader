// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "003MoonlightCut"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		
	}


	Category 
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Cull Off
			Lighting Off 
			ZWrite Off
			ZTest LEqual
			
			Pass {
			
				CGPROGRAM
				
				#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
				#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
				#endif
				
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_instancing
				#pragma multi_compile_particles
				#pragma multi_compile_fog
				

				#include "UnityCG.cginc"

				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
					
				};
				
				
				#if UNITY_VERSION >= 560
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				#else
				uniform sampler2D_float _CameraDepthTexture;
				#endif

				//Don't delete this comment
				// uniform sampler2D_float _CameraDepthTexture;

				uniform sampler2D _MainTex;
				uniform fixed4 _TintColor;
				uniform float4 _MainTex_ST;
				uniform float _InvFade;
				

				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					

					v.vertex.xyz +=  float3( 0, 0, 0 ) ;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = v.texcoord;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag ( v2f i  ) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID( i );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( i );

					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						float partZ = i.projPos.z;
						float fade = saturate (_InvFade * (sceneZ-partZ));
						i.color.a *= fade;
					#endif

					float2 break15_g1 = float2( 0,0.003 );
					float2 uv06 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float smoothstepResult8_g1 = smoothstep( break15_g1.x , break15_g1.y , ( 1.0 - ( length( ( ( ( uv06 - float2( 0.5,0.5 ) ) - ( float2( 0,0 ) + float2( 0,0 ) ) ) / float2( 1,1 ) ) ) * 2.0 ) ));
					float2 break15_g2 = float2( 0,0.003 );
					float2 uv041 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float3 uv048 = i.texcoord.xyz;
					uv048.xy = i.texcoord.xyz.xy * float2( 1,1 ) + float2( 0,0 );
					float2 appendResult51 = (float2((-1.0 + (( uv048.z + 0.0 ) - 0.0) * (0.0 - -1.0) / (1.0 - 0.0)) , 0.0));
					float smoothstepResult8_g2 = smoothstep( break15_g2.x , break15_g2.y , ( 1.0 - ( length( ( ( ( uv041 - float2( 0.5,0.5 ) ) - ( appendResult51 + float2( 0,0 ) ) ) / float2( 1,1 ) ) ) * 2.0 ) ));
					float4 color68 = IsGammaSpace() ? float4(0,0.8106995,1,0.772549) : float4(0,0.6221216,1,0.772549);
					float4 color69 = IsGammaSpace() ? float4(0.6273585,0.9298557,1,0.772549) : float4(0.3514183,0.8477902,1,0.772549);
					float2 break15_g3 = float2( 0,0.3 );
					float2 uv064 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float smoothstepResult8_g3 = smoothstep( break15_g3.x , break15_g3.y , ( 1.0 - ( length( ( ( ( uv064 - float2( 0.5,0.5 ) ) - ( float2( 0,0 ) + float2( 0,0 ) ) ) / float2( 1,1 ) ) ) * 2.0 ) ));
					float4 lerpResult71 = lerp( color68 , color69 , smoothstepResult8_g3);
					

					fixed4 col = ( i.color * _TintColor * 2.0 * ( saturate( ( smoothstepResult8_g1 - smoothstepResult8_g2 ) ) * lerpResult71 ) );
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG 
			}
		}	
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17500
2063;38;1416;1294;1073.85;-189.797;1;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-1346.931,243.8945;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-1107.06,295.0706;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;50;-998.2094,280.7572;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1058.687,-161.3509;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;8;-990.1183,-34.34525;Inherit;False;Constant;_Offset;Offset;0;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-875.1027,165.1244;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;51;-811.2216,313.3722;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;74;-769.646,-74.74397;Inherit;False;DrawCircle;-1;;1;cfdf684b58b0f6d4288a5ead4eb82c3a;0;4;11;FLOAT2;0,0;False;9;FLOAT2;0,0;False;13;FLOAT2;1,1;False;14;FLOAT2;0,0.003;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;64;-1020.918,1067.211;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;75;-607.848,349.0095;Inherit;False;DrawCircle;-1;;2;cfdf684b58b0f6d4288a5ead4eb82c3a;0;4;11;FLOAT2;0,0;False;9;FLOAT2;0,0;False;13;FLOAT2;1,1;False;14;FLOAT2;0,0.003;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;76;-780.9183,1067.211;Inherit;False;DrawCircle;-1;;3;cfdf684b58b0f6d4288a5ead4eb82c3a;0;4;11;FLOAT2;0,0;False;9;FLOAT2;0,0;False;13;FLOAT2;1,1;False;14;FLOAT2;0,0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;25;-400.8414,92.00285;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;68;-764.9183,667.2107;Inherit;False;Constant;_Color0;Color 0;0;0;Create;True;0;0;False;0;0,0.8106995,1,0.772549;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;69;-748.9183,875.2107;Inherit;False;Constant;_Color1;Color 1;0;0;Create;True;0;0;False;0;0.6273585,0.9298557,1,0.772549;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;54;-135.0901,281.3062;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;71;-460.9182,922.2107;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;63.91082,130.0353;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;28.18322,608.9178;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;1;43.45653,-311.4983;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;4;-3.089401,-119.9633;Inherit;False;0;0;_TintColor;Shader;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;505.1107,208.5361;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1360.63,457.0782;Inherit;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;688.8932,345.9162;Float;False;True;-1;2;ASEMaterialInspector;0;7;003MoonlightCut;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;True;True;True;True;False;0;False;-1;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;52;0;48;3
WireConnection;50;0;52;0
WireConnection;51;0;50;0
WireConnection;74;11;6;0
WireConnection;74;9;8;0
WireConnection;75;11;41;0
WireConnection;75;9;51;0
WireConnection;76;11;64;0
WireConnection;25;0;74;0
WireConnection;25;1;75;0
WireConnection;54;0;25;0
WireConnection;71;0;68;0
WireConnection;71;1;69;0
WireConnection;71;2;76;0
WireConnection;72;0;54;0
WireConnection;72;1;71;0
WireConnection;2;0;1;0
WireConnection;2;1;4;0
WireConnection;2;2;5;0
WireConnection;2;3;72;0
WireConnection;0;0;2;0
ASEEND*/
//CHKSM=B07619D4F8701EEF5F7A08D80D32A1E5727624F3