using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Character : MonoBehaviour
{
    private CharacterController characterController;
    public float moveSpeed = 5f;
    public float rotateSpeed = 10f;

    private Vector3 movementVelocity;
    private PlayerInput playerInput;

    private float verticalVelocity;
    [HideInInspector] public float Gravity = -20f;

    private Animator animator;


    private void Awake()
    {
        characterController = GetComponent<CharacterController>();
        playerInput = GetComponent<PlayerInput>();
        animator = GetComponent<Animator>();
    }

    private void CalculatePlayerMovement()
    {
        movementVelocity.Set(playerInput.horizontalInput, 0, playerInput.verticalInput);
        movementVelocity.Normalize();
        movementVelocity = Quaternion.Euler(0, -45f, 0) * movementVelocity;

        animator.SetFloat("Speed", movementVelocity.magnitude);

        movementVelocity *= moveSpeed * Time.deltaTime;

        if (movementVelocity != Vector3.zero)
        {
            transform.rotation = Quaternion.Slerp(transform.rotation, (Quaternion.LookRotation(movementVelocity)), rotateSpeed * Time.deltaTime);
        }

        animator.SetBool("AirBome", !characterController.isGrounded);
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
