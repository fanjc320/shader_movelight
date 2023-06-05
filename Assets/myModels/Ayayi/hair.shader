// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "hair"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_low_ayayi_ayayi_hair_main1_BaseMap("low_ayayi_ayayi_hair_main1_BaseMap", 2D) = "white" {}
		_low_ayayi_ayayi_hair_main1_MaskMap("low_ayayi_ayayi_hair_main1_MaskMap", 2D) = "white" {}
		_low_ayayi_ayayi_hair_main1_Normal("low_ayayi_ayayi_hair_main1_Normal", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _low_ayayi_ayayi_hair_main1_Normal;
		uniform float4 _low_ayayi_ayayi_hair_main1_Normal_ST;
		uniform sampler2D _low_ayayi_ayayi_hair_main1_BaseMap;
		uniform float4 _low_ayayi_ayayi_hair_main1_BaseMap_ST;
		uniform sampler2D _low_ayayi_ayayi_hair_main1_MaskMap;
		SamplerState sampler_low_ayayi_ayayi_hair_main1_MaskMap;
		uniform float4 _low_ayayi_ayayi_hair_main1_MaskMap_ST;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_low_ayayi_ayayi_hair_main1_Normal = i.uv_texcoord * _low_ayayi_ayayi_hair_main1_Normal_ST.xy + _low_ayayi_ayayi_hair_main1_Normal_ST.zw;
			o.Normal = tex2D( _low_ayayi_ayayi_hair_main1_Normal, uv_low_ayayi_ayayi_hair_main1_Normal ).rgb;
			float2 uv_low_ayayi_ayayi_hair_main1_BaseMap = i.uv_texcoord * _low_ayayi_ayayi_hair_main1_BaseMap_ST.xy + _low_ayayi_ayayi_hair_main1_BaseMap_ST.zw;
			o.Albedo = tex2D( _low_ayayi_ayayi_hair_main1_BaseMap, uv_low_ayayi_ayayi_hair_main1_BaseMap ).rgb;
			float2 uv_low_ayayi_ayayi_hair_main1_MaskMap = i.uv_texcoord * _low_ayayi_ayayi_hair_main1_MaskMap_ST.xy + _low_ayayi_ayayi_hair_main1_MaskMap_ST.zw;
			float4 tex2DNode2 = tex2D( _low_ayayi_ayayi_hair_main1_MaskMap, uv_low_ayayi_ayayi_hair_main1_MaskMap );
			o.Alpha = tex2DNode2.g;
			clip( tex2DNode2.g - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
221;1325;2039;935;971.1804;259.595;1;True;True
Node;AmplifyShaderEditor.SamplerNode;3;-520.5,341.5;Inherit;True;Property;_low_ayayi_ayayi_hair_main1_Normal;low_ayayi_ayayi_hair_main1_Normal;3;0;Create;True;0;0;False;0;False;-1;1da3ba94df069a142b0d8164615e6b5b;1da3ba94df069a142b0d8164615e6b5b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-477.5,118.5;Inherit;True;Property;_low_ayayi_ayayi_hair_main1_MaskMap;low_ayayi_ayayi_hair_main1_MaskMap;2;0;Create;True;0;0;False;0;False;-1;31bac00ae24453a4c8ac604193f3a62f;31bac00ae24453a4c8ac604193f3a62f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-411.5,-82.5;Inherit;True;Property;_low_ayayi_ayayi_hair_main1_BaseMap;low_ayayi_ayayi_hair_main1_BaseMap;1;0;Create;True;0;0;False;0;False;-1;8c1a4050a4e197644affa6d06a290d10;8c1a4050a4e197644affa6d06a290d10;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;217,-49;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;hair;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;TransparentCutout;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;1;0
WireConnection;0;1;3;0
WireConnection;0;9;2;2
WireConnection;0;10;2;2
ASEEND*/
//CHKSM=32DB5413051124E9CFEE8B0FC8AB958231C234DE