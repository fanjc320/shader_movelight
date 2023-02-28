// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Rim"
{
	/*�����������UI���
	https://docs.unity3d.com/cn/current/Manual/SL-Properties.html
	https://docs.unity3d.com/cn/current/ScriptReference/MaterialPropertyDrawer.html
	*/
	Properties
	{
		_MainTex("Texture", 2D) = "" {}
		_MainColor("Main Color",Color) = (1,1,1,1)
		_Emiss("Emiss", Float) = 1.0
		_Speed("Speed", Vector) = (.34, .85, .92, 1)
	}
	SubShader
	{
			/*
		��ǩ���ԣ������֣�һ����SubShader�㼶��һ����Pass�㼶
		https://docs.unity3d.com/cn/current/Manual/SL-SubShaderTags.html
		https://docs.unity3d.com/cn/current/Manual/SL-PassTags.html
		*/
		Tags { "Queue" = "Transparent" }
		Pass
		{
			Cull Off
			ZWrite On
			ColorMask 0
			CGPROGRAM
			float _Color;
			#pragma vertex vert
			#pragma fragment frag

			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertexPos);
			}

			float4 frag(void) : COLOR
			{
				return _Color;
			}
			ENDCG
		}
		Pass
		{
			//Blending:https://docs.unity3d.com/Manual/SL-Blend.html
			ZWrite Off
			//Blend SrcAlpha OneMinusSrcAlpha 
			Blend SrcAlpha One
			//Blend DstColor Zero

			CGPROGRAM  // Shader��������￪ʼ	
			#pragma vertex vert //ָ��һ����Ϊ"vert"�ĺ���Ϊ����Shader
			#pragma fragment frag //ָ��һ����Ϊ"frag"����ΪƬԪShader

			#include "UnityCG.cginc"  //����Unity���õ��ļ����ܷ��㣬�кܶ��ֳɵĺ����ṩʹ��

			struct appdata  //CPU�򶥵�Shader�ṩ��ģ������
			{
				float4 vertex : POSITION; //ģ�Ϳռ䶥������
				half2 texcoord0 : TEXCOORD0; //��һ��UV
				half3 normal : NORMAL; //���㷨��
			};

			struct v2f  //�Զ������ݽṹ�壬������ɫ����������ݣ�Ҳ��ƬԪ��ɫ����������
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 pos_world : TEXCOORD1;
				float3 normal_world : TEXCOORD2;
			};

			/*
			Shader�ڵı������������������Propertiesģ���ڵĲ���ͬ�����Ϳ��Բ�������
			*/
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Cutout;
			float4 _Speed;
			sampler2D _NoiseMap;
			float4 _NoiseMap_ST;
			float4 _MainColor;
			float _Emiss;

			//Unity���ñ�����https://docs.unity3d.com/Manual/SL-VertexProgramInputs.html

		    //����Shader
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
				o.pos_world = pos_world.xyz;
				o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				return o;
			}
			//ƬԪShader
			half4 frag(v2f i) : SV_Target //SV_Target��ʾΪ��ƬԪShader�����Ŀ��أ���ȾĿ�꣩
			{
				float3 normal_world = normalize(i.normal_world);
				float3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
				float NdotV = saturate(dot(normal_world, view_world));
				float alpha = saturate(_MainColor.a / NdotV);
				return float4(_MainColor.xyz * _Emiss, alpha);
			}
			ENDCG // Shader������������
		}
	}
}
