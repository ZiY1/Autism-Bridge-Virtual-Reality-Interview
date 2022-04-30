Shader "SimpleTeleportEffect/UnlitTextureAlphaColor(URP)" {
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
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varying
			{
				float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 uvTex : TEXCOORD1;
				float fogCoord : TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			TEXTURE2D(_MainTex);
			TEXTURE2D(_NoiseTex);
			SAMPLER(sampler_MainTex);
			SAMPLER(sampler_NoiseTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;

			half4 _Color;
			float _ColorMultiplier;
			float _Opacity;

			half _UseNoise;
			float _NoiseSpeed;

			half _BlinkMode;
			float _BlinkSpeed;
			CBUFFER_END

			Varying vert (Attributes IN)
			{
				Varying OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_TRANSFER_INSTANCE_ID(Varying, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				OUT.uvTex.xy = TRANSFORM_TEX(IN.uv, _NoiseTex);
				OUT.uvTex.zw = IN.uv;
				OUT.fogCoord = ComputeFogFactor(OUT.positionCS.z);
				return OUT;
			}

			half4 frag (Varying IN) : SV_Target
			{
				// Color
				half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;
				color.rgb *= _ColorMultiplier;
				color.a *= _Opacity;
				
				// Blink
				if(_BlinkMode > 0)
				{
					color.a *= abs(sin(_Time.z*_BlinkSpeed));
				}

				// Noise alpha
				// Didn't use shader variation to batch objects.(SRP batcher)
				// This is inefficient to pixel shader optimization but I'd rather to have batching advantage.
				if(_UseNoise)
				{
					float2 uvTime = float2(_Time.x, -_Time.y) * _NoiseSpeed;
					half noise = SAMPLE_TEXTURE2D (_NoiseTex, sampler_NoiseTex, IN.uvTex.xy + uvTime).g;
					half noiseTexAlpha = SAMPLE_TEXTURE2D (_NoiseTex, sampler_NoiseTex, IN.uvTex.zw).a;
					color.a = saturate(color.a * noise * noiseTexAlpha + noiseTexAlpha*0.5);
				}

				color.rgb = MixFog(color.rgb, IN.fogCoord);
				return color;
			}
			ENDHLSL
		}
	}
}
