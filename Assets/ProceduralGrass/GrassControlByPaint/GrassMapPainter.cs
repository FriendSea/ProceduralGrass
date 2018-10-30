using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassMapPainter : MonoBehaviour {
	[SerializeField]
	Vector2 MeshScale;
	[SerializeField]
	Material MapMaterial;
	[SerializeField]
	Material BendMaterial;
	[SerializeField]
	Renderer GrassRenderer;

	RenderTexture GrassMap;

	const int resolution = 128;
	void Start()
	{
		GrassMap = new RenderTexture(resolution, resolution, 16, RenderTextureFormat.ARGB32);
		GrassMap.Create();
		GrassRenderer.material.SetTexture("_MainTex", GrassMap);
	}

	void Update () {
		Graphics.Blit(GrassMap, GrassMap, MapMaterial);
		foreach (var go in Collisions)
			PaintBend(go.transform.position);
	}

	void PaintBend(Vector3 position){
		Vector3 localpos = transform.worldToLocalMatrix.MultiplyPoint(position);
		Vector2 PaintPos = new Vector2(localpos.x, localpos.z);
		PaintPos.x /= MeshScale.x;
		PaintPos.y /= MeshScale.y;
		BendMaterial.SetVector("_BendPos", PaintPos);
		Graphics.Blit(GrassMap, GrassMap, BendMaterial);
	}

	List<GameObject> Collisions = new List<GameObject>();
	private void OnCollisionEnter(Collision collision)
	{
		if (Collisions.Contains(collision.gameObject)) return;
		Collisions.Add(collision.gameObject);
	}

	private void OnCollisionExit(Collision collision)
	{
		if (!Collisions.Contains(collision.gameObject)) return;
		Collisions.Remove(collision.gameObject);
	}

	private void OnDrawGizmos()
	{
		Gizmos.color = Color.red;
		Gizmos.matrix = transform.localToWorldMatrix;
		Gizmos.DrawWireCube(Vector3.zero, Vector3.right * MeshScale.x + Vector3.forward * MeshScale.y);
		Gizmos.matrix = Matrix4x4.identity;
	}
}
