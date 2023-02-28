Shader "Custom/jianbian_uv"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Intensity("liangdu", Range(0, 3)) = 2 // ����

        _MoveSpeed_U("U speed", Range(0,10))=0
        _MoveSpeed_V("V speed", Range(0,10))=0

        _UVRampTex("RampTex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Blend One One
            //�رղ��У�����˫����Ⱦ
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
            float4 _MainTex_ST;//����ͼ��UV�������
            float4 _Color;
            float _Intensity;

            float _MoveSpeed_U;
            float _MoveSpeed_V;

            sampler2D _UVRampTex;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //��ģ��uv���� �����е�UV���� (���UV���仯����д) o.uv = v.uv;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


            half4 frag(v2f i) : SV_Target
            {
                float2 uvOffset = float2(_MoveSpeed_U, _MoveSpeed_V) * _Time.y;
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv + uvOffset);
                half4 ramp = tex2D(_UVRampTex, i.uv);
                //��ɫ����͸��������˿Ч������
                //�������ͼ��׼ȷ https://zhuanlan.zhihu.com/p/387898772
                col.rgb *= col.a;
                //�ð�ɫ�����ٵ���ͼ��������ͼ�ϰ벿��
                col.rgb += ramp.b;
                //�ð�ɫ��������ͼ��ѹ����ͼ���°벿��
                col.rgb *= ramp.g;

                clip(col.r - 0.4);//������5��6��7����rͨ���Ƚϰ������޳�����

                col *= _Color * _Intensity;
                //apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}

//https://zhuanlan.zhihu.com/p/387898772
//ʹ�� ��TRANSFORM_TEX�� ����ԭʼģ�ͣգ�ת��Ϊ���ں��UV��
//
//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
//
//��ʵ�� _MainTex��ST������UV�ı�����ƫ�ơ�4�����ݣ�
//
//���л��ƾ��ǡ��������ó˷�����ƫ�ƣ��üӷ�
//
//o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
//
//ʹ��
//
//return float4(i.uv.x % 1, i.uv.y % 1, 0, 0);
//
//��UVתΪ��ɫ��ʾ��ģ���ϡ�
//
//����ȡ��ķ����鿴����1�����ݱ仯����

//5.��Ӱ����ת����������ת����UNITY_TRANSFER_SHADOWλ��AutoLight.cginc��UNITY_TRANSFER_FOGλ��UnityCG.cginc�����ļ�������SM��ͬ��ѡ���𶥵�������صļ��㡣
//frag �����е� UNITY_APPLY_FOG
//#ifdef UNITY_PASS_FORWARDADD
//#define UNITY_APPLY_FOG(coord,col) UNITY_APPLY_FOG_COLOR(coord,col,fixed4(0,0,0,0))
//#else
//#define UNITY_APPLY_FOG(coord,col) UNITY_APPLY_FOG_COLOR(coord,col,unity_FogColor)
//#endif
//
//������Կ�������Ӧ֮ǰ�� Helper ��˵�ģ�forward add�Ļ�����ʹ�ú�ɫ��Ϊ����ɫ
//��������������������������������
//��Ȩ����������ΪCSDN������Jave.Lin����ԭ�����£���ѭCC 4.0 BY - SA��ȨЭ�飬ת���븽��ԭ�ĳ������Ӽ���������
//ԭ�����ӣ�https ://blog.csdn.net/linjf520/article/details/105558069