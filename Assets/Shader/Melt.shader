// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Melt"
{
	Properties{
		_MainTex("Base(rgb)", 2D) = "white"{}
		_NoiseMap("NoiseMap", 2D) = "white"{}
		_StartColor("StarColor", Color) = (0,0,0,0)
		_EndColor("EndColor", Color) = (0,0,0,0)
		_MeltThreshold("MeltThreshold", Range(0, 1)) = 0
		_Erode("Erode", Range(0.0, 1.0)) = 0.98
		_ErodeColor("ErodeColor", Range(0.0, 1.0)) = 0.71
	}


	SubShader{

		CGINCLUDE

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseMap;
			//消融边缘起始颜色
			fixed4 _StartColor;
			//最终颜色
			fixed4 _EndColor;
			//消融阈值
			float _MeltThreshold;
			//控制侵蚀程度
			float _Erode;
			float _ErodeColor;

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
				//使用噪声图，伪随机数
				fixed3 melt = tex2D(_NoiseMap, i.uv).rgb;

				//采样阈值与设定阈值比较，小于设定的阈值就裁剪掉该片元，也就是消融
				clip(melt.r - _MeltThreshold);

				//光照计算部分，使用兰伯特漫反射光照模型

				//纹理采样得到反射率
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//计算环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(i.worldNormal, worldLightDir));
				//最终光照
				fixed3 lightColor = diffuse + ambient;

				//侵蚀计算部分
				float percent = _MeltThreshold / melt.r;

				if(percent > _Erode){

					if(percent > _ErodeColor) {

						return _EndColor;
					}
					
					return _StartColor;

				}

				return fixed4(lightColor, 1);
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

	FallBack Off
}
