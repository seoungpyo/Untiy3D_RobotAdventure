using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player_Run : StateMachineBehaviour
{
    public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        if(animator.GetComponent<PlayerVFXManager>() != null)
        {
            animator.GetComponent<PlayerVFXManager>().UpdateFootStepVFX(true);
        }
    }

    public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        if (animator.GetComponent<PlayerVFXManager>() != null)
        {
            animator.GetComponent<PlayerVFXManager>().UpdateFootStepVFX(false);
        }
    }
}
