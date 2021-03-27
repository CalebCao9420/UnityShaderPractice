Shader "Unlit/007Outline(Outter)"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor("OutlineColor" , Color  ) = (1,1,1,1)
        _Width("OutlineWidth" , Range(0,2)) = 0
        _Alpha("Alpha" ,Range(0,1)) =0
        _Glow("Glow" ,Range(0,100)) =1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Cull Off
        Lighting Off
        ZWrite  Off
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
            float4 _OutlineColor;
            float _Width;
            float _Alpha;
            float _Glow;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 Outline(float4 rawCol,sampler2D tex,float2 uv,float4 color,float width){
                fixed4 temp= tex2D(tex, uv + float2(width,width)) * color;
                return fixed4(rawCol.r,rawCol.g,rawCol.b,rawCol.a  * temp.a);
            }

            float GetBorderAlpha(sampler2D tex,float2 uv,float offset){
                //left right up down
                fixed left= tex2D(tex,uv + float2(-offset,0)).a;
                fixed right= tex2D(tex,uv + float2(offset,0)).a;
                fixed up= tex2D(tex,uv + float2(0,offset)).a;
                fixed down= tex2D(tex,uv + float2(0,-offset)).a;

                fixed result= left + right + up + down;
                //leftUp rightUp leftDown rightDown
                fixed leftUp= tex2D(tex, uv + float2(-offset,offset)).a;
                fixed leftDown= tex2D(tex, uv + float2(-offset,-offset)).a;
                fixed rightUp= tex2D(tex, uv + float2(offset,offset)).a;
                fixed rightDown= tex2D(tex, uv + float2(offset,-offset)).a;
                result += (leftUp + leftDown + rightUp + rightDown);

                return result;
            }

            float4 DrawOutline(float4 rawCol,sampler2D tex,float2 uv, float4 color, float width ,float alpha, float glow){
                float innterAlpha=GetBorderAlpha(tex,uv,width);
                innterAlpha = step(0.01,innterAlpha);
                innterAlpha *= (1 - rawCol.a) * alpha;
                float4 result = innterAlpha * color * glow *2;
                return lerp(result,rawCol,rawCol.a);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col= DrawOutline(col,_MainTex,i.uv,_OutlineColor,_Width,_Alpha,_Glow);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
