Shader "Unlit/005Shadow2D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowColor("ShadowColor" ,Color) =(1,1,1,1)
        _ShadowOffset ("ShadowOffset" ,Vector) = (0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        ZWrite  Off
        Cull  Off
        Lighting Off
        Blend One OneMinusSrcAlpha 
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
            float4 _ShadowColor;
            float2 _ShadowOffset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

             float4 Shadow2D_005(float4 col,sampler2D tex,float2 uv,float2 shadowOffset,float4 shadowColor){
                float shadowA= tex2D(tex, uv + shadowOffset).a;
                col.rgb=lerp(shadowColor.rgb * shadowA,col.rgb,col.a);
                col.a = max(shadowA * shadowColor.a ,col.a);
                return col;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = lerp(0,col.rgb,col.a);
                col=Shadow2D_005(col,_MainTex,i.uv,_ShadowOffset,_ShadowColor);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
