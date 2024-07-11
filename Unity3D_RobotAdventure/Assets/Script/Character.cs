using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

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

    //Enemy
    public bool isPlayer = true;
    private NavMeshAgent navMeshAgent;
    private Transform targetPlayer;

    //Health
    private Health health;

    //Damage Caster
    private DamageCaster damageCaster;

    //State Machine
    [HideInInspector] 
    public enum CharacterState
    {
        Normal, Attacking
    }
    public CharacterState currentState;

    //Player slides
    private float attackStartTime;
    public float attackSlideDuration = 0.4f;
    public float attackSlideSpped = 0.06f;

    private void Awake()
    {
        characterController = GetComponent<CharacterController>();
        animator = GetComponent<Animator>();
        health = GetComponent<Health>();
        damageCaster = GetComponentInChildren<DamageCaster>();

        if (!isPlayer)
        {
            navMeshAgent = GetComponent<NavMeshAgent>();
            targetPlayer = GameObject.FindWithTag("Player").transform;
            navMeshAgent.speed = moveSpeed;
        }
        else
        {
            playerInput = GetComponent<PlayerInput>();
        }
    }

    private void CalculateEnemyMovement()
    {
        if (Vector3.Distance(targetPlayer.position, transform.position) >= navMeshAgent.stoppingDistance)
        {
            navMeshAgent.SetDestination(targetPlayer.position);
            animator.SetFloat("Speed", 0.2f);
        }
        else
        {
            navMeshAgent.SetDestination(transform.position);
            animator.SetFloat("Speed", 0f);

            SwitchStateTo(CharacterState.Attacking);
        }
    }

    private void CalculatePlayerMovement()
    {
        if(playerInput.MouseButtonDown && characterController.isGrounded)
        {
            SwitchStateTo(CharacterState.Attacking);
            return;
        }

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
        switch (currentState)
        {
            case (CharacterState.Normal):
                if (isPlayer)
                {
                    CalculatePlayerMovement();
                }
                else
                {
                    CalculateEnemyMovement();
                }
                break;

            case (CharacterState.Attacking):

                if (isPlayer)
                {
                    movementVelocity = Vector3.zero;

                    if(Time.time < attackStartTime + attackSlideDuration)
                    {
                        float timePassed = Time.time - attackStartTime;
                        float lerpTime = timePassed / attackSlideDuration;
                        movementVelocity = Vector3.Lerp(transform.forward * attackSlideSpped, Vector3.zero, lerpTime);
                    }
                }
                break;
        }

        if (isPlayer)
        {

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

    private void SwitchStateTo(CharacterState newState)
    {
        //Clear Cache
        if (isPlayer)
        {
            playerInput.MouseButtonDown = false;
        }
        
        //Exiting state
        switch (currentState)
        {
            case (CharacterState.Normal):
                break;
            case (CharacterState.Attacking):
                break;
        }

        //Enter state
        switch (newState)
        {
            case (CharacterState.Normal):
                break;
            case (CharacterState.Attacking):
                animator.SetTrigger("Attack");

                if (!isPlayer)
                {
                    Quaternion newRotation = Quaternion.LookRotation(targetPlayer.position - transform.position);
                    transform.rotation = newRotation;
                }

                if (isPlayer)
                {
                    attackStartTime = Time.time;
                }

                break;
        }

        currentState = newState;

        Debug.Log("Switch to" + currentState);
    }

    public void AttackAnimationEnds()
    {
        SwitchStateTo(CharacterState.Normal);
    }
       
    public void ApplyDamage(int damage, Vector3 attackPos = new Vector3())
    {
        if(health != null)
        {
            health.ApplyDamage(damage);
        }
    }

    public void EnableDamageCaster()
    {
        damageCaster.EnableDamageCaster();
    }

    public void DisableDamageCaster()
    {
        damageCaster.DisableDamageCaster();
    }
}
