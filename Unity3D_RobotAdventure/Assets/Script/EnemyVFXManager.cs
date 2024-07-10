using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class EnemyVFXManager : MonoBehaviour
{
    public VisualEffect footStep;
    public VisualEffect attackVFX;

    public void PlayAttackVFX()
    {
        attackVFX.SendEvent("OnPlay");
    }

    public void BrustFootStep()
    {
        footStep.SendEvent("OnPlay");
    }
}
