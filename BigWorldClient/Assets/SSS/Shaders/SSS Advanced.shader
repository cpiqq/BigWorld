// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EdShaders/SSS Advanced"
{
	Properties
	{
		_MainColor("Main Color", Color) = (0.3921569,0.3921569,0.3921569,1)
		_SpecularColor("Specular Color", Color) = (0.3921569,0.3921569,0.3921569,1)
		_Shininess("Shininess", Range( 0.01 , 1)) = 0.1
		_SubsurfaceDistortion("Subsurface Distortion", Range( 0 , 1)) = 0.5
		_SSSMultiplier("SSS Multiplier", Float) = 1
		_SSSPower("SSS Power", Float) = 1
		_ShadowStrength("Shadow Strength", Range( 0 , 1)) = 1
		_InternalColourPower("Internal Colour Power", Float) = 4
		_PointLightPunchthrough("Point Light Punchthrough", Range( 0 , 1)) = 1
		_SSSScale("SSS Scale", Float) = 1
		_SSSMap("SSS Map", 2D) = "white" {}
		_InternalColour("Internal Colour", Color) = (0.9632353,0.08499137,0.08499137,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _SpecularColor;
		uniform float _Shininess;
		uniform float4 _MainColor;
		uniform float4 _InternalColour;
		uniform sampler2D _SSSMap;
		uniform float4 _SSSMap_ST;
		uniform float _SubsurfaceDistortion;
		uniform float _SSSPower;
		uniform float _SSSScale;
		uniform float _SSSMultiplier;
		uniform float _ShadowStrength;
		uniform float _PointLightPunchthrough;
		uniform float _InternalColourPower;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float4 temp_output_43_0_g1 = _SpecularColor;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g2 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float3 normalizeResult64_g1 = normalize( WorldNormalVector( i , float3(0,0,1) ) );
			float dotResult19_g1 = dot( normalizeResult4_g2 , normalizeResult64_g1 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 temp_output_40_0_g1 = ( ase_lightColor.rgb * ase_lightAtten );
			float dotResult14_g1 = dot( normalizeResult64_g1 , ase_worldlightDir );
			UnityGI gi34_g1 = gi;
			float3 diffNorm34_g1 = normalizeResult64_g1;
			gi34_g1 = UnityGI_Base( data, 1, diffNorm34_g1 );
			float3 indirectDiffuse34_g1 = gi34_g1.indirect.diffuse + diffNorm34_g1 * 0.0001;
			float4 temp_output_42_0_g1 = _MainColor;
			float2 uv_SSSMap = i.uv_texcoord * _SSSMap_ST.xy + _SSSMap_ST.zw;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult351 = dot( ase_worldViewDir , -( ase_worldlightDir + ( ase_worldNormal * _SubsurfaceDistortion ) ) );
			float IsPointLight363 = _WorldSpaceLightPos0.w;
			float dotResult356 = dot( pow( ( ( dotResult351 * ( 1.0 - IsPointLight363 ) ) + ( IsPointLight363 * ase_lightAtten ) ) , _SSSPower ) , _SSSScale );
			float temp_output_358_0 = saturate( ( tex2D( _SSSMap, uv_SSSMap ).r * dotResult356 * _SSSMultiplier ) );
			float4 lerpResult484 = lerp( _InternalColour , ase_lightColor , saturate( pow( ( ( temp_output_358_0 * saturate( ( ase_lightAtten + ( 1.0 - _ShadowStrength ) ) ) * ( 1.0 - IsPointLight363 ) ) + ( ase_lightAtten * temp_output_358_0 * _PointLightPunchthrough * IsPointLight363 ) ) , _InternalColourPower ) ));
			c.rgb = ( float4( ( ( (temp_output_43_0_g1).rgb * (temp_output_43_0_g1).a * pow( max( dotResult19_g1 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g1 ) + ( ( ( temp_output_40_0_g1 * max( dotResult14_g1 , 0.0 ) ) + indirectDiffuse34_g1 ) * (temp_output_42_0_g1).rgb ) ) , 0.0 ) + ( lerpResult484 * ase_lightColor.a * ( ( temp_output_358_0 * saturate( ( ase_lightAtten + ( 1.0 - _ShadowStrength ) ) ) * ( 1.0 - IsPointLight363 ) ) + ( ase_lightAtten * temp_output_358_0 * _PointLightPunchthrough * IsPointLight363 ) ) ) ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
2567;29;1906;1014;2541.71;6.1488;1.940414;True;False
Node;AmplifyShaderEditor.CommentaryNode;405;-4925.705,689.9528;Float;False;989.8997;621.6354;;10;364;345;346;347;348;349;350;351;451;452;Subsurface Scattering Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;345;-4871.084,1196.588;Float;False;Property;_SubsurfaceDistortion;Subsurface Distortion;5;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;402;-2244.999,790.6136;Float;False;563.4187;183;Outputs 0 for Point Lights, 1 for Directional Lights;2;362;363;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;364;-4869.326,1032.864;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightPos;362;-2194.999,840.6137;Float;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;406;-4649.565,1405.539;Float;False;748.1089;352.2148;Comment;3;408;407;409;Point Light Contribution;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;346;-4875.705,870.1448;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;347;-4532.008,1023.908;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-1924.579,850.4897;Float;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;408;-4583.832,1575.879;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;407;-4568.064,1494.079;Float;False;363;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;348;-4375.241,966.3441;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;350;-4251.527,967.4572;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;409;-4150.588,1492.155;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;451;-4481.315,1193.138;Float;False;363;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;349;-4326.554,739.9528;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;351;-4089.805,946.7889;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;412;-3809.652,1512.925;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;452;-4261.778,1197.111;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;411;-3736.035,1460.679;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;344;-3537.576,795.808;Float;False;1004.59;664.8036;;7;354;352;355;356;62;156;378;SSS Mask Strength;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;453;-3918.159,1074.386;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;410;-3646.785,1101.707;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;352;-3516.204,1289.689;Float;False;Property;_SSSPower;SSS Power;7;0;Create;True;0;0;False;0;1;0.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;355;-3392.068,1100.371;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;339;-2250.863,1012.165;Float;False;875.6224;413.5689;Adjustable Light Attenuation (directional light shadow tweaking);10;432;15;393;389;391;382;390;433;514;516;SSS Directional Lights (shadow control);1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-3324.829,1281.326;Float;False;Property;_SSSScale;SSS Scale;11;0;Create;True;0;0;False;0;1;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-2938.895,1219.257;Float;False;Property;_SSSMultiplier;SSS Multiplier;6;0;Create;True;0;0;False;0;1;1.88;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;356;-3214.304,1100.77;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;390;-2234.066,1229.141;Float;False;Property;_ShadowStrength;Shadow Strength;8;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;62;-3029.138,870.6781;Float;True;Property;_SSSMap;SSS Map;12;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;378;-2694.688,1079.735;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;382;-2219.58,1153.605;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;391;-1967.55,1232.893;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;432;-2225.862,1332.171;Float;False;363;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;430;-2086.589,1458.994;Float;False;616.0552;345.9696;Light Attenuation required for Point Lights;4;442;440;435;429;SSS Point Lights;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;389;-1822.994,1142.152;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;433;-2003.505,1337.668;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;358;-2433.678,1070.563;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;429;-2048.906,1609.887;Float;False;Property;_PointLightPunchthrough;Point Light Punchthrough;10;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;516;-2274.213,1089.962;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;440;-2011.42,1695.341;Float;False;363;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;393;-1707.351,1136.988;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;517;-2264.206,1479.146;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;435;-2014.696,1509.761;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;514;-1613.862,1283.746;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1503.044,1061.556;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;-1649.566,1523.979;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;447;-1303.717,1436.938;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;449;-1305.264,1136.771;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;478;-1040.294,807.4915;Float;False;747.384;679.4553;;13;489;504;484;511;510;505;477;483;509;508;481;480;488;SSS Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;445;-1232.015,1200.736;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;480;-1018.495,1381.551;Float;False;Property;_InternalColourPower;Internal Colour Power;9;0;Create;True;0;0;False;0;4;0.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;488;-1000.442,1198.884;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;481;-832.6113,1272.826;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;508;-687.024,1268.17;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;509;-544.4167,1220.971;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;477;-1011.884,851.2545;Float;False;Property;_InternalColour;Internal Colour;13;0;Create;True;0;0;False;0;0.9632353,0.08499137,0.08499137,0;0.6838235,0.6285143,0.6285143,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;510;-721.2174,1067.571;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;505;-866.8283,1163.771;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;483;-1008.064,1032.286;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WireNode;504;-618.528,1115.671;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;484;-697.5635,872.2891;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;511;-641.9168,1084.473;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;458;-208.1306,640.2563;Float;False;343.3309;347.4604;;2;104;381;Adding in Standard Lighting model;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;-478.7575,871.6292;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;381;-158.1307,690.2563;Float;False;Blinn-Phong Light;0;;1;cf814dba44d007a4e958d2ddd5813da6;0;3;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;43;COLOR;0,0,0,0;False;2;FLOAT3;0;FLOAT;57
Node;AmplifyShaderEditor.SimpleAddOpNode;104;-18.79955,854.7169;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;114;187.5354,687.0269;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;EdShaders/SSS Advanced;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Spherical;False;Relative;0;;4;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;347;0;364;0
WireConnection;347;1;345;0
WireConnection;363;0;362;2
WireConnection;348;0;346;0
WireConnection;348;1;347;0
WireConnection;350;0;348;0
WireConnection;409;0;407;0
WireConnection;409;1;408;0
WireConnection;351;0;349;0
WireConnection;351;1;350;0
WireConnection;412;0;409;0
WireConnection;452;0;451;0
WireConnection;411;0;412;0
WireConnection;453;0;351;0
WireConnection;453;1;452;0
WireConnection;410;0;453;0
WireConnection;410;1;411;0
WireConnection;355;0;410;0
WireConnection;355;1;352;0
WireConnection;356;0;355;0
WireConnection;356;1;354;0
WireConnection;378;0;62;1
WireConnection;378;1;356;0
WireConnection;378;2;156;0
WireConnection;391;0;390;0
WireConnection;389;0;382;0
WireConnection;389;1;391;0
WireConnection;433;0;432;0
WireConnection;358;0;378;0
WireConnection;516;0;358;0
WireConnection;393;0;389;0
WireConnection;517;0;358;0
WireConnection;514;0;433;0
WireConnection;15;0;516;0
WireConnection;15;1;393;0
WireConnection;15;2;514;0
WireConnection;442;0;435;0
WireConnection;442;1;517;0
WireConnection;442;2;429;0
WireConnection;442;3;440;0
WireConnection;447;0;442;0
WireConnection;449;0;15;0
WireConnection;445;0;449;0
WireConnection;445;1;447;0
WireConnection;488;0;445;0
WireConnection;481;0;488;0
WireConnection;481;1;480;0
WireConnection;508;0;481;0
WireConnection;509;0;508;0
WireConnection;510;0;509;0
WireConnection;505;0;488;0
WireConnection;504;0;505;0
WireConnection;484;0;477;0
WireConnection;484;1;483;0
WireConnection;484;2;510;0
WireConnection;511;0;483;2
WireConnection;489;0;484;0
WireConnection;489;1;511;0
WireConnection;489;2;504;0
WireConnection;104;0;381;0
WireConnection;104;1;489;0
WireConnection;114;13;104;0
ASEEND*/
//CHKSM=E77A18113A557D716C76357A5CAC4CD0DF7C0DE5