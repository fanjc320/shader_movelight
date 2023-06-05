Shader "Simple/Water"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NoiseTex("Noise Tex", 2D) = "white" {} //�Ŷ�ͼ
		_NoisePower("Noise Power", Range(0,1)) = 0.01//�Ŷ�ǿ��
		_BlurPixel("_BlurPixel", Range(0,1)) = 0.01//ģ����

		_WaterLine("Water Line Y" , Range(0,1)) = 0.33//ˮ��
		_FoamLine("Foam Depth" , Range(0,1)) = 0.03//��ĭ���

		_WaterColor("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
		_WaterColorDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)

		_SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100
			Pass
			{

				ZTest Always
				ZWrite Off

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

			float4 _MainTex_ST;
			float _WaterLine;

			sampler2D _NoiseTex;
			float _NoisePower;

			float _BlurPixel;

			float4 _WaterColor;
			float4 _WaterColorDeep;

			float _SurfaceNoiseCutoff;
			float _FoamLine;

			sampler2D _customTex;
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex).xy;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			fixed4 texblur(sampler2D tex, float2 uv)
			{
			   fixed4 col = tex2D(tex, uv + float2(0, 1) * 0.01 * _BlurPixel);
				col += tex2D(tex, uv + float2(0, -1) * 0.01 * _BlurPixel);
				col += tex2D(tex, uv + float2(-1, 0) * 0.01 * _BlurPixel);
				col += tex2D(tex, uv + float2(1, 0) * 0.01 * _BlurPixel);
				//  col += tex2D(tex, uv + float2(-1, 1) * 0.01 * _BlurPixel) ;
				 // col += tex2D(tex, uv +  float2(1, 1) * 0.01 * _BlurPixel) ;
				 // col += tex2D(tex, uv +  float2(-1, -1) * 0.01 * _BlurPixel);
				 // col += tex2D(tex, uv +  float2(1, -1) * 0.01 * _BlurPixel);
				  return col / 4;
			  }
			fixed4 frag(v2f i) : SV_Target
			{

				// sample the texture

				fixed4 col = tex2D(_MainTex, i.uv);



				if (i.uv.y < _WaterLine)
				{
					float cut = tex2D(_customTex, i.uv).r;
					if (cut < 0.5)
						return col;

					//�������Ŷ�
					//�������������Ŷ�
					float disTex = tex2D(_NoiseTex, float2(i.uv.x + _Time.x, i.uv.y + _Time.x)).r;


					float2 offsetUV = float2(disTex, disTex * 0.5);

					//���� + ˮ�� ��ɫ
					float waterDepthDifference01 = saturate((_WaterLine - i.uv.y) / _WaterLine);
					float4 waterColor = lerp(_WaterColor, _WaterColorDeep, waterDepthDifference01);

					float2 nv = float2(i.uv.x, _WaterLine + (_WaterLine - i.uv.y));
					fixed4 refc = texblur(_MainTex, nv + (offsetUV - 0.5) * 2 * 0.01 * _NoisePower) * waterColor;

					
					//����͵��ֱ��������ͼ��ˮ��ͼ
					//С��������ˮ���Ŷ�
					float2 offsetNoiseUV = float2(disTex, 0);
					float disTex5 = tex2D(_NoiseTex, float2(i.uv.x * 2.0 + _Time.x, i.uv.y * 10.0) + offsetNoiseUV).r;
					col = lerp(col,  refc, _WaterColor.a);

					float whitepower = saturate(1.0 - (_WaterLine - i.uv.y) / _FoamLine);
					//float whitepower =(1- waterDepthDifference01)* (1 - waterDepthDifference01);
					//if (whitepower < 0.95)whitepower = 0;
					float surfaceNoise = disTex5 * whitepower > (_SurfaceNoiseCutoff) ? 1 : 0;
					//if (whitepower < 0.95)
					   // whitepower *= surfaceNoise;
					col.xyz += surfaceNoise;
				}
				// apply fog
				//col.r = 1.0-col.b*2.0;
				//col.g = 0;
				return col;
			}
			ENDCG
		}
		}
}
