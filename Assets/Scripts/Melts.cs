using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Melts : MonoBehaviour {

	public Material material;

	[Range(0.01f, 1.0f)]
	public float meltSpeed = 0.2f;

	private float meltProcess = 0.0f;

	void Update(){

		meltProcess = Mathf.Repeat(Time.time * meltSpeed, 2.0f);
		material.SetFloat("_MeltProcess", meltProcess);

	}
}
