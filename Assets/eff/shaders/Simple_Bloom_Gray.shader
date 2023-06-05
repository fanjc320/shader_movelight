Shader "Simple/Bloom_Gray"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LuminanceThreshold("_LuminanceThreshold", Range(0,1)) = 0.01
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _MainTex_TexelSize;


            float _LuminanceThreshold;//bloom ¡¡∂»„–÷µ


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
             

                return o;
            }

            fixed luminance(fixed4 color) {
                return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 colsrc = tex2D(_MainTex, i.uv);

                fixed val = clamp(luminance(colsrc) - _LuminanceThreshold, 0.0, 1.0);

              
                return colsrc * val;

            }
            ENDCG
        }
    }
}
