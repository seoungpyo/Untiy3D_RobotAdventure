using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy02Shoot : MonoBehaviour
{
    public Transform shootingPoint;
    public GameObject damageOrb;
    private Character character;

    private void Awake()
    {
        character = GetComponent<Character>();
    }

    public void ShootTheDamageOrb()
    {
        Instantiate(damageOrb, shootingPoint.position, Quaternion.LookRotation(shootingPoint.forward));
    }

    private void Update()
    {
        character.RotateToTarget();
    }
}
