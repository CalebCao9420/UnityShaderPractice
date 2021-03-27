Shader "Unlit/TestSkillCd"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Programe("Programe",Range(0,1)) = 0
        [HideInInspector] _Uv("uv",2D  ) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Uv;
            float _Programe;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                 float2 uv_t=i.vertex.xy;          
                float2 col= 1- length( uv_t - float2(0.5,0.5))  * 2 ;
                 // float2 col=0;
                clip(smoothstep(0,0.25,col)); 
                
                fixed4 finalcolor=(tex2D(_MainTex ,col));
                return finalcolor;
            }
            ENDCG
        }
    }
}
