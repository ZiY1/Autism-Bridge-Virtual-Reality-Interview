Shader "SimpleTeleportEffect/UnlitTextureAlphaColor(Built-In)" {
	Properties {
		[Header(Color)]
		_Color ("Color", Color) = (1,1,1,1)
		_ColorMultiplier ("Color Multiplier(HDR)", float) = 1
		_MainTex ("Texture", 2D) = "white" {}
		_Opacity("Opacity", Range(0,1)) = 1

		[Header(Blink Mode)]
		[Toggle] _BlinkMode("Blink Mode", int) = 0
		_BlinkSpeed ("Blink Speed", float) = 1

		[Header(Noise)]
		[Toggle] _UseNoise("Use Noise", int) = 0
		_NoiseTex ("Noise Texture", 2D) = "white" {}
		_NoiseSpeed ("Noise Speed", float) = 1

		[Header(Draw Setting)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", float) = 2
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTestMode("ZTest", float) = 4
		[Enum(Off,0,On,1)] _ZWriteMode("ZWrite", float) = 0

		//https://docs.unity3d.com/ScriptReference/Rendering.BlendMode.html
		[Header(BlendMode)]
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Blend Source", float) = 5 // SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Blend Destination", float) = 1 // One
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		Cull [_CullMode]
		ZWrite [_ZWriteMode]
		ZTest [_ZTestMode]
		Blend [_SrcBlend] [_DstBlend]

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile_instancing
			#pragma shader_feature_local_fragment _BLINKMODE_ON
			#pragma shader_feature_local _USENOISE_ON

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				#if defined(_USENOISE_ON)
					float4 uvNoise : TEXCOORD1;
				#endif
				UNITY_FOG_COORDS(2)
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			#if defined(_USENOISE_ON)
				sampler2D _NoiseTex;
			#endif

			UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
			
			UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
			UNITY_DEFINE_INSTANCED_PROP(float, _ColorMultiplier)
			UNITY_DEFINE_INSTANCED_PROP(float, _Opacity)

			#if defined(_BLINKMODE_ON)
				UNITY_DEFINE_INSTANCED_PROP(float, _BlinkSpeed)
			#endif

			#if defined(_USENOISE_ON)
				UNITY_DEFINE_INSTANCED_PROP(float4, _NoiseTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _NoiseSpeed)
			#endif
			UNITY_INSTANCING_BUFFER_END(Props)

			v2f vert (appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				#if defined(_USENOISE_ON)
					o.uvNoise.xy = TRANSFORM_TEX(v.uv, _NoiseTex);
					o.uvNoise.zw = v.uv;
				#endif
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			half4 frag (v2f i) : SV_Target
			{
				// Color
				half4 color = tex2D(_MainTex, i.uv) * _Color;
				color.rgb *= _ColorMultiplier;

				// Blink
				#if defined(_BLINKMODE_ON)
					color.a *= abs(sin(_Time.z*_BlinkSpeed));
				#endif

				// Noise alpha
				#if defined(_USENOISE_ON)
					{
						float2 uvTime = float2(_Time.x, -_Time.y) * _NoiseSpeed;
						half noise = tex2D (_NoiseTex, i.uvNoise.xy + uvTime).g;
						half noiseTexAlpha = tex2D (_NoiseTex, i.uvNoise.zw).a;
						color.a = saturate(color.a * noise * noiseTexAlpha + noiseTexAlpha*0.5);
					}
				#endif

				color.a *= _Opacity;

				UNITY_APPLY_FOG(i.fogCoord, color);
				return color;
			}
			ENDCG
		}
	}
}
