using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Events;
using System;

public class TeleportToggle : MonoBehaviour
{
    [SerializeField] private InputActionReference teleportToggleBtn;

    public UnityEvent OnTeleportActivate;
    public UnityEvent OnTeleportCancel;

    #region Input Action Listerners
    private void OnEnable()
    {
        teleportToggleBtn.action.performed += ActivateTeleport;
        teleportToggleBtn.action.canceled += DeactivateTeleport;
    }

    private void OnDisable()
    {
        teleportToggleBtn.action.performed -= ActivateTeleport;
        teleportToggleBtn.action.canceled -= DeactivateTeleport;
    }
    #endregion

    private void ActivateTeleport(InputAction.CallbackContext obj)
    {
        OnTeleportActivate.Invoke();
    }
    private void DeactivateTeleport(InputAction.CallbackContext obj)
    {
        Invoke("TurnOffTeleport", .1f);
    }

    private void TurnOffTeleport()
    {
        OnTeleportCancel.Invoke();
    }

    
}
