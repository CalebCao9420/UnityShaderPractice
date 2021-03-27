Shader "Unlit/SpritePixelTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PixelResolution("PixelResolution", Range(4,512))=4
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
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
            float _PixelResolution;
            sampler2D _AlphaTex;
            float _EnableExternalAlpha;

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
                //  float2 uv = i.uv;
                // float2 rawUV = uv;
                // uv = floor(uv * _PixelResolution) / _PixelResolution;
                // // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // fixed4 alpha = tex2D (_AlphaTex, uv);
                // col.a = lerp (col.a, alpha.r, _EnableExternalAlpha);
                // // apply fog
                // // UNITY_APPLY_FOG(i.fogCoord, col);
                // col.rgb *= col.a;
                // return col;

                fixed4 col = fixed4(0,0,0,0);
 
                // 先放大uv,然后缩小到原来的大小，在int 然他丢失精度，从而实现像素风格（马赛克风格）
                float ratio_u = floor(i.uv.x * _PixelResolution)/_PixelResolution;
                float ratio_v = floor(i.uv.y * _PixelResolution)/_PixelResolution;

                float2 pixelVal=(int)(i.uv * _PixelResolution)/_PixelResolution;
 
                col = tex2D(_MainTex,fixed2(ratio_u,ratio_v));
                // col = tex2D(_MainTex,fixed2(pixelVal));
 
                // 混合颜色返回
                return col ;

            }
            ENDCG
        }
    }
}
