using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Melts : MonoBehaviour {

	public Material material;

	[Range(0.01f, 1.0f)]
	public float meltSpeed = 0.2f;

	private float meltThreshold = 0.0f;

	void Start(){
		material.SetFloat("_MeltThreshold", 0);
	}

	void Update(){
		//使用时间控制消融阈值
		meltThreshold = Mathf.Repeat(Time.time * meltSpeed, 6.0f);
		material.SetFloat("_MeltThreshold", meltThreshold);

	}

}
