using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectsBase {

	public Shader bloomShader;

	private Material bloomMaterial;

	public Material material{
		get{
			return CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
		}
	}

	[Range(0, 4)]
	public int iterations = 3;

	[Range(0.2f, 3.0f)]
	public float blurSpread = 0.6f;

	[Range(1, 8)]
	public int downSample = 2;

	[Range(0.0f, 4.0f)]
	public float luminanceThreshold = 0.6f;

	void OnRenderImage(RenderTexture src, RenderTexture dest){
		if(material != null){
			material.SetFloat("_LuminancceThreshold", luminanceThreshold);
			int rtW = src.width/downSample;
			int rtH = src.height/downSample;

			RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH, 0);
			rt0.filterMode = FilterMode.Bilinear;

			Graphics.Blit(src, rt0, material, 0);
			
			for(int i = 0; i < iterations; i++){
				material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

				RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);

				Graphics.Blit(rt0, rt1, material, 1);
				RenderTexture.ReleaseTemporary(rt0);

				rt0 = rt1;
				rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				Graphics.Blit(rt0, rt1, material, 2);
				RenderTexture.ReleaseTemporary(rt0);
				rt0 = rt1;
			}

			material.SetTexture("_Bloom", rt0);
			Graphics.Blit(src, dest, material, 3);
			RenderTexture.ReleaseTemporary(rt0);
		}else{
			Graphics.Blit(src, dest);
		}
	}
}
