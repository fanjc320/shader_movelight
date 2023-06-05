Shader "Simple/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BloomFactor("_BloomFactor", Range(0,10)) = 0.8//
            
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
            sampler2D _bloomTex;
            float4 _MainTex_ST;
            float _BlurPixel;
            float _BloomFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 colsrc = tex2D(_MainTex, i.uv);
                fixed4 colbloom = tex2D(_bloomTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return colbloom *_BloomFactor +colsrc;
            }
            ENDCG
        }
    }
}