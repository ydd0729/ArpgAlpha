// Made with Amplify Shader Editor v1.9.2.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BK/Grass"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.29
		_WindMultiplier("Wind Multiplier", Float) = 1
		[Space(10)]_Color01("Color 01", Color) = (1,0.3215686,0,1)
		_Color02("Color 02", Color) = (1,0.3215686,0,1)
		[Space(10)]_MainTex("Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.1
		_ColorVariationPower("Color Variation Power", Range( 0 , 1)) = 1
		_Normal("Normal", 2D) = "bump" {}
		_NormalPower("Normal Power", Range( 0 , 1)) = 1
		[Toggle(_NORMALWORLDSPACEUVS_ON)] _NormalWorldSpaceUVs("Normal WorldSpace UVs", Float) = 0
		[Space(10)]_Noise("Noise", 2D) = "white" {}
		_NoiseTiling("Noise Tiling", Float) = 1.09
		[Toggle(_NOISEWORLDSPACEUVS_ON)] _NoiseWorldSpaceUVs("Noise WorldSpace UVs", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Off
		AlphaToMask On
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.0
		#pragma multi_compile_instancing
		#pragma shader_feature_local _NORMALWORLDSPACEUVS_ON
		#pragma shader_feature_local _NOISEWORLDSPACEUVS_ON
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float4 screenPosition;
			float eyeDepth;
		};

		uniform float MicroSpeed;
		uniform float MicroFrequency;
		uniform float MicroPower;
		uniform float _WindMultiplier;
		uniform sampler2D _Normal;
		uniform float _NoiseTiling;
		uniform float _NormalPower;
		uniform float4 _Color01;
		uniform float4 _Color02;
		uniform sampler2D _Noise;
		uniform float _ColorVariationPower;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Smoothness;
		uniform float GrassRenderDist;
		uniform float _Cutoff = 0.29;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 appendResult109 = (float3(ase_worldPos.z , ase_worldPos.y , ase_worldPos.x));
			float2 temp_cast_0 = (( MicroSpeed * 0.5 )).xx;
			float2 panner110 = ( 1.0 * _Time.y * temp_cast_0 + appendResult109.xy);
			float simplePerlin2D112 = snoise( panner110 );
			simplePerlin2D112 = simplePerlin2D112*0.5 + 0.5;
			float4 MicroWind125 = ( ( ( float4( ( ( ( sin( ( ( appendResult109 + simplePerlin2D112 ) * ( MicroFrequency * 2.0 ) ) ) * v.texcoord.xy.y ) * MicroPower ) * v.color.r ) , 0.0 ) * float4(12,3.6,1,1) ) * 0.05 ) * _WindMultiplier );
			v.vertex.xyz += MicroWind125.xyz;
			v.vertex.w = 1;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult40 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 WorldSpaceUVs160 = ( appendResult40 * _NoiseTiling );
			#ifdef _NORMALWORLDSPACEUVS_ON
				float2 staticSwitch185 = WorldSpaceUVs160;
			#else
				float2 staticSwitch185 = i.uv_texcoord;
			#endif
			o.Normal = UnpackScaleNormal( tex2D( _Normal, staticSwitch185 ), _NormalPower );
			#ifdef _NOISEWORLDSPACEUVS_ON
				float2 staticSwitch192 = WorldSpaceUVs160;
			#else
				float2 staticSwitch192 = i.uv_texcoord;
			#endif
			float4 lerpResult48 = lerp( _Color01 , _Color02 , ( tex2D( _Noise, staticSwitch192 ).r * _ColorVariationPower ));
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
			float4 _Albedo194 = ( lerpResult48 * tex2DNode2 );
			o.Albedo = _Albedo194.rgb;
			o.Smoothness = ( _Smoothness * i.vertexColor.r );
			o.Alpha = 1;
			float _Alpha202 = tex2DNode2.a;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen148 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither148 = Dither8x8Bayer( fmod(clipScreen148.x, 8), fmod(clipScreen148.y, 8) );
			float cameraDepthFade145 = (( i.eyeDepth -_ProjectionParams.y - GrassRenderDist ) / GrassRenderDist);
			dither148 = step( dither148, ( 1.0 - cameraDepthFade145 ) );
			float DistanceFade150 = dither148;
			float2 clipScreen151 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither151 = Dither8x8Bayer( fmod(clipScreen151.x, 8), fmod(clipScreen151.y, 8) );
			float3 temp_cast_1 = ((1.5 + (i.uv_texcoord.y - 0.11) * (8.0 - 1.5) / (0.52 - 0.11))).xxx;
			float3 temp_cast_2 = ((1.5 + (i.uv_texcoord.y - 0.11) * (8.0 - 1.5) / (0.52 - 0.11))).xxx;
			float3 gammaToLinear146 = GammaToLinearSpace( temp_cast_2 );
			float3 clampResult149 = clamp( gammaToLinear146 , float3( 0,0,0 ) , float3( 1,1,1 ) );
			dither151 = step( dither151, clampResult149.x );
			float BaseOpacity152 = dither151;
			clip( ( ( _Alpha202 * DistanceFade150 ) * BaseOpacity152 ) - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
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
				float3 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
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
				o.customPack2.xyzw = customInputData.screenPosition;
				o.customPack1.z = customInputData.eyeDepth;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				surfIN.screenPosition = IN.customPack2.xyzw;
				surfIN.eyeDepth = IN.customPack1.z;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
}
/*ASEBEGIN
Version=19201
Node;AmplifyShaderEditor.CommentaryNode;135;-3840,-384;Inherit;False;3196.689;476.6296;;24;125;213;214;130;133;124;122;123;121;120;118;119;116;117;115;113;114;111;112;110;109;126;108;127;Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-3808,-64;Float;False;Global;MicroSpeed;MicroSpeed;18;1;[HideInInspector];Create;False;0;0;0;False;0;False;2;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;108;-3808,-320;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-3568,-64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;109;-3568,-304;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;110;-3392,-192;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;112;-3200,-192;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-3200,-64;Float;False;Global;MicroFrequency;MicroFrequency;19;1;[HideInInspector];Create;False;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;163;-3840,-2816;Inherit;False;1153.912;317.6656;World-Space UVs;0;UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-2944,-64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-2944,-304;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-2752,-320;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;139;-3840,-2304;Inherit;False;1085.633;188.7;;0;Distance Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;140;-3841.647,-1916.839;Inherit;False;1312.323;289;;0;Base Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.SinOpNode;117;-2528,-320;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;116;-2560,-96;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;143;-3809.647,-1852.839;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-2304,-320;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-2304,-96;Float;False;Global;MicroPower;MicroPower;20;0;Create;False;0;0;0;False;0;False;0.05;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;134;-3840,-1408;Inherit;False;2180.593;765.4294;;13;191;176;192;165;47;46;48;1;107;3;194;2;202;Diffuse / Colors;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-3808,-2240;Inherit;False;Global;GrassRenderDist;GrassRenderDist;9;0;Create;True;0;0;0;False;0;False;50;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;120;-2048,-96;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;144;-3585.647,-1852.839;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0.11;False;2;FLOAT;0.52;False;3;FLOAT;1.5;False;4;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-2048,-320;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-1792,-320;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GammaToLinearNode;146;-3313.647,-1852.839;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;122;-1792,-96;Inherit;False;Constant;_WaveAndDistance;WaveAndDistance;4;0;Create;True;0;0;0;False;0;False;12,3.6,1,1;12,3.6,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;149;-3105.647,-1852.839;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-1536,-224;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-2753.647,-1852.839;Inherit;False;BaseOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;145;-3584,-2240;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;147;-3328,-2240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;150;-2976,-2240;Inherit;False;DistanceFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;148;-3168,-2240;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;151;-2945.647,-1852.839;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-1536,-96;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;39;-3808,-2752;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;40;-3616,-2720;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-3616,-2608;Inherit;False;Property;_NoiseTiling;Noise Tiling;11;0;Create;True;0;0;0;False;0;False;1.09;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-3424,-2688;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-3040,-2688;Inherit;False;WorldSpaceUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-640,-2432;Float;False;True;-1;4;;0;0;Standard;BK/Grass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.29;True;True;0;True;Opaque;;AlphaTest;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;True;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;217;-1067.918,-2289.233;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-1408,-2304;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-976,-1920;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-1184,-1792;Inherit;False;152;BaseOpacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;-1168,-1920;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-1408,-1792;Inherit;False;150;DistanceFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-1408,-1920;Inherit;False;202;_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;186;-1792,-2688;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;184;-1792,-2496;Inherit;False;160;WorldSpaceUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;185;-1536,-2608;Inherit;False;Property;_NormalWorldSpaceUVs;Normal WorldSpace UVs;9;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-1504,-2496;Inherit;False;Property;_NormalPower;Normal Power;8;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;181;-1216,-2624;Inherit;True;Property;_Normal;Normal;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;195;-1152,-2816;Inherit;False;194;_Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;191;-3808,-1344;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;176;-3808,-1216;Inherit;False;160;WorldSpaceUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;192;-3584,-1296;Inherit;False;Property;_NoiseWorldSpaceUVs;Noise WorldSpace UVs;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;165;-3264,-1312;Inherit;True;Property;_Noise;Noise;10;0;Create;True;0;0;0;False;1;Space(10);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-3248,-1072;Inherit;False;Property;_ColorVariationPower;Color Variation Power;6;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-2928,-1200;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;-2400,-1248;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1;-2656,-1152;Inherit;False;Property;_Color02;Color 02;3;0;Create;True;0;0;0;False;0;False;1,0.3215686,0,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;107;-2656,-1344;Inherit;False;Property;_Color01;Color 01;2;0;Create;True;0;0;0;False;1;Space(10);False;1,0.3215686,0,1;0.5613207,0.8245283,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-1280,-224;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.05;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-1280,-96;Inherit;False;Property;_WindMultiplier;Wind Multiplier;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;-1056,-224;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-864,-224;Inherit;False;MicroWind;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;2;-2432,-896;Inherit;True;Property;_MainTex;Texture;4;0;Create;False;0;0;0;False;1;Space(10);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-2080,-1024;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-1920,-1024;Inherit;False;_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;-1920,-800;Inherit;False;_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;218;-1293.823,-2226.291;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1288,-2046;Inherit;False;125;MicroWind;1;0;OBJECT;;False;1;FLOAT4;0
WireConnection;126;0;127;0
WireConnection;109;0;108;3
WireConnection;109;1;108;2
WireConnection;109;2;108;1
WireConnection;110;0;109;0
WireConnection;110;2;126;0
WireConnection;112;0;110;0
WireConnection;114;0;111;0
WireConnection;113;0;109;0
WireConnection;113;1;112;0
WireConnection;115;0;113;0
WireConnection;115;1;114;0
WireConnection;117;0;115;0
WireConnection;119;0;117;0
WireConnection;119;1;116;2
WireConnection;144;0;143;2
WireConnection;121;0;119;0
WireConnection;121;1;118;0
WireConnection;123;0;121;0
WireConnection;123;1;120;1
WireConnection;146;0;144;0
WireConnection;149;0;146;0
WireConnection;124;0;123;0
WireConnection;124;1;122;0
WireConnection;152;0;151;0
WireConnection;145;0;142;0
WireConnection;145;1;142;0
WireConnection;147;0;145;0
WireConnection;150;0;148;0
WireConnection;148;0;147;0
WireConnection;151;0;149;0
WireConnection;40;0;39;1
WireConnection;40;1;39;3
WireConnection;178;0;40;0
WireConnection;178;1;179;0
WireConnection;160;0;178;0
WireConnection;0;0;195;0
WireConnection;0;1;181;0
WireConnection;0;4;217;0
WireConnection;0;10;155;0
WireConnection;0;11;38;0
WireConnection;217;0;157;0
WireConnection;217;1;218;1
WireConnection;155;0;156;0
WireConnection;155;1;154;0
WireConnection;156;0;203;0
WireConnection;156;1;153;0
WireConnection;185;1;186;0
WireConnection;185;0;184;0
WireConnection;181;1;185;0
WireConnection;181;5;182;0
WireConnection;192;1;191;0
WireConnection;192;0;176;0
WireConnection;165;1;192;0
WireConnection;47;0;165;1
WireConnection;47;1;46;0
WireConnection;48;0;107;0
WireConnection;48;1;1;0
WireConnection;48;2;47;0
WireConnection;130;0;124;0
WireConnection;130;1;133;0
WireConnection;213;0;130;0
WireConnection;213;1;214;0
WireConnection;125;0;213;0
WireConnection;3;0;48;0
WireConnection;3;1;2;0
WireConnection;194;0;3;0
WireConnection;202;0;2;4
ASEEND*/
//CHKSM=0A716641E5D6B0B57CB9496AFCA9BD0B6149623A