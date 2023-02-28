Shader "Custom/Clip_rongjie" //Shader����������  ������·��ʽ�ĸ�ʽ
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
		_Cutout("Cutout", Range(0.0,1.1)) = 0.0
		_Speed("Speed", Vector) = (.34, .85, .92, 1)
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
		float4 _Speed;
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
		//clip ���ָ����ֵС���㣬�������ǰ���ء� Ҳ���ǲ���ʾ,���ر��۵�
		//ƬԪShader
		//half4 frag(v2f i) : SV_Target //SV_Target��ʾΪ��ƬԪShader�����Ŀ��أ���ȾĿ�꣩
		//{
		//	half gradient = tex2D(_MainTex, i.uv.xy + _Time.y * 0.1f * _Speed.xy).r * (1.0 - i.uv.y);
		//	//half noise = 1.0 - tex2D(_NoiseMap, i.uv.zw + _Time.y * 0.1f * _Speed.zw).r;
		//	half noise = tex2D(_NoiseMap, i.uv.zw + _Time.y * 0.1f * _Speed.zw).r;
		//	clip(gradient - noise);
		//	return _MainColor;

		//}

		half frag(v2f i) : SV_Target
		{
			half col = tex2D(_MainTex, i.uv);
			half secondTex = tex2D(_NoiseMap, i.uv);
			clip(secondTex - _Cutout);
			//return _MainTex;
			return col;
		}

		ENDCG // Shader������������
		}
	}
}

//Direct3D 10����	Direct3D 9�ȼ�����
//SV_Depth		DEPTH
//SV_Position	POSITION
//SV_Target		COLOR
//SV_POSITION���壺������ɫ���������Ϊ�ü��ռ䶥������
//SV_Target���壺������ɫ��������洢��һ����ȾĿ��(RenderTarget)����


//HLSL��POSTION��VS_POSITION������
//
//SV_ǰ׺�ı�������system value����DX10�Ժ��������б�ʹ�ô�����������壬��POSITION�÷����޲�ͬ��Ψһ������ SV_POSTIONһ������Ϊvertex shader��������壬��ô������յĶ���λ�þͱ��̶��ˣ�ֱ�ӽ����դ�����������Ϊfragment shader������������ô��POSITION��һ���ģ�������ÿ�����ص�����Ļ�ϵ�λ�ã����˵����ʵ����׼ȷ����ʵ��fragment ��view space�ռ��е�λ�ã���ֱ�۵ĸ�����������֮ǰ����һ�㡣
//
//��DX10�汾֮ǰû������SV_��Ԥ�������壬POSITION������vertex shader������������fragment shader�������������DX10֮����Ƽ�ʹ��SV_POSITION��Ϊvertex shader�������fragment shader�����룬ע��vertex shader�����뻹��ʹ��POSITION�� ������DX10�Ժ�Ĵ������ɼ���POSITION��Ϊȫ�̱�

//clip�����Ὣ����С��0�����ص�ֱ�Ӷ����� ����˵����Ҫ���ܽ�Ч�� ����mainTexture�������������һ�������ܽ��ͼ �ж�����ͼ��alphaС��ĳ���������ص� ��������һ����0��1�ı����������� �����ǹؼ�����
//��Ҫ��fragment������ col������ͼ secondTex�������ܽ��жϵ�ͼƬ
//_CutOutTex��һ��0��1�ı��� ���ڿ����޳���
//
//fixed4 frag(v2f i) : SV_Target
//{
//	fixed4 col = tex2D(_MainTex, i.uv);
//	fixed4 secondTex = tex2D(_CutOutTex,i.uv);
//	clip(secondTex.rgb - _CutOutValue);
//	return col;
//}
//��������������������������������
//��Ȩ����������ΪCSDN�����������ǡ���ԭ�����£���ѭCC 4.0 BY - SA��ȨЭ�飬ת���븽��ԭ�ĳ������Ӽ���������
//ԭ�����ӣ�https ://blog.csdn.net/qq_37190129/article/details/105184132