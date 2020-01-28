using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCamera : MonoBehaviour {
    public float _MoveSpeed = 1.0f;
    public float _SpinSpeed = 1.0f;
    public float _MoveAcceleration = 1.0f;

    private float _curSpeed = 0;
    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        bool modifier = (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift));
        
        gameObject.transform.position += Time.deltaTime * _MoveSpeed * gameObject.transform.forward * Input.GetAxis("Vertical") * ( modifier ? 5.0f : 1.0f) ;
        gameObject.transform.position += Time.deltaTime * _MoveSpeed * gameObject.transform.right * Input.GetAxis("Horizontal") * (modifier ? 5.0f : 1.0f);

        float spinAngle = Time.deltaTime * _SpinSpeed * Input.GetAxis("Spin");
        gameObject.transform.rotation = gameObject.transform.rotation * (new Quaternion(0,0,Mathf.Sin(spinAngle/2),Mathf.Cos(spinAngle/2)));
    }
}
