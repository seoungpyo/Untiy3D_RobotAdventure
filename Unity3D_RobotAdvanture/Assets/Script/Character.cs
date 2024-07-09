using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Character : MonoBehaviour
{
    private CharacterController characterController;
    public float moveSpeed = 5f;

    private Vector3 movementVelocity;
    private PlayerInput playerInput;

    private float verticalVelocity;
    public float Gravity = -9.8f;

    private void Awake()
    {
        characterController = GetComponent<CharacterController>();
        playerInput = GetComponent<PlayerInput>();
    }

    private void CalculatePlayerMovement()
    {
        movementVelocity.Set(playerInput.horizontalInput, 0, playerInput.verticalInput);
        movementVelocity.Normalize();
        movementVelocity = Quaternion.Euler(0, -45f, 0) * movementVelocity;
        movementVelocity *= moveSpeed * Time.deltaTime;

        if (movementVelocity != Vector3.zero)
        {
            transform.rotation = Quaternion.LookRotation(movementVelocity);
        }
    }

    private void FixedUpdate()
    {
        CalculatePlayerMovement();

        if (characterController.isGrounded == false)
        {
            verticalVelocity = Gravity;
        }
        else
        {
            verticalVelocity = Gravity * 0.3f;
        }
        movementVelocity += verticalVelocity * Vector3.up * Time.deltaTime;
        characterController.Move(movementVelocity);
    }
}
