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
            float4 _MainTex_ST;//����ͼ��UV�������

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //��ģ��uv��� �����е�UV���� (���UV���仯����д) o.uv = v.uv;
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

                //ֱ�Ӱ�UV������ΪRG��ɫ����� ��ȡ��ķ����鿴����1�����ݱ仯
                return float4(i.uv.x%1, i.uv.y%1, 0, 0);
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