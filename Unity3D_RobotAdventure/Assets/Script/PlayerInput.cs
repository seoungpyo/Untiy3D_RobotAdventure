using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInput : MonoBehaviour
{
    [HideInInspector] public float horizontalInput;
    [HideInInspector] public float verticalInput;
    [HideInInspector] public bool MouseButtonDown;

    private void Update()
    {
        if(!MouseButtonDown && Time.timeScale != 0)
        {
            MouseButtonDown = Input.GetMouseButtonDown(0);
        }
        horizontalInput = Input.GetAxisRaw("Horizontal");
        verticalInput = Input.GetAxisRaw("Vertical");
    }

    private void OnDisable()
    {
        MouseButtonDown = false;
        horizontalInput = 0;
        verticalInput = 0;
    }
}
