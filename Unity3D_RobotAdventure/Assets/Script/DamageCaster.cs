using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DamageCaster : MonoBehaviour
{
    private Collider damageCasterCollider;
    public int damage = 30;
    public string TargetTag;
    private List<Collider> damageTargetList;

    private void Awake()
    {
        damageCasterCollider = GetComponent<Collider>();
        damageCasterCollider.enabled = false;
        damageTargetList = new List<Collider>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == TargetTag && !damageTargetList.Contains(other))
        {
            Character targetCharacterController = other.GetComponent<Character>();

            if(targetCharacterController != null)
            {
                targetCharacterController.ApplyDamage(damage, transform.parent.position);
                PlayerVFXManager playerVFXManager = transform.parent.GetComponent<PlayerVFXManager>();
                if(playerVFXManager != null)
                {
                    RaycastHit hit;

                    Vector3 originalPos = transform.position + (-damageCasterCollider.bounds.extents.z) * transform.forward;

                    bool isHit = Physics.BoxCast(originalPos, damageCasterCollider.bounds.extents / 2, transform.forward,
                        out hit, transform.rotation, damageCasterCollider.bounds.extents.z, 1 << 6);

                    if (isHit)
                    {
                        playerVFXManager.PlaySlash(hit.point + new Vector3(0, 0.5f, 0));
                    }
                }
            }
            damageTargetList.Add(other);
        }
    }

    public void EnableDamageCaster()
    {
        damageTargetList.Clear();
        damageCasterCollider.enabled = true;
    }

    public void DisableDamageCaster()
    {
        damageTargetList.Clear();
        damageCasterCollider.enabled = false;
    }

  
}
