Shader "Simple/Bloom_Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _offsets("_offsets", Vector) = (0,0,0,0)
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
                float4 uv01 : TEXCOORD1;    //一个vector4存储两个纹理坐标  
                float4 uv23 : TEXCOORD2;    //一个vector4存储两个纹理坐标  
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _MainTex_TexelSize;


            float2 _offsets;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                _offsets *= _MainTex_TexelSize.xyxy;
                //由于uv可以存储4个值，所以一个uv保存两个vector坐标，_offsets.xyxy * float4(1,1,-1,-1)可能表示(0,1,0-1)，表示像素上下两个  
                //坐标，也可能是(1,0,-1,0)，表示像素左右两个像素点的坐标，下面*2.0，*3.0同理  
                o.uv01 = v.uv.xyxy + _offsets.xyxy * float4(1, 1, -1, -1);
                o.uv23 = v.uv.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 2.0;

                return o;
            }

 
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 colsrc = tex2D(_MainTex, i.uv);


                fixed4 color = fixed4(0, 0, 0, 0);
                color += 0.4026 * colsrc;
                color += 0.2442 * tex2D(_MainTex, i.uv01.xy);
                color += 0.2442 * tex2D(_MainTex, i.uv01.zw);
                color += 0.0545 * tex2D(_MainTex, i.uv23.xy);
                color += 0.0545 * tex2D(_MainTex, i.uv23.zw);
                return color;

            }
            ENDCG
        }
    }
}
