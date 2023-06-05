Shader "Custom/Transparent_Liuguang"
{

	/*SubShader
	{
		Tags {"Queue" = "Background"}
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off
		ZWrite On
		ZTest Always
		Pass
		{
			Color(0,0,0,0)
		}
	}*/


	Properties{
		_Color("Color", Color) = (1,1,1,1)
		//_Color("Color", Color) = (0,0,0,0)
		//_MainTex("Albedo (RGB)", 2D) = "white" {}
		_MainTex("Albedo (RGB)", 2D) = "white" {}
			//流光图
			_LightTex("Light Texture",2D) = "white"{}
		//遮罩图
		_MaskTex("Mask Texture",2D) = "white"{}
		//流光颜色
		_MoveLightColor("MoveLightColor", Color) = (1,1,1,1)
			//流光uv x轴速度
			_SpeedX("SpeedX", Range(-1,1)) = 0.0
			//流光uv y轴速度
			_SpeedY("SpeedY", Range(-1,1)) = 0.0
			//流光宽度
			_LightWidth("LightWidth",Range(1,20)) = 1

			_Cutoff("透明裁切", Range(0,1))=0.5
	}
		SubShader{
			Tags { "RenderType" = "Transparent" }
			//Tags {"Queue" = "Transparent" }
			LOD 200
			//Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _LightTex;
			sampler2D _MaskTex;
			float4 _MoveLightColor;
			float _SpeedY;
			float _SpeedX;
			float _LightWidth;

			//在CG程序中，我们有这样的约定，在一个贴图变量（在我们例子中是_MainTex）之前加上uv两个字母，就代表提取它的uv值（其实就是两个代表贴图上点的二维坐标 ）。
			//我们之后就可以在surf程序中直接通过访问uv_MainTex来取得这张贴图当前需要计算的点的坐标值了。
			struct Input
			{
				float2 uv_MainTex;
			};

			fixed4 _Color;

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				//计算流光宽度uv坐标越少，则获取白色流光图白色区域越大，就等于流光长度
				float2 uv = IN.uv_MainTex / _LightWidth;
				//流光图y轴偏移
				uv.y += _Time.y * _SpeedY;
				//流光图x轴偏移
				uv.x += _Time.y * _SpeedX;
				//获取流光图的蓝色通道，因为流光图都是黑白，获取红色绿色通道都可以
				fixed light = tex2D(_LightTex, uv).b;
				//获取要显示流光的位置，我这里使用蓝色通道来处理，我这边不用alpha来处理，因为透明图占内存
				fixed maskb = tex2D(_MaskTex, IN.uv_MainTex).b;
				//这里算出要流光的地方叠加颜色
				//fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color + light * _MoveLightColor * maskb;
				fixed4 c = light * _MoveLightColor * maskb;
				o.Albedo = c.rgb;
				
				//o.Alpha = c.a;
				o.Alpha = 0.0;
			}
			ENDCG
		}
			FallBack "Diffuse"
}