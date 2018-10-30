using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour {
	[SerializeField]
	float Speed = 5;

	// Update is called once per frame
	void Update () {
		transform.position += Vector3.right * Input.GetAxis("Horizontal") * Speed * Time.deltaTime;
		transform.position += Vector3.forward * Input.GetAxis("Vertical") * Speed * Time.deltaTime;
	}
}
