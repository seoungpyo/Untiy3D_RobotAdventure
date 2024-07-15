using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Health : MonoBehaviour
{
    public int maxHealth;
    [HideInInspector] public int currentHealth;
    private Character character;

    private void Awake()
    {
        currentHealth = maxHealth;
        character = GetComponent<Character>();
    }

    public void ApplyDamage(int damage)
    {
        currentHealth -= damage;
        Debug.Log(gameObject.name + " Took Damage " + damage);
        Debug.Log(gameObject.name + " current health : " + currentHealth);

        CheckHealth();
    }

    private void CheckHealth()
    {
        if(currentHealth <= 0)
        {
            character.SwitchStateTo(Character.CharacterState.Dead);
        }
    }
}
