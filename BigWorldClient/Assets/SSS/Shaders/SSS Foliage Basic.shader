// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EdShaders/SSS Foliage Basic"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_ColourTint("Colour Tint", Color) = (1,1,1,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_SubsurfaceDistortion("Subsurface Distortion", Range( 0 , 1)) = 0.5
		_SSSMultiplier("SSS Multiplier", Float) = 1
		_SSSPower("SSS Power", Float) = 1
		_ShadowStrength("Shadow Strength", Range( 0 , 1)) = 1
		_InternalColourPower("Internal Colour Power", Float) = 4
		_PointLightPunchthrough("Point Light Punchthrough", Range( 0 , 1)) = 1
		_SSSScale("SSS Scale", Float) = 1
		_SSSAOStrength("SSS AO Strength", Range( 0 , 1)) = 0.52
		_AOStrength("AO Strength", Range( 0 , 1)) = 0.52
		_AOSize("AO Size", Float) = 0.52
		_SSSMap("SSS Map", 2D) = "white" {}
		_InternalColour("Internal Colour", Color) = (0.9632353,0.08499137,0.08499137,0)
		_OverrideNormalsforStandardLighting("Override Normals for Standard Lighting", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
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
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
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

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _OverrideNormalsforStandardLighting;
		uniform float4 _ColourTint;
		uniform float _AOSize;
		uniform float _AOStrength;
		uniform float4 _InternalColour;
		uniform sampler2D _SSSMap;
		uniform float4 _SSSMap_ST;
		uniform float _SubsurfaceDistortion;
		uniform float _SSSPower;
		uniform float _SSSScale;
		uniform float _SSSMultiplier;
		uniform float _SSSAOStrength;
		uniform float _ShadowStrength;
		uniform float _PointLightPunchthrough;
		uniform float _InternalColourPower;
		uniform float _Cutoff = 0.5;

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
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode518 = tex2D( _MainTex, uv_MainTex );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir529 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz;
			float3 normalizeResult531 = normalize( objToWorldDir529 );
			float3 sphereNormals535 = normalizeResult531;
			float3 lerpResult590 = lerp( ase_worldNormal , sphereNormals535 , _OverrideNormalsforStandardLighting);
			float3 normalizeResult563 = normalize( lerpResult590 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult578 = dot( normalizeResult563 , ase_worldlightDir );
			UnityGI gi554 = gi;
			float3 diffNorm554 = normalizeResult563;
			gi554 = UnityGI_Base( data, 1, diffNorm554 );
			float3 indirectDiffuse554 = gi554.indirect.diffuse + diffNorm554 * 0.0001;
			float3 break530 = ase_vertex3Pos;
			float temp_output_539_0 = saturate( (0.0 + (( ( break530.x * break530.x ) + ( break530.y * break530.y ) + ( break530.z * break530.z ) ) - 0.0) * (1.0 - 0.0) / (_AOSize - 0.0)) );
			float AO540 = temp_output_539_0;
			float2 uv_SSSMap = i.uv_texcoord * _SSSMap_ST.xy + _SSSMap_ST.zw;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult351 = dot( ase_worldViewDir , -( ase_worldlightDir + ( sphereNormals535 * _SubsurfaceDistortion ) ) );
			float IsPointLight363 = _WorldSpaceLightPos0.w;
			float dotResult356 = dot( pow( ( ( dotResult351 * ( 1.0 - IsPointLight363 ) ) + ( IsPointLight363 * ase_lightAtten ) ) , _SSSPower ) , _SSSScale );
			float temp_output_358_0 = saturate( ( tex2D( _SSSMap, uv_SSSMap ).r * dotResult356 * _SSSMultiplier * saturate( ( AO540 + ( 1.0 - _SSSAOStrength ) ) ) ) );
			float4 lerpResult484 = lerp( _InternalColour , ase_lightColor , saturate( pow( ( ( temp_output_358_0 * saturate( ( ase_lightAtten + ( 1.0 - _ShadowStrength ) ) ) * ( 1.0 - IsPointLight363 ) ) + ( ase_lightAtten * temp_output_358_0 * _PointLightPunchthrough * IsPointLight363 ) ) , _InternalColourPower ) ));
			c.rgb = ( ( float4( ( ( ( ase_lightColor.rgb * ase_lightAtten ) * max( dotResult578 , 0.0 ) ) + indirectDiffuse554 ) , 0.0 ) * ( tex2DNode518 * _ColourTint ) * saturate( ( AO540 + ( 1.0 - _AOStrength ) ) ) ) + ( lerpResult484 * ase_lightColor.a * ( ( temp_output_358_0 * saturate( ( ase_lightAtten + ( 1.0 - _ShadowStrength ) ) ) * ( 1.0 - IsPointLight363 ) ) + ( ase_lightAtten * temp_output_358_0 * _PointLightPunchthrough * IsPointLight363 ) ) ) ).rgb;
			c.a = 1;
			clip( tex2DNode518.a - _Cutoff );
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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
Version=16900
0;144;1440;604;4416.193;-494.5533;2.121781;True;False
Node;AmplifyShaderEditor.CommentaryNode;524;-5734.981,2627.129;Float;False;792.809;259.7164;Spherical Normals out from Centre Position;3;531;529;526;Sphere Normals;0.905071,0.4705882,1,0.634;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;526;-5694.064,2677.729;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;529;-5451.357,2673.174;Float;False;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;531;-5168.498,2677.244;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;405;-4925.705,689.9528;Float;False;989.8997;621.6354;;11;364;345;346;347;348;349;350;351;451;452;547;Subsurface Scattering Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;535;-4678.484,2701.627;Float;False;sphereNormals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;402;-2244.999,790.6136;Float;False;563.4187;183;Outputs 0 for Point Lights, 1 for Directional Lights;2;362;363;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;547;-4868.764,1114.475;Float;False;535;sphereNormals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;345;-4871.084,1196.588;Float;False;Property;_SubsurfaceDistortion;Subsurface Distortion;3;0;Create;True;0;0;False;0;0.5;0.154;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;527;-5672.653,2115.229;Float;False;1272.16;405.4415;(Can use Distance instead);8;530;538;537;536;533;534;532;539;Sqr Magnitude (for Centre Masking);1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;362;-2194.999,840.6137;Float;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;346;-4868.188,742.3599;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;347;-4532.008,1023.908;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-1924.579,850.4897;Float;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;406;-4649.565,1405.539;Float;False;748.1089;352.2148;Comment;3;408;407;409;Point Light Contribution;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;530;-5443.298,2261.198;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;532;-5144.853,2391.027;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;534;-5158.171,2190.811;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;533;-5154.935,2296.679;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;408;-4583.832,1575.879;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;348;-4375.241,966.3441;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;407;-4568.064,1494.079;Float;False;363;IsPointLight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;537;-4974.438,2232.457;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;536;-5011.54,2432.55;Float;False;Property;_AOSize;AO Size;12;0;Create;True;0;0;False;0;0.52;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;409;-4150.588,1492.155;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;349;-4326.554,739.9528;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;350;-4251.527,967.4572;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;451;-4481.315,1193.138;Float;False;363;IsPointLight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;452;-4261.778,1197.111;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;541;-3935.38,2035.916;Float;False;869.4731;234.4004;Faked via distance from Centre - can replace with baking AO via vertex colour;5;545;542;544;543;540; SSS Ambient Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;538;-4777.957,2179.25;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;412;-3809.652,1512.925;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;351;-4089.805,946.7889;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;542;-3927.887,2084.814;Float;False;Property;_SSSAOStrength;SSS AO Strength;10;0;Create;True;0;0;False;0;0.52;0.923;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;344;-3537.576,795.808;Float;False;1004.59;664.8036;;7;354;352;355;356;62;156;378;SSS Mask Strength;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;539;-4574.185,2305.271;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;411;-3736.035,1460.679;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;453;-3918.159,1074.386;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;540;-3817.015,2186.702;Float;False;AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;410;-3646.785,1101.707;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;352;-3516.204,1289.689;Float;False;Property;_SSSPower;SSS Power;5;0;Create;True;0;0;False;0;1;1.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;543;-3592.274,2076.927;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;339;-2250.863,1012.165;Float;False;875.6224;413.5689;Adjustable Light Attenuation (directional light shadow tweaking);10;432;15;393;389;391;382;390;433;514;516;SSS Directional Lights (shadow control);1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-3324.829,1281.326;Float;False;Property;_SSSScale;SSS Scale;9;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;544;-3399.8,2099.423;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;355;-3392.068,1100.371;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;356;-3214.304,1100.77;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;62;-3029.138,870.6781;Float;True;Property;_SSSMap;SSS Map;13;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;545;-3245.118,2101.313;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-2938.895,1219.257;Float;False;Property;_SSSMultiplier;SSS Multiplier;4;0;Create;True;0;0;False;0;1;1.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;390;-2234.066,1229.141;Float;False;Property;_ShadowStrength;Shadow Strength;6;0;Create;True;0;0;False;0;1;0.436;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;391;-1967.55,1232.893;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;432;-2225.862,1332.171;Float;False;363;IsPointLight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;382;-2219.58,1153.605;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;378;-2694.688,1079.735;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;433;-2003.505,1337.668;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;389;-1822.994,1142.152;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;358;-2433.678,1070.563;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;430;-2086.589,1458.994;Float;False;616.0552;345.9696;Light Attenuation required for Point Lights;4;442;440;435;429;SSS Point Lights;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;429;-2048.906,1609.887;Float;False;Property;_PointLightPunchthrough;Point Light Punchthrough;8;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;516;-2274.213,1089.962;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;440;-2011.42,1695.341;Float;False;363;IsPointLight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;514;-1613.862,1283.746;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;393;-1707.351,1136.988;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;435;-2014.696,1509.761;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;517;-2264.206,1479.146;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1503.044,1061.556;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;-1649.566,1523.979;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;583;-1648.001,-353.21;Float;False;2090.932;915.2427;Comment;25;571;588;520;556;518;519;587;554;555;559;572;586;584;580;570;585;577;578;579;563;582;548;589;590;591;Blinn Phong Tweaked No Spec;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;447;-1303.717,1436.938;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;449;-1305.264,1136.771;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;591;-1608.856,38.35741;Float;False;Property;_OverrideNormalsforStandardLighting;Override Normals for Standard Lighting;15;0;Create;True;0;0;False;0;1;0.732;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;445;-1232.015,1200.736;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;548;-1610.658,-269.1404;Float;False;535;sphereNormals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;478;-642.9844,796.5313;Float;False;747.384;679.4553;;13;489;504;484;511;510;505;477;483;509;508;481;480;488;SSS Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;589;-1605.35,-135.6033;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;480;-621.1855,1370.591;Float;False;Property;_InternalColourPower;Internal Colour Power;7;0;Create;True;0;0;False;0;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;590;-1362.35,-110.6033;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;488;-603.1326,1187.924;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;563;-1382.836,-264.3669;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;481;-435.3018,1261.866;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;582;-1471.317,158.7102;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;570;-1158.836,-40.3671;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;578;-1110.836,-152.3672;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;579;-746.8853,-287.3049;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;585;-563.9175,372.8235;Float;False;Property;_AOStrength;AO Strength;11;0;Create;True;0;0;False;0;0.52;0.366;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;577;-809.2719,-177.6596;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;508;-289.7145,1257.21;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;559;-570.8853,-255.3049;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;584;-360.7073,270.9238;Float;False;540;AO;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;509;-147.1072,1210.011;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;586;-260.9094,376.8914;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;580;-950.8356,-152.3672;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;572;-1126.836,-24.36713;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;477;-614.5745,840.2943;Float;False;Property;_InternalColour;Internal Colour;14;0;Create;True;0;0;False;0;0.9632353,0.08499137,0.08499137,0;0.5463182,0.9485294,0.160413,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IndirectDiffuseLighting;554;-438.8357,-56.36703;Float;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;587;-48.87276,341.7863;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;555;-358.8356,-168.3672;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;518;-1147.406,46.28442;Float;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;483;-610.7546,1021.326;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WireNode;505;-469.5188,1152.811;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;519;-1056.654,272.718;Float;False;Property;_ColourTint;Colour Tint;1;0;Create;True;0;0;False;0;1,1,1,0;0.09245243,0.6985294,0.1217114,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;510;-323.9079,1056.611;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;504;-221.2185,1104.711;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;511;-244.6073,1073.513;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;588;126.4589,361.0651;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;556;-166.836,-168.3672;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;520;-688.841,78.66458;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;484;-300.254,861.3289;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;458;628.141,756.624;Float;False;256.4237;201.8907;;1;104;Adding in Standard Lighting model;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;571;233.164,-168.3672;Float;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;523;705.4852,271.2203;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;-81.44798,860.6689;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;522;848.4162,358.6213;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;364;-4865.567,950.1796;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RelayNode;592;-4033.164,2300.502;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;104;715.3564,827.6883;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;114;1073.315,603.1606;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;EdShaders/SSS Foliage Basic;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Spherical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;529;0;526;0
WireConnection;531;0;529;0
WireConnection;535;0;531;0
WireConnection;347;0;547;0
WireConnection;347;1;345;0
WireConnection;363;0;362;2
WireConnection;530;0;526;0
WireConnection;532;0;530;2
WireConnection;532;1;530;2
WireConnection;534;0;530;0
WireConnection;534;1;530;0
WireConnection;533;0;530;1
WireConnection;533;1;530;1
WireConnection;348;0;346;0
WireConnection;348;1;347;0
WireConnection;537;0;534;0
WireConnection;537;1;533;0
WireConnection;537;2;532;0
WireConnection;409;0;407;0
WireConnection;409;1;408;0
WireConnection;350;0;348;0
WireConnection;452;0;451;0
WireConnection;538;0;537;0
WireConnection;538;2;536;0
WireConnection;412;0;409;0
WireConnection;351;0;349;0
WireConnection;351;1;350;0
WireConnection;539;0;538;0
WireConnection;411;0;412;0
WireConnection;453;0;351;0
WireConnection;453;1;452;0
WireConnection;540;0;539;0
WireConnection;410;0;453;0
WireConnection;410;1;411;0
WireConnection;543;0;542;0
WireConnection;544;0;540;0
WireConnection;544;1;543;0
WireConnection;355;0;410;0
WireConnection;355;1;352;0
WireConnection;356;0;355;0
WireConnection;356;1;354;0
WireConnection;545;0;544;0
WireConnection;391;0;390;0
WireConnection;378;0;62;1
WireConnection;378;1;356;0
WireConnection;378;2;156;0
WireConnection;378;3;545;0
WireConnection;433;0;432;0
WireConnection;389;0;382;0
WireConnection;389;1;391;0
WireConnection;358;0;378;0
WireConnection;516;0;358;0
WireConnection;514;0;433;0
WireConnection;393;0;389;0
WireConnection;517;0;358;0
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
WireConnection;590;0;589;0
WireConnection;590;1;548;0
WireConnection;590;2;591;0
WireConnection;488;0;445;0
WireConnection;563;0;590;0
WireConnection;481;0;488;0
WireConnection;481;1;480;0
WireConnection;570;0;563;0
WireConnection;578;0;563;0
WireConnection;578;1;582;0
WireConnection;508;0;481;0
WireConnection;559;0;579;1
WireConnection;559;1;577;0
WireConnection;509;0;508;0
WireConnection;586;0;585;0
WireConnection;580;0;578;0
WireConnection;572;0;570;0
WireConnection;554;0;572;0
WireConnection;587;0;584;0
WireConnection;587;1;586;0
WireConnection;555;0;559;0
WireConnection;555;1;580;0
WireConnection;505;0;488;0
WireConnection;510;0;509;0
WireConnection;504;0;505;0
WireConnection;511;0;483;2
WireConnection;588;0;587;0
WireConnection;556;0;555;0
WireConnection;556;1;554;0
WireConnection;520;0;518;0
WireConnection;520;1;519;0
WireConnection;484;0;477;0
WireConnection;484;1;483;0
WireConnection;484;2;510;0
WireConnection;571;0;556;0
WireConnection;571;1;520;0
WireConnection;571;2;588;0
WireConnection;523;0;518;4
WireConnection;489;0;484;0
WireConnection;489;1;511;0
WireConnection;489;2;504;0
WireConnection;522;0;523;0
WireConnection;592;0;539;0
WireConnection;104;0;571;0
WireConnection;104;1;489;0
WireConnection;114;10;522;0
WireConnection;114;13;104;0
ASEEND*/
//CHKSM=7D687E35F25D53E5AC3D4DFB3A0E79ED7CAB42B1