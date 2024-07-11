using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Health : MonoBehaviour
{
    public int maxHealth;
    [HideInInspector] public int currentHealth;
    private CharacterController characterController;

    private void Awake()
    {
        currentHealth = maxHealth;
        characterController = GetComponent<CharacterController>();
    }

    public void ApplyDamage(int damage)
    {
        currentHealth -= damage;
        Debug.Log(gameObject.name + " Took Damage " + damage);
        Debug.Log(gameObject.name + " current health : " + currentHealth);
    }
}
