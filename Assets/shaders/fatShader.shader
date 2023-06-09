// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/fatShader"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Diffuse("diffuse",Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Specular("specular",Color) = (1,1,1,1)
		_Gloss("gloss",Range(0,2)) = 0.6
		_DepthColor("DepthColor", Color) = (1,1,1,1)
		_YHeight("YHeight",float) = 1
		_XHeight("XHeight",float) = 1
		_Scale("Scale",float) = 1
		_Range("Range",Range(-1,1)) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass//ForwardBase
			{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct appdata members vertColor)
						#pragma exclude_renderers d3d11
						#pragma multi_compile_fwdbase
						#pragma vertex vert
						#pragma fragment frag

						#include "UnityCG.cginc"
						#include "Lighting.cginc"
						#include "AutoLight.cginc"

						fixed4 _Diffuse;
						fixed4 _Specular;
						float _Gloss;
						fixed4 _DepthColor;
						fixed4 _Color;
						float _YHeight;
						float _XHeight;
						sampler2D _MainTex;
						float4 _MainTex_ST;
						float _Scale;
						float _Range;

						struct appdata
						{
							float4 vertex : POSITION;
							float3 normal:NORMAL;
							float4 texcoord : TEXCOORD0;
							float4 vertColor:COLOR;
						};

						struct v2f
						{
							float4 pos : SV_POSITION;
							float3 worldNormal:TEXCOORD0;
							float3 worldPos:TEXCOORD1;
							float3 vertexLight : TEXCOORD2;
							float4 projPos:TEXCOORD3;
							float2 uv : TEXCOORD4;
							float4 Color:COLOR;
							SHADOW_COORDS(5)//��������Ӱ
						};


						v2f vert(appdata v)
						{
							v2f o;
							float y = sin(v.vertex.y - _YHeight);
							float x = sin(v.vertex.x - _XHeight);
							float target = x * y;
							if (target < 0)
							{
								target = 0;
							}
							v.vertex.xyz += v.normal * target * _Scale;

							o.pos = UnityObjectToClipPos(v.vertex);
							o.worldNormal = UnityObjectToWorldNormal(v.normal);
							o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
							o.projPos = ComputeScreenPos(o.pos);
							o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
							#ifdef LIGHTMAP_OFF
							float3 shLight = ShadeSH9(float4(v.normal, 1.0));
							o.vertexLight = shLight;
			#ifdef VERTEXLIGHT_ON
							float3 vertexLight = Shade4PointLights(
								unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
								unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
								unity_4LightAtten0, o.worldPos, o.worldNormal
							);
							o.vertexLight += vertexLight;
			#endif
			#endif
							TRANSFER_SHADOW(o);//��������Ӱ
							return o;
						}

						fixed4 frag(v2f i) : SV_Target
						{
							fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
							float3 worldNormal = normalize(i.worldNormal);
							float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
							fixed4 albedo = tex2D(_MainTex, i.uv);
							float diff = max(0,dot(worldLightDir,worldNormal));
							//��������ϵ��
							diff = diff * 0.5 + _Gloss;
							//���������������˹���˥���Լ���Ӱ,��ΪForwardBase�����ع�Դһ���Ƿ���⣬˥��Ϊ1��atten������ʵ������Ӱֵ
							UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
							float3 diffcolor = diff * albedo.rgb * atten;
							//������ɫ
							float4 color = float4((diffcolor + ambient) * _Color,_DepthColor.a) * atten;
							fixed4 endcolor = float4((diffcolor + ambient) * _DepthColor,_DepthColor.a) * atten;
							fixed s = sin(i.worldPos.y / 100);
							fixed3 fincolor = lerp(endcolor.rgb,color.rgb, s);
							return float4(fincolor,1);
						}
						ENDCG
					}

					Pass//������Ӱ��ͨ��(����͸��Ҳ������Ӱ)
					{
						Tags { "LightMode" = "ShadowCaster" }

						CGPROGRAM
						#pragma vertex vert
						#pragma fragment frag
						#pragma target 2.0
						#pragma multi_compile_shadowcaster
						#pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
						#include "UnityCG.cginc"

						struct v2f {
							V2F_SHADOW_CASTER;
							UNITY_VERTEX_OUTPUT_STEREO
						};

						v2f vert(appdata_base v)
						{
							v2f o;
							UNITY_SETUP_INSTANCE_ID(v);
							UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
							TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
							return o;
						}

						float4 frag(v2f i) : SV_Target
						{
							SHADOW_CASTER_FRAGMENT(i)
						}
						ENDCG
					}
		}
}