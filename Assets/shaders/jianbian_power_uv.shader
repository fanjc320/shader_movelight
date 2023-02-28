Shader "Custom/jianbian_pow_uv"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)

        _MoveSpeed_U("U speed", Range(-10,10))=0.3
        _MoveSpeed_V("V speed", Range(-10,10))=2

        /*_UVRampTex("RampTex", 2D) = "white" {}*/
        //次方范围控制
        _AddPow("top fire control range", Range(1,50)) = 40
        _MultiplyPow("down fade range", Range(0,1)) = 0.3
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Blend One One
            //关闭裁切，开启双面渲染
            Cull Off

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
            float4 _Color;

            float _MoveSpeed_U;
            float _MoveSpeed_V;

            float _AddPow;
            float _MultiplyPow;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //把模型uv添加 属性中的UV调节 (如果UV不变化可以写) o.uv = v.uv;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


            half4 frag(v2f i) : SV_Target
            {
                float2 uvOffset = float2(_MoveSpeed_U, _MoveSpeed_V) * _Time.y;
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv + uvOffset);
                //顶端相加影响，过度白色少
                col += pow(i.uv.y, _AddPow) * _AddPow;
                //低端相乘影响，过度白色多
                col *= pow(i.uv.y, _MultiplyPow);
                clip(col.r - 0.5);//纹理中5，6，7部分r通道比较暗，被剔除掉了
                col *= _Color;
                //apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
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

//5.阴影坐标转换，雾坐标转换。UNITY_TRANSFER_SHADOW位于AutoLight.cginc，UNITY_TRANSFER_FOG位于UnityCG.cginc。雾的计算会根据SM不同，选择逐顶点或逐像素的计算。
//frag 函数中的 UNITY_APPLY_FOG
//#ifdef UNITY_PASS_FORWARDADD
//#define UNITY_APPLY_FOG(coord,col) UNITY_APPLY_FOG_COLOR(coord,col,fixed4(0,0,0,0))
//#else
//#define UNITY_APPLY_FOG(coord,col) UNITY_APPLY_FOG_COLOR(coord,col,unity_FogColor)
//#endif
//
//这个可以看到，对应之前的 Helper 里说的，forward add的话，会使用黑色作为雾颜色
//————————————————
//版权声明：本文为CSDN博主「Jave.Lin」的原创文章，遵循CC 4.0 BY - SA版权协议，转载请附上原文出处链接及本声明。
//原文链接：https ://blog.csdn.net/linjf520/article/details/105558069