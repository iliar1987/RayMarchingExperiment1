using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawSpheres : MonoBehaviour {
    public Material _material;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Copy the source Render Texture to the destination,
        // applying the material along the way.
        Graphics.Blit(source, destination, _material);
    }

    void LateUpdate()
    {
        // To investigate: do we need to use non-jittered version for antialiasing effects?
        var cam = gameObject.GetComponent<Camera>();
        var p = cam.projectionMatrix;
        //// Undo some of the weird projection-y things so it's more intuitive to work with.
        //p[2, 3] = p[3, 2] = 0.0f;
        //p[3, 3] = 1.0f;

        // I'll confess I don't understand entirely why this is right,
        // I just kept fiddling with numbers until it worked.
        p = Matrix4x4.Inverse(p * cam.worldToCameraMatrix);
           //* Matrix4x4.TRS(new Vector3(0, 0, -p[2, 2]), Quaternion.identity, Vector3.one);
        
        _material.SetMatrix("_ClipToWorld", p);
        _material.SetFloat("_NearPlane", cam.nearClipPlane);
    }

    // Use this for initialization
    void Start () {
        
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
