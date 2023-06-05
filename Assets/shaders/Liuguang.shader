Shader "Unlit/AlphaTest"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        _CutOff("Alpha CutOff", Range(0,1)) = 0.5


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

            //uv_MainTex("uv_MainTex", float2) = (0,0)
    }
        SubShader
        {
            Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "Ture" "RenderType" = "TransparentCutout" }

            Pass
            {
                Tags {"LightMode" = "ForwardBase"}

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Lighting.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float3 worldNormal : TEXCOORD1;
                    float3 worldPos : TEXCOORD2;
                };

                fixed4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                fixed _CutOff;

                sampler2D _LightTex;
                sampler2D _MaskTex;
                float4 _MoveLightColor;
                float _SpeedY;
                float _SpeedX;
                float _LightWidth;

                    float2 uv_MainTex;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed3 worldNormal = normalize(i.worldNormal);
                    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                    fixed4 texColor = tex2D(_MainTex, i.uv);

                    //// Alpha Test
                    /*clip(texColor.a - _CutOff);*/

                    //fixed3 albedo = texColor.rgb * _Color.rgb;
                    //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                    //fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldLightDir, worldNormal));

                    //return fixed4(ambient + diffuse, 1.0);



                    //计算流光宽度uv坐标越少，则获取白色流光图白色区域越大，就等于流光长度
                    //float2 uv = i.uv / _LightWidth;
                    float2 uv = i.uv / _LightWidth;
                    //流光图y轴偏移
                    uv.y += _Time.y * _SpeedY;
                    //流光图x轴偏移
                    uv.x += _Time.y * _SpeedX;
                    //获取流光图的蓝色通道，因为流光图都是黑白，获取红色绿色通道都可以
                    fixed light = tex2D(_LightTex, uv).b;
                    //获取要显示流光的位置，我这里使用蓝色通道来处理，我这边不用alpha来处理，因为透明图占内存
                    //fixed maskb = tex2D(_MaskTex, i.uv_MainTex).b;
                    fixed maskb = tex2D(_MaskTex, uv).b;
                    //这里算出要流光的地方叠加颜色
                    fixed4 c = light * _MoveLightColor * maskb;
                    //fixed4 c = light * _MoveLightColor * 1;
                    //o.Albedo = c.rgb;

                    //return half4(c.rgb, 1.0f);
                    //return half4(c.rgb, texColor.a);
                    //return half4(c);
                    texColor.rgb = c.rgb;
                    float x = step(0.01, c.r);
                    x = 1 - x;
                    clip(texColor.a - x);
                    return texColor;

                }
                ENDCG
            }
        }
            Fallback "Transparent/Cutout/VertexLit"
}