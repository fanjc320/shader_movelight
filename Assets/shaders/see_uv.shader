Shader "Custom/see_uv"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            float4 _MainTex_ST;//主贴图的UV坐标调节

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //把模型uv添加 属性中的UV调节 (如果UV不变化可以写) o.uv = v.uv;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //return col;

                //直接把UV坐标作为RG颜色输出， 用取余的方法查看大于1的数据变化
                return float4(i.uv.x%1, i.uv.y%1, 0, 0);
            }
            ENDCG
        }
    }
}

//https://zhuanlan.zhihu.com/p/387898772
//使用 “TRANSFORM_TEX” 来把原始模型ＵＶ转换为调节后的UV。
//
//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
//
//其实　 _MainTex＿ST存贮了UV的倍增和偏移　4个数据；
//
//运行机制就是“倍增”用乘法　＂偏移＂用加法
//
//o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
//
//使用
//
//return float4(i.uv.x % 1, i.uv.y % 1, 0, 0);
//
//把UV转为颜色显示在模型上。
//
//（用取余的方法查看大于1的数据变化。）