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
        Normal, Attacking, Dead, BeingHit, Slide
    }
    public CharacterState currentState;

    public GameObject itemToDrop;

    private MaterialPropertyBlock materialPropertyBlock;
    private SkinnedMeshRenderer skinnedMeshRenderer;

    //Player slides
    private float attackStartTime;
    public float attackSlideDuration = 0.4f;
    public float attackSlideSpped = 0.06f;

    private Vector3 impactOnCharacter;

    public bool IsInvincible;
    public float InvincibleDuration= 2f;

    private float attackAnimationDuration;

    public float slideSpeed = 9f;

    public int coin = 0;

    private void Awake()
    {
        characterController = GetComponent<CharacterController>();
        animator = GetComponent<Animator>();
        health = GetComponent<Health>();
        damageCaster = GetComponentInChildren<DamageCaster>();

        skinnedMeshRenderer = GetComponentInChildren<SkinnedMeshRenderer>();
        materialPropertyBlock = new MaterialPropertyBlock();
        skinnedMeshRenderer.GetPropertyBlock(materialPropertyBlock);


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
        if (playerInput.MouseButtonDown && characterController.isGrounded)
        {
            SwitchStateTo(CharacterState.Attacking);
            return;
        }
        else if (playerInput.spaceKeyDown && characterController.isGrounded)
        {
            SwitchStateTo(CharacterState.Slide);
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
            case CharacterState.Normal:
                if (isPlayer)
                {
                    CalculatePlayerMovement();
                }
                else
                {
                    CalculateEnemyMovement();
                }
                break;

            case CharacterState.Attacking:

                if (isPlayer)
                {
                    if(Time.time < attackStartTime + attackSlideDuration)
                    {
                        float timePassed = Time.time - attackStartTime;
                        float lerpTime = timePassed / attackSlideDuration;
                        movementVelocity = Vector3.Lerp(transform.forward * attackSlideSpped, Vector3.zero, lerpTime);
                    }

                    if (playerInput.MouseButtonDown && characterController.isGrounded)
                    {
                        string currentClipName = animator.GetCurrentAnimatorClipInfo(0)[0].clip.name;
                        attackAnimationDuration = animator.GetCurrentAnimatorStateInfo(0).normalizedTime;

                        if(currentClipName != "LittleAdventurerAndie_ATTACK_03" && attackAnimationDuration>0.5f && attackAnimationDuration < 0.7f)
                        {
                            playerInput.MouseButtonDown = false;
                            SwitchStateTo(CharacterState.Attacking);

                            CalculatePlayerMovement();
                        }
                    }
                }
                break;

            case CharacterState.Dead:
                return;

            case CharacterState.BeingHit:

                if(impactOnCharacter.magnitude > 0.2f)
                {
                    movementVelocity = impactOnCharacter * Time.deltaTime;
                }
                impactOnCharacter = Vector3.Lerp(impactOnCharacter, Vector3.zero, Time.deltaTime * 5);

                break;

            case CharacterState.Slide:
                movementVelocity = transform.forward * slideSpeed * Time.deltaTime;
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

            movementVelocity = Vector3.zero;

        }
    }

    public void SwitchStateTo(CharacterState newState)
    {
        //Clear Cache
        if (isPlayer)
        {
            playerInput.ClearCache();
        }
        
        //Exiting state
        switch (currentState)
        {
            case CharacterState.Normal:
                break;
            case CharacterState.Attacking:
                
                if(damageCaster != null)
                {
                    damageCaster.DisableDamageCaster();
                }
                if (isPlayer)
                {
                    GetComponent<PlayerVFXManager>().StopBlade();
                }
                break;
            case CharacterState.Dead:
                break;
            case CharacterState.BeingHit:
                break;
            case CharacterState.Slide:
                break;
        }

        //Enter state
        switch (newState)
        {
            case CharacterState.Normal:
                break;
            case CharacterState.Attacking:
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

            case CharacterState.Dead:
                characterController.enabled = false;
                animator.SetTrigger("Dead");
                StartCoroutine(MaterialDissolve());
                break;

            case CharacterState.BeingHit:
                animator.SetTrigger("BeingHit");
                if (isPlayer)
                {
                    IsInvincible = true;
                    StartCoroutine(DelayCancelInvincible());
                }
                break;
            case CharacterState.Slide:
                animator.SetTrigger("Slide");
                break;
        }

        currentState = newState;

    }

    public void SlideAnimationEnds()
    {
        SwitchStateTo(CharacterState.Normal);
    }

    public void AttackAnimationEnds()
    {
        SwitchStateTo(CharacterState.Normal);
    }

    public void BeingHitAnimationEnds()
    {
            SwitchStateTo(CharacterState.Normal);
    }
       
    public void ApplyDamage(int damage, Vector3 attackerPos = new Vector3())
    {
        if (IsInvincible)
        {
            return;
        }

        if(health != null)
        {
            health.ApplyDamage(damage);
        }

        if (!isPlayer)
        {
            GetComponent<EnemyVFXManager>().PlayBeingHitVFX(attackerPos);
        }

        StartCoroutine(MaterialBlink());

        if (isPlayer && currentState != CharacterState.Dead)
        {
            SwitchStateTo(CharacterState.BeingHit);
            AddImpact(attackerPos, 10f);
        }
    }

    IEnumerator DelayCancelInvincible()
    {
        yield return new WaitForSeconds(InvincibleDuration);
        IsInvincible = false;
    }

    private void AddImpact(Vector3 attackerPos,float force)
    {
        Vector3 impactDir = transform.position - attackerPos;
        impactDir.Normalize();
        impactDir.y = 0;
        impactOnCharacter = impactDir * force;
    }

    public void EnableDamageCaster()
    {
        damageCaster.EnableDamageCaster();
    }

    public void DisableDamageCaster()
    {
        damageCaster.DisableDamageCaster();
    }

    private IEnumerator MaterialBlink()
    {
        materialPropertyBlock.SetFloat("_blink", 0.4f);
        skinnedMeshRenderer.SetPropertyBlock(materialPropertyBlock);

        yield return new WaitForSeconds(0.2f);

        materialPropertyBlock.SetFloat("_blink", 0f);
        skinnedMeshRenderer.SetPropertyBlock(materialPropertyBlock);

    }


    IEnumerator MaterialDissolve()
    {
        yield return new WaitForSeconds(2f);

        float dissolveTimeDuration = 2f;
        float currentDissolveTime = 0;
        float dissolveHeightStart = 20f;
        float dissolveHeightTarget = -10f;
        float dissolveHeight;

        materialPropertyBlock.SetFloat("_enableDissolve", 1f);
        skinnedMeshRenderer.SetPropertyBlock(materialPropertyBlock);

        while(currentDissolveTime < dissolveTimeDuration)
        {
            currentDissolveTime += Time.deltaTime;
            dissolveHeight = Mathf.Lerp(dissolveHeightStart, dissolveHeightTarget, currentDissolveTime / dissolveTimeDuration);
            materialPropertyBlock.SetFloat("_dissolve_height", dissolveHeight);
            skinnedMeshRenderer.SetPropertyBlock(materialPropertyBlock);
            yield return null;
        }

        DropItem();
    }

    public void DropItem()
    {
        if(itemToDrop != null)
        {
            Instantiate(itemToDrop,transform.position,Quaternion.identity);
        }
    }

    public void PickUpItem(PickUp item)
    {
        switch (item.type)
        {
            case PickUp.PickUpType.Heal:
                AddHealth(item.value);
                break;
            case PickUp.PickUpType.Coin:
                AddCoin(item.value);
                break;
        }
    }

    private void AddHealth(int heal)
    {
        health.AddHealth(heal);
    }
    
    private void AddCoin(int coin)
    {
        this.coin += coin;
    }
}
