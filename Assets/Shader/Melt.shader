Shader "Unlit/Melt"
{
	Properties{
		_MainTex("Base(rgb)", 2D) = "white"{}
		_NoiseMap("NoiseMap", 2D) = "white"{}
		_StartColor("StarColor", Color) = (0,0,0,0)
		_EndColor("EndColor", Color) = (0,0,0,0)
		_MeltThreshold("MeltThreshold", Range(0, 1)) = 0
		_ColorFactor("ColorFactor", Range(0, 1)) = 0.9
		_MeltEdge("MeltEdge", Range(0, 1)) = 0.8

	}


	SubShader{

		CGINCLUDE

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseMap;
			fixed4 _StartColor;
			fixed4 _EndColor;
			float _MeltThreshold;
			float _ColorFactor;
			float _MeltEdge;

			#include "Lighting.cginc"

			struct a2v{
				float4 vertex : POSITION;
    			float3 normal : NORMAL;
    			float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};

			v2f vert(a2v v){
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 melt = tex2D(_NoiseMap, i.uv).rgb;

				clip(melt.r - _MeltThreshold);

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(i.worldNormal, worldLightDir));

				fixed3 lightColor = diffuse + ambient;

				float percent = _MeltThreshold / melt.r;

				float lerpEdge = saturate(sign(percent - _ColorFactor - _MeltEdge));

				fixed3 edgeColor = lerp(_EndColor, _StartColor, lerpEdge);

				float color = saturate(sign(percent - _ColorFactor));

				fixed3 finalColor = lerp(lightColor, edgeColor, color);

				return fixed4(finalColor, 1);
			}

		ENDCG


		Pass{

			Tags{ "RenderType" = "Opaque"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
	}

	FallBack ""
}
