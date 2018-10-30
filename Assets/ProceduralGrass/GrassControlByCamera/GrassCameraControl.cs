using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassCameraControl : MonoBehaviour {
	[SerializeField]
	GameObject CollisionObject;
	Dictionary<GameObject, GameObject> Collisions = new Dictionary<GameObject, GameObject>();

	const int resolution = 128;
	private void Start()
	{
		RenderTexture grassmap = new RenderTexture(resolution, resolution, 16, RenderTextureFormat.ARGB32);
		grassmap.Create();
		foreach(var r in GetComponentsInChildren<Renderer>()){
			if (r.gameObject == gameObject) continue;
			r.material.SetTexture("_MainTex", grassmap);
		}
		foreach (var c in GetComponentsInChildren<Camera>())
		{
			if (c.gameObject == gameObject) continue;
			c.enabled = true;
			c.targetTexture = grassmap;
		}
	}

	private void Update()
	{
		foreach (var c in Collisions)
			c.Value.transform.SetPositionAndRotation(c.Key.transform.position,transform.rotation);
	}

	private void OnCollisionEnter(Collision collision)
	{
		if (Collisions.ContainsKey(collision.gameObject)) return;

		Collisions.Add(collision.gameObject, Instantiate(CollisionObject, collision.gameObject.transform.position, transform.rotation));
	}

	private void OnCollisionExit(Collision collision)
	{
		if (!Collisions.ContainsKey(collision.gameObject)) return;

		Destroy(Collisions[collision.gameObject]);
		Collisions.Remove(collision.gameObject);
	}
}
