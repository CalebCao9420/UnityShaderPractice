Shader "008Outline(Inner)"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor("OutlineColor", Color) = (1,1,1,1)
        _Alpha("OutlineAlpha", Float) = 1
        _Glow("OutlineGlow" ,Float) =1 
        _Width("OutlineWidth" ,Float) =1 
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Cull Off
        Lighting Off
        ZWrite Off
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Alpha;
            float _Glow;
            float4 _OutlineColor;
            float _Width;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            inline fixed3 _GetPixel(sampler2D tex,float2 uv, float offset_x,float offset_y){
                return tex2D(tex, ( uv + float2(offset_x,offset_y))) .rgb;
            }

            float4 DrawInnerOutline(sampler2D tex,float4 rawCol, float2 uv,float4 outlineColor,float alpha,float width,float glow){
                float3 col =abs(_GetPixel(tex,uv , 0,width ) - _GetPixel(tex,uv , 0,-width ));
                col += abs(_GetPixel(tex,uv , width,0 ) - _GetPixel(tex,uv , -width,0 )); 

                col *= rawCol.a * alpha;
                fixed4 innerOutlineVal = length(col) * glow;
                rawCol.rgb = lerp(rawCol.rgb,outlineColor,innerOutlineVal);
                return rawCol;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = lerp(0,col.rgb,col.a) ;
                col = DrawInnerOutline(_MainTex,col,i.uv,_OutlineColor,_Alpha,_Width,_Glow); 
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
