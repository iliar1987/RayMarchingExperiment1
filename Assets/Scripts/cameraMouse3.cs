using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cameraMouse3 : MonoBehaviour {

    public float m_fMouseSensitivity = 10.0f;
    public float m_fMouseSmooth = 0.75f;

    public bool m_bNeedRightMButton = true;

    private Vector2 m_mickeysCurrent = new Vector2(0, 0);

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update ()
    {
        Vector2 mickeysInput = new Vector2(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));
        m_mickeysCurrent = m_fMouseSmooth * m_mickeysCurrent + (1 - m_fMouseSmooth) * mickeysInput;

        if (m_bNeedRightMButton && !Input.GetMouseButton(1) )
        {
            return;
        }

        Vector3 v3MouseScreen = new Vector3(m_mickeysCurrent.x, m_mickeysCurrent.y, 0);
        Vector3 v3RotVecScreen = Vector3.Cross(new Vector3(0, 0, 1), v3MouseScreen);
        
        gameObject.transform.Rotate(v3RotVecScreen.normalized, v3RotVecScreen.magnitude * m_fMouseSensitivity,Space.Self);
    }
}
