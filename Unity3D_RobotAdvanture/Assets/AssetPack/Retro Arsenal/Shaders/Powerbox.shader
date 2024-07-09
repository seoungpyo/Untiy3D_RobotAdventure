// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Archanor VFX/Retro Arsenal/Powerbox"
{
	Properties
	{
		_Background("Background", 2D) = "white" {}
		_PanningTexture("Panning Texture", 2D) = "white" {}
		_Icon("Icon", 2D) = "white" {}
		[Header(Background  Edge Settings)][Space(10)]_BackgroundTint("Background Tint", Color) = (0,0,0,0)
		_EdgeTint("Edge Tint", Color) = (0,0,0,0)
		_BackgroundPower("Background Power", Float) = 1
		_EdgePower("Edge Power", Float) = 1
		_Contrast("Contrast", Float) = 0
		[Header(Icon Settings)][Space(10)]_IconTint("Icon Tint", Color) = (0,0,0,0)
		_PanColor("Pan Color", Color) = (0.7028302,0.8790489,1,0)
		_IconContrast("Icon Contrast", Range( 1 , 1.5)) = 0
		_IconEmission("Icon Emission", Range( 1 , 15)) = 0
		_PanStrength("Pan Strength", Range( 1 , 5)) = 1
		[Header(Rotation)][Space(10)]_RotationSpeed("Rotation Speed", Float) = 2
		[Header(Bobbing)][Space(10)]_BobSpeed("Bob Speed", Float) = 4
		_BobHeight("Bob Height", Range( 0 , 0.2)) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _RotationSpeed;
		uniform float _BobSpeed;
		uniform float _BobHeight;
		uniform float _Contrast;
		uniform float4 _BackgroundTint;
		uniform sampler2D _Background;
		uniform float4 _Background_ST;
		uniform float _BackgroundPower;
		uniform float4 _EdgeTint;
		uniform float _EdgePower;
		uniform float _IconContrast;
		uniform sampler2D _Icon;
		uniform float _IconEmission;
		uniform float4 _IconTint;
		uniform sampler2D _PanningTexture;
		uniform float _PanStrength;
		uniform float4 _PanColor;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 appendResult276 = (float4(0.0 , 0.0 , _BobHeight , 0.0));
			float3 rotatedValue72 = RotateAroundAxis( float3( 0,0,0 ), (ase_vertex3Pos*1.0 + ( sin( ( _Time.y * _BobSpeed ) ) * appendResult276 ).xyz), float3(0,0,1), ( _Time.y * _RotationSpeed ) );
			v.vertex.xyz = rotatedValue72;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Background = i.uv_texcoord * _Background_ST.xy + _Background_ST.zw;
			float4 tex2DNode9 = tex2D( _Background, uv_Background );
			float2 temp_cast_0 = (2.0).xx;
			float2 uv_TexCoord83 = i.uv_texcoord * temp_cast_0 + float3(0,-1,0).xy;
			float4 tex2DNode84 = tex2D( _Icon, uv_TexCoord83 );
			float2 temp_cast_2 = (1.0).xx;
			float2 uv_TexCoord101 = i.uv_texcoord * temp_cast_2;
			float2 panner95 = ( _Time.y * float2( 0,1.5 ) + uv_TexCoord101);
			float2 temp_cast_3 = (2.0).xx;
			float2 uv_TexCoord186 = i.uv_texcoord * temp_cast_3;
			float2 panner184 = ( _Time.y * float2( 0,2 ) + uv_TexCoord186);
			float4 panColor278 = _PanColor;
			float4 pan2280 = ( tex2D( _PanningTexture, panner184 ) * 0.5 * panColor278 );
			float4 lerpResult87 = lerp( CalculateContrast(_Contrast,( ( _BackgroundTint * tex2DNode9.a * _BackgroundPower ) + tex2DNode9 + ( ( 1.0 - tex2DNode9.a ) * _EdgeTint * _EdgePower ) )) , ( CalculateContrast(_IconContrast,( tex2DNode84.r * _IconEmission * _IconTint )) + ( ( tex2D( _PanningTexture, panner95 ) * _PanStrength * _PanColor ) + pan2280 ) ) , tex2DNode84.a);
			o.Emission = lerpResult87.rgb;
			o.Metallic = 0.5;
			o.Smoothness = 0.25;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;282;-4632.791,-1161.039;Inherit;False;1809.49;636.0625;;11;280;279;187;188;185;183;189;192;191;186;184;Pan 2;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;202;647.1061,-414.4931;Inherit;False;Constant;_Float4;Float 4;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;201;809.4479,-394.3845;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1054.642,-28.98039;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-524.0716,-27.3208;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;100;-2046.978,436.682;Inherit;False;Constant;_Vector0;Vector 0;12;0;Create;True;0;0;0;False;0;False;0,1.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;95;-1739.264,353.967;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;101;-2016.978,225.6822;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1095.894,502.1538;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;98;-2045.678,585.0086;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-2257.283,628.8722;Inherit;False;Constant;_Float2;Float 2;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2208.779,279.9617;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;131.18,117.0882;Inherit;False;Constant;_Metallic;Metallic;13;0;Create;True;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;128.3234,195.3165;Inherit;False;Constant;_Smoothness;Smoothness;12;0;Create;True;0;0;0;False;0;False;0.25;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;72;100.2321,471.1804;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;-370.7857,961.0505;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;-700.6794,905.1906;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;253;-538.1792,905.1925;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;220;-379.6225,742.4347;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;73;-118.6599,320.3042;Inherit;False;Constant;_Vector1;Vector 1;7;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-97.51855,496.7009;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;76;-323.1246,471.8771;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;87;-210.5475,-150.4043;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;200;-811.5876,-27.82151;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;83;-1648.23,-170.3728;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;84;-1371.741,-194.1203;Inherit;True;Property;_Icon;Icon;2;0;Create;True;0;0;0;False;0;False;-1;None;f3473e6400297ed45b8303c34955caca;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;82;-1924.914,-88.03061;Inherit;False;Constant;_IconOffset;Icon Offset;7;0;Create;True;0;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;81;-1900.768,-187.4597;Inherit;False;Constant;_IconScale;Icon Scale;7;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1362.716,-4.57361;Inherit;False;Property;_IconEmission;Icon Emission;11;0;Create;True;0;0;0;False;0;False;0;2.5;1;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1084.111,182.5846;Inherit;False;Property;_IconContrast;Icon Contrast;10;0;Create;True;0;0;0;False;0;False;0;1.5;1;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-1499.907,623.1202;Inherit;False;Property;_PanStrength;Pan Strength;12;0;Create;True;0;0;0;False;0;False;1;1;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;112;-1416.931,793.0872;Inherit;False;Property;_PanColor;Pan Color;9;0;Create;True;0;0;0;False;0;False;0.7028302,0.8790489,1,0;0.1296362,1,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;96;-1455.718,364.8605;Inherit;True;Property;_PanningTexture;Panning Texture;1;0;Create;True;0;0;0;False;0;False;-1;None;4d64936f26b0b0e458f06562c1064b59;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;265;-898.4014,1121.562;Inherit;False;Property;_BobHeight;Bob Height;15;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;276;-559.5208,1073.896;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;254;-896.9786,861.7908;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;-1159.251,810.0306;Inherit;False;panColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;277;-679.5453,446.1441;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;281;-878.39,704.4095;Inherit;False;280;pan2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;184;-4046.935,-992.7426;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;186;-4324.652,-1121.029;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;191;-4353.352,-761.7016;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-4564.957,-717.8377;Inherit;False;Constant;_Float3;Float 2;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-3668.406,-740.3577;Inherit;False;Constant;_PanStrength1;Pan Strength;12;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;183;-4354.652,-910.0276;Inherit;False;Constant;_Vector2;Vector 0;12;0;Create;True;0;0;0;False;0;False;0,2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;185;-3763.39,-981.8496;Inherit;True;Property;_BackgroundPan;BackgroundPan;1;0;Create;True;0;0;0;False;0;False;-1;None;4d64936f26b0b0e458f06562c1064b59;True;0;False;white;Auto;False;Instance;96;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;188;-4516.454,-1066.749;Inherit;False;Constant;_Float1;Float 0;12;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-3330.665,-980.2618;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;279;-3640.739,-621.4001;Inherit;False;278;panColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;280;-3070.549,-978.2825;Inherit;False;pan2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;-1899.814,-873.7063;Inherit;True;Property;_Background;Background;0;0;Create;True;0;0;0;False;0;False;-1;None;eb5c8515707341a45b1d613c2fea411c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;321;-1505.004,-669.6082;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;326;-1284.294,-490.786;Inherit;False;Property;_EdgeTint;Edge Tint;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1374768,0.6603774,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;-1033.04,-613.5797;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;325;-1212.517,-1042.974;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;328;-674.1044,-893.1713;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;330;-222.6052,-904.5055;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;331;-454.968,-789.2693;Inherit;False;Property;_Contrast;Contrast;7;0;Create;True;0;0;0;False;0;False;0;1.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;308;-1250.944,-305.815;Inherit;False;Property;_EdgePower;Edge Power;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;332;-1597.888,-983.8474;Inherit;False;Property;_BackgroundPower;Background Power;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-1507.877,-1164.047;Inherit;False;Property;_BackgroundTint;Background Tint;3;1;[Header];Create;True;1;Background  Edge Settings;0;0;False;1;Space(10);False;0,0,0,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;85;-1299.118,89.29703;Inherit;False;Property;_IconTint;Icon Tint;8;1;[Header];Create;True;1;Icon Settings;0;0;False;1;Space(10);False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;69;-326.6915,578.2936;Inherit;False;Property;_RotationSpeed;Rotation Speed;13;1;[Header];Create;True;1;Rotation;0;0;False;1;Space(10);False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-872.2771,974.0865;Inherit;False;Property;_BobSpeed;Bob Speed;14;1;[Header];Create;True;1;Bobbing;0;0;False;1;Space(10);False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;230;-131.118,743.5576;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;452.916,11.10008;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Archanor VFX/Retro Arsenal/Powerbox;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;201;0;202;0
WireConnection;93;0;84;1
WireConnection;93;1;88;0
WireConnection;93;2;85;0
WireConnection;86;0;200;0
WireConnection;86;1;277;0
WireConnection;95;0;101;0
WireConnection;95;2;100;0
WireConnection;95;1;98;0
WireConnection;101;0;102;0
WireConnection;109;0;96;0
WireConnection;109;1;110;0
WireConnection;109;2;112;0
WireConnection;98;0;121;0
WireConnection;72;0;73;0
WireConnection;72;1;68;0
WireConnection;72;3;230;0
WireConnection;236;0;253;0
WireConnection;236;1;276;0
WireConnection;255;0;254;0
WireConnection;255;1;247;0
WireConnection;253;0;255;0
WireConnection;68;0;76;0
WireConnection;68;1;69;0
WireConnection;87;0;330;0
WireConnection;87;1;86;0
WireConnection;87;2;84;4
WireConnection;200;1;93;0
WireConnection;200;0;91;0
WireConnection;83;0;81;0
WireConnection;83;1;82;0
WireConnection;84;1;83;0
WireConnection;96;1;95;0
WireConnection;276;2;265;0
WireConnection;278;0;112;0
WireConnection;277;0;109;0
WireConnection;277;1;281;0
WireConnection;184;0;186;0
WireConnection;184;2;183;0
WireConnection;184;1;191;0
WireConnection;186;0;188;0
WireConnection;191;0;192;0
WireConnection;185;1;184;0
WireConnection;187;0;185;0
WireConnection;187;1;189;0
WireConnection;187;2;279;0
WireConnection;280;0;187;0
WireConnection;321;0;9;4
WireConnection;327;0;321;0
WireConnection;327;1;326;0
WireConnection;327;2;308;0
WireConnection;325;0;6;0
WireConnection;325;1;9;4
WireConnection;325;2;332;0
WireConnection;328;0;325;0
WireConnection;328;1;9;0
WireConnection;328;2;327;0
WireConnection;330;1;328;0
WireConnection;330;0;331;0
WireConnection;230;0;220;0
WireConnection;230;2;236;0
WireConnection;0;2;87;0
WireConnection;0;3;78;0
WireConnection;0;4;77;0
WireConnection;0;11;72;0
ASEEND*/
//CHKSM=098AD72405AEC1FBC4CCF0D79C88C5E000160BA5