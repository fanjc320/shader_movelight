Shader "Custom/Clip_rongjie" //Shader的真正名字  可以是路径式的格式
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
		_Cutout("Cutout", Range(0.0,1.1)) = 0.0
		_Speed("Speed", Vector) = (.34, .85, .92, 1)
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
				//注意跟上方的TEXCOORD的意义是不一样的，上方代表的是UV，这里可以是任意数据。
				//插值器：输出后会被光栅化进行插值，而后作为输入数据，进入片元Shader
				//最多可以写16个：TEXCOORD0 ~ TEXCOORD15。
				//float3 pos_local : TEXCOORD1;
				//float3 pos_pivot : TEXCOORD2;
			};

		/*
		Shader内的变量声明，如果跟上面Properties模块内的参数同名，就可以产生链接
		*/
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Cutout;
		float4 _Speed;
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
			return o;
		}
		//clip 如果指定的值小于零，则放弃当前像素。 也就是不显示,像素被扣掉
		//片元Shader
		//half4 frag(v2f i) : SV_Target //SV_Target表示为：片元Shader输出的目标地（渲染目标）
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

		ENDCG // Shader代码从这里结束
		}
	}
}

//Direct3D 10语义	Direct3D 9等价语义
//SV_Depth		DEPTH
//SV_Position	POSITION
//SV_Target		COLOR
//SV_POSITION语义：顶点着色器的输出作为裁剪空间顶点坐标
//SV_Target语义：像素着色器的输出存储到一个渲染目标(RenderTarget)当中


//HLSL中POSTION与VS_POSITION的区别？
//
//SV_前缀的变量代表system value，在DX10以后的语义绑定中被使用代表特殊的意义，和POSITION用法并无不同。唯一区别是 SV_POSTION一旦被作为vertex shader的输出语义，那么这个最终的顶点位置就被固定了，直接进入光栅化处理，如果作为fragment shader的输入语义那么和POSITION是一样的，代表着每个像素点在屏幕上的位置，这个说法其实并不准确，事实是fragment 在view space空间中的位置，但直观的感受是如括号之前所述一般。
//
//在DX10版本之前没有引入SV_的预定义语义，POSITION被用作vertex shader的输入和输出，fragment shader的输入参数。但DX10之后就推荐使用SV_POSITION作为vertex shader的输出和fragment shader的输入，注意vertex shader的输入还是使用POSITION！ 不过，DX10以后的代码依旧兼容POSITION作为全程表达。

//clip函数会将参数小于0的像素点直接丢弃掉 比如说我们要做溶解效果 除了mainTexture可以在里面放入一张用于溶解的图 判断这张图的alpha小于某个数的像素点 可以设置一个从0到1的变量用来控制 下面是关键代码
//主要是fragment函数里 col是主贴图 secondTex是用于溶解判断的图片
//_CutOutTex是一个0到1的变量 用于控制剔除度
//
//fixed4 frag(v2f i) : SV_Target
//{
//	fixed4 col = tex2D(_MainTex, i.uv);
//	fixed4 secondTex = tex2D(_CutOutTex,i.uv);
//	clip(secondTex.rgb - _CutOutValue);
//	return col;
//}
//————————————————
//版权声明：本文为CSDN博主「程序乔」的原创文章，遵循CC 4.0 BY - SA版权协议，转载请附上原文出处链接及本声明。
//原文链接：https ://blog.csdn.net/qq_37190129/article/details/105184132