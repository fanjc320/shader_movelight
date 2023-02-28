Shader "Custom/Clip_rongjie_direction" //Shader����������  ������·��ʽ�ĸ�ʽ
{
	/*�����������UI���
	https://docs.unity3d.com/cn/current/Manual/SL-Properties.html
	https://docs.unity3d.com/cn/current/ScriptReference/MaterialPropertyDrawer.html
	https://zhuanlan.zhihu.com/p/93194054
	*/
	Properties
	{
		_MainTex("Texture", 2D) = "" {}
		_MainColor("Main Color",Color) = (1,1,1,1)
		_NoiseMap("NoiseMap", 2D) = "" {}
		_Cutout("Cutout", Range(0.0,1.1)) = 0.25
		_LineWidth("LineWidth", Range(0,1)) = 0.5
		_OffsetY("OffsetY", Range(0,1)) = 0.5
	}
		/*
		����Ϊ�����������һ��Shader�ļ���д���ְ汾��Shader����ֻ��һ���ᱻʹ�á�
		�ṩ����汾��SubShader��Unity���Ը��ݶ�Ӧƽ̨ѡ������ʵ�Shader
		�������LOD����һ��ʹ�á�
		һ��дһ������
		*/
		SubShader
		{
			/*
			��ǩ���ԣ������֣�һ����SubShader�㼶��һ����Pass�㼶
			https://docs.unity3d.com/cn/current/Manual/SL-SubShaderTags.html
			https://docs.unity3d.com/cn/current/Manual/SL-PassTags.html
			*/
			Tags { "RenderType" = "Opaque" "DisableBatching" = "True"}
			/*
			Pass���������Shader�������������õĵط���
			һ��Pass��Ӧһ������������������GPU�ϵ�������ɫ��(Vertex-Fragment Shader)
			һ��SubShader������԰������Pass��ÿ��Pass�ᱻ��˳��ִ��
			*/
			Pass
			{
				CGPROGRAM  // Shader��������￪ʼ
				#pragma vertex vert //ָ��һ����Ϊ"vert"�ĺ���Ϊ����Shader
				#pragma fragment frag //ָ��һ����Ϊ"frag"����ΪƬԪShader
				#include "UnityCG.cginc"  //����Unity���õ��ļ����ܷ��㣬�кܶ��ֳɵĺ����ṩʹ��

				//https://docs.unity3d.com/Manual/SL-VertexProgramInputs.html
			struct appdata  //CPU�򶥵�Shader�ṩ��ģ������
			{
			//ð�ź�������ض�����ʣ�����CPU��Ҫ��Щ���Ƶ�����
			float4 vertex : POSITION; //ģ�Ϳռ䶥������
			half2 texcoord0 : TEXCOORD0; //��һ��UV
			//half2 texcoord1 : TEXCOORD1; //�ڶ���UV
			//half2 texcoord2 : TEXCOORD2; //�ڶ���UV
			//half2 texcoord4 : TEXCOORD3;  //ģ�����ֻ����4��UV

			//half4 color : COLOR; //������ɫ
			//half3 normal : NORMAL; //���㷨��
			//half4 tangent : TANGENT; //��������(ģ�͵���Unity���Զ�����õ�)
			};

			struct v2f  //�Զ������ݽṹ�壬������ɫ����������ݣ�Ҳ��ƬԪ��ɫ����������
			{
				float4 pos : SV_POSITION; //����ü��ռ��µĶ����������ݣ�����դ��ʹ�ã�����Ҫд������
				float4 uv : TEXCOORD0; //�Զ���������
				//ע����Ϸ���TEXCOORD�������ǲ�һ���ģ��Ϸ��������UV������������������ݡ�
				//��ֵ���������ᱻ��դ�����в�ֵ��������Ϊ�������ݣ�����ƬԪShader
				//������д16����TEXCOORD0 ~ TEXCOORD15��
				//float3 pos_local : TEXCOORD1;
				//float3 pos_pivot : TEXCOORD2;
			};

		/*
		Shader�ڵı������������������Propertiesģ���ڵĲ���ͬ�����Ϳ��Բ�������
		*/
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Cutout;
		float _LineWidth;
		sampler2D _NoiseMap;
		float4 _NoiseMap_ST;
		float4 _MainColor;

		//����Shader
		v2f vert(appdata v)
		{
			v2f o;
			float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
			float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
			float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);
			o.pos = pos_clip;
			//o.pos = UnityObjectToClipPos(v.vertex);
			o.uv.xy = v.texcoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
			o.uv.zw = v.texcoord0 * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
			//o.uv = TRANSFORM_TEX(v.uv, _MainTex);//Ϊ�α���?
			//o.uv = v.uv;//����
			return o;
		}

		half4 frag(v2f i) : SV_Target
		{
			half4 bb = tex2D(_NoiseMap, i.uv);
			float clipValue = bb.r - _Cutout;
			clip(clipValue);
			half4 aa = tex2D(_MainTex, i.uv);
			float edgeFactor = saturate(clipValue / (_LineWidth * _Cutout));
			return lerp(_MainColor,aa, edgeFactor);
		}

		ENDCG // Shader������������
		}
	}
}

//һ��saturate��clamp
//
//saturate(v) : ��v��ȡ��[0, 1]����.
//
//clamp(v, min, max) : ��v��ȡ��[min, max]����
//����fmod��frac
//
//fmod(x, y) : ���� x / y ��С������.�� : x = i * y + f
//
//frac(x) : ����x��С������.

//lerp(a, b, w) ����w����a��b֮��Ĳ�ֵ a, b, w����Ϊ����Ҳ����Ϊ��������������Ӧ��ͳһ����Ϊ����ʱ����Ҳ��Ҫͳһ�� �൱�� float3 lerp(float3 a, float3 b, float w) { return a + w * (b - a); } �ɴ˿ɼ� �� w = 0ʱ����a.��w = 1ʱ ����b.