Shader "Custom/Clip_rongjie_direction1" //Shader的真正名字  可以是路径式的格式
{
	/*材质球参数及UI面板
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
		_OffsetY("OffsetY", Range(-1,1)) = 0.5
	}
		/*
		这是为了让你可以在一个Shader文件中写多种版本的Shader，但只有一个会被使用。
		提供多个版本的SubShader，Unity可以根据对应平台选择最合适的Shader
		或者配合LOD机制一起使用。
		一般写一个即可
		*/
		SubShader
		{
			/*
			标签属性，有两种：一种是SubShader层级，一种在Pass层级
			https://docs.unity3d.com/cn/current/Manual/SL-SubShaderTags.html
			https://docs.unity3d.com/cn/current/Manual/SL-PassTags.html
			*/
			Tags { "RenderType" = "Opaque" "DisableBatching" = "True"}
			/*
			Pass里面的内容Shader代码真正起作用的地方，
			一个Pass对应一个真正意义上运行在GPU上的完整着色器(Vertex-Fragment Shader)
			一个SubShader里面可以包含多个Pass，每个Pass会被按顺序执行
			*/
			Pass
			{
				CGPROGRAM  // Shader代码从这里开始
				#pragma vertex vert //指定一个名为"vert"的函数为顶点Shader
				#pragma fragment frag //指定一个名为"frag"函数为片元Shader
				#include "UnityCG.cginc"  //引用Unity内置的文件，很方便，有很多现成的函数提供使用

				//https://docs.unity3d.com/Manual/SL-VertexProgramInputs.html
			struct appdata  //CPU向顶点Shader提供的模型数据
			{
			//冒号后面的是特定语义词，告诉CPU需要哪些类似的数据
			float4 vertex : POSITION; //模型空间顶点坐标
			half2 texcoord0 : TEXCOORD0; //第一套UV
			//half2 texcoord1 : TEXCOORD1; //第二套UV
			//half2 texcoord2 : TEXCOORD2; //第二套UV
			//half2 texcoord4 : TEXCOORD3;  //模型最多只能有4套UV

			//half4 color : COLOR; //顶点颜色
			//half3 normal : NORMAL; //顶点法线
			//half4 tangent : TANGENT; //顶点切线(模型导入Unity后自动计算得到)
			};

			struct v2f  //自定义数据结构体，顶点着色器输出的数据，也是片元着色器输入数据
			{
				float4 pos : SV_POSITION; //输出裁剪空间下的顶点坐标数据，给光栅化使用，必须要写的数据
				float4 uv : TEXCOORD0; //自定义数据体
				float4 worldPos : TEXCOORD1;
			};

		/*
		Shader内的变量声明，如果跟上面Properties模块内的参数同名，就可以产生链接
		*/
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Cutout;
		float _LineWidth;
		float _OffsetY;
		sampler2D _NoiseMap;
		float4 _NoiseMap_ST;
		float4 _MainColor;

		//顶点Shader
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
			//o.uv = TRANSFORM_TEX(v.uv, _MainTex);//为何报错?
			//o.uv = v.uv;//报错
			o.worldPos = pos_world;
			return o;
		}

		//https://blog.csdn.net/shi_tou_ge/article/details/107894372

		fixed4 frag(v2f i) : SV_Target
		{
			float clip_value = _OffsetY - i.worldPos.y;
			clip(clip_value);
			// sample the texture
			fixed4 col = tex2D(_MainTex, i.uv);
			float per = saturate(clip_value / _LineWidth);

			return lerp(col , _MainColor,1 - per);//fjc:lerp控制渐变，_LineWidth控制了渐变的暗色范围
		}


		ENDCG // Shader代码从这里结束
		}
	}
}
//定向溶解还有个更好的工程 叫Dissolve

//一、saturate，clamp
//
//saturate(v) : 将v夹取到[0, 1]区间.
//
//clamp(v, min, max) : 将v夹取到[min, max]区间
//二、fmod，frac
//
//fmod(x, y) : 返回 x / y 的小数部分.如 : x = i * y + f
//
//frac(x) : 返回x的小数部分.

//lerp(a, b, w) 根据w返回a到b之间的插值 a, b, w可以为标量也可以为向量，但是三者应该统一。且为向量时长度也需要统一。 相当于 float3 lerp(float3 a, float3 b, float w) { return a + w * (b - a); } 由此可见 当 w = 0时返回a.当w = 1时 返回b.