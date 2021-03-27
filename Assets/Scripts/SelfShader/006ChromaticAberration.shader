Shader "Unlit/006ChromaticAberration"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint" , Color  )  = (1,1,1,1)
        _Factor("ChromaticAberrationFactor" ,Range(0,1)) = 0
        _Alpha("ChromaticAberrationAlpha" ,Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Cull Off
        ZWrite Off  
        Lighting Off
        Blend  One OneMinusSrcAlpha 

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
                float4 color :COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 color :COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Alpha;
            float _Factor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 ChromaticAberration(float4 rawCol,sampler2D tex,float2 uv, float4 color,float factor,float alpha){
                fixed4 r = tex2D( tex, uv + float2(factor,0)) *color;
                fixed4 b = tex2D( tex, uv + float2(-factor,0)) *color;
                return fixed4(r.r * r.a ,rawCol.g, b.b * b.a ,max(max(b.a,r.a) * alpha , rawCol.a));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = lerp(0,col.rgb,col.a);
                col = ChromaticAberration(col,_MainTex,i.uv,i.color *_Color,_Factor,_Alpha);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
