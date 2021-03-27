// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "10DistortPortal"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_Distort("Distort", 2D) = "bump" {}
		_Circle01("Circle01", 2D) = "white" {}
		_DistortStrength("DistortStrength", Range( 0 , 1)) = 0.1
		_TimeScale("TimeScale", Float) = 1
		_MaskSize("MaskSize", Float) = 0.85
		_MaskEdge("MaskEdge", Float) = -0.3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}


	Category 
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend One One
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
				#include "UnityShaderVariables.cginc"


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
				uniform float _MaskEdge;
				uniform float _MaskSize;
				uniform sampler2D _Circle01;
				uniform sampler2D _Distort;
				uniform float4 _Distort_ST;
				uniform float _DistortStrength;
				uniform float _TimeScale;

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

					float2 appendResult21 = (float2(_MaskEdge , 0.5));
					float2 break15_g1 = appendResult21;
					float2 uv03_g1 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float2 temp_cast_0 = (_MaskSize).xx;
					float smoothstepResult8_g1 = smoothstep( break15_g1.x , break15_g1.y , ( 1.0 - ( length( ( ( ( uv03_g1 - float2( 0.5,0.5 ) ) - ( float2( 0,0 ) + float2( 0,0 ) ) ) / temp_cast_0 ) ) * 2.0 ) ));
					float2 uv_Distort = i.texcoord.xy * _Distort_ST.xy + _Distort_ST.zw;
					float3 tex2DNode1 = UnpackNormal( tex2D( _Distort, uv_Distort ) );
					float2 appendResult3 = (float2(tex2DNode1.r , tex2DNode1.g));
					float2 uv08 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float cos12 = cos( ( _Time.y * _TimeScale ) );
					float sin12 = sin( ( _Time.y * _TimeScale ) );
					float2 rotator12 = mul( ( ( appendResult3 * _DistortStrength ) + uv08 ) - float2( 0.5,0.5 ) , float2x2( cos12 , -sin12 , sin12 , cos12 )) + float2( 0.5,0.5 );
					

					fixed4 col = ( i.color * ( ( smoothstepResult8_g1 + 0.0 ) * tex2D( _Circle01, rotator12 ) ) );
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
1999;0;1303;1389;354.9742;595.6055;1;True;True
Node;AmplifyShaderEditor.SamplerNode;1;-942.9532,-83.43197;Inherit;True;Property;_Distort;Distort;0;0;Create;True;0;0;False;0;-1;6433ad4692b7d114f95eaccf8dfb9627;6433ad4692b7d114f95eaccf8dfb9627;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;3;-632.465,-49.10755;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-858.5525,166.2393;Inherit;False;Property;_DistortStrength;DistortStrength;2;0;Create;True;0;0;False;0;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-646.7106,530.8579;Inherit;False;Property;_TimeScale;TimeScale;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-452.9526,33.63941;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-241.4408,-45.86289;Inherit;False;Property;_MaskEdge;MaskEdge;5;0;Create;True;0;0;False;0;-0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-493.2526,200.0393;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;13;-654.808,360.2155;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-218.7338,-156.9066;Inherit;False;Property;_MaskSize;MaskSize;4;0;Create;True;0;0;False;0;0.85;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-254.9837,96.53207;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-345.4495,399.1991;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-29.00366,-49.19233;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;12;-70.02188,180.3106;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;17;167.5316,-106.1408;Inherit;False;DrawCircle;-1;;1;cfdf684b58b0f6d4288a5ead4eb82c3a;0;4;11;FLOAT2;0,0;False;9;FLOAT2;0,0;False;13;FLOAT2;1,1;False;14;FLOAT2;0,0.003;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;438.2986,-56.38044;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;199.8867,161.1874;Inherit;True;Property;_Circle01;Circle01;1;0;Create;True;0;0;False;0;-1;a7ba4ab3dacca1f41b92de92749d7342;a7ba4ab3dacca1f41b92de92749d7342;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;10;541.2252,-285.1104;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;573.5811,45.96537;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;904.2064,1.554985;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1145.6,119.1;Float;False;True;-1;2;ASEMaterialInspector;0;7;10DistortPortal;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;True;True;True;True;False;0;False;-1;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;3;0;1;1
WireConnection;3;1;1;2
WireConnection;5;0;3;0
WireConnection;5;1;6;0
WireConnection;7;0;5;0
WireConnection;7;1;8;0
WireConnection;16;0;13;2
WireConnection;16;1;14;0
WireConnection;21;0;20;0
WireConnection;12;0;7;0
WireConnection;12;2;16;0
WireConnection;17;13;19;0
WireConnection;17;14;21;0
WireConnection;22;0;17;0
WireConnection;2;1;12;0
WireConnection;18;0;22;0
WireConnection;18;1;2;0
WireConnection;11;0;10;0
WireConnection;11;1;18;0
WireConnection;0;0;11;0
ASEEND*/
//CHKSM=252A62B5A56F5A228BB1193CDACF44A8DA3EA100