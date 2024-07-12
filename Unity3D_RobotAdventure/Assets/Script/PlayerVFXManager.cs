using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class PlayerVFXManager : MonoBehaviour
{
    public VisualEffect footStep;
    public ParticleSystem blade01;
    public VisualEffect slash;

    public void UpdateFootStepVFX(bool state)
    {
        if (state)
        {
            footStep.Play();
        }
        else
        {
            footStep.Stop();
        }
    }

    public void PlayBlade01()
    {
        blade01.Play();
    }

    public void PlaySlash(Vector3 pos)
    {
        slash.transform.position = pos;
        slash.Play();
    }
}
