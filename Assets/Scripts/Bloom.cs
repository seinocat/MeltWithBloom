using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectsBase {

	public Shader bloomShader;

	private Material bloomMaterial;

	public Material material{
		get{
			bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
			return bloomMaterial;
		}
	}


	//高斯模糊迭代次数
	[Range(0, 4)]
	public int iterations = 3;

	//模糊范围取值
	[Range(0.2f, 3.0f)]
	public float blurSpread = 0.6f;

	//降采样，一般取2次就行，多了会照常图片像素化
	[Range(1, 3)]
	public int downSample = 2;

	//亮度阈值
	[Range(0.0f, 4.0f)]
	public float luminanceThreshold = 0.6f;

	void OnRenderImage(RenderTexture src, RenderTexture dest){
		if(material != null){
			material.SetFloat("_LuminanceThreshold", luminanceThreshold);
			//先对原图进行降采样
			int rtW = src.width/downSample;
			int rtH = src.height/downSample;

			RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH, 0);
			rt0.filterMode = FilterMode.Bilinear;

			//提取采样亮度后的图片，存放入rt0，接下来对这些高亮度区域进行高斯模糊得到泛光效果
			Graphics.Blit(src, rt0, material, 0);
			
			for(int i = 0; i < iterations; i++){
				material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

				RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				//使用第2个pass进行横向高斯滤波
				Graphics.Blit(rt0, rt1, material, 1);
				RenderTexture.ReleaseTemporary(rt0);

				rt0 = rt1;
				rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				//第3个pass纵向滤波
				Graphics.Blit(rt0, rt1, material, 2);
				RenderTexture.ReleaseTemporary(rt0);
				rt0 = rt1;
			}

			material.SetTexture("_Bloom", rt0);
			//第4个pass对泛光后的图片和原图进行混合，输出到屏幕
			Graphics.Blit(src, dest, material, 3);
			RenderTexture.ReleaseTemporary(rt0);
		}else{
			Graphics.Blit(src, dest);
		}
	}
}
