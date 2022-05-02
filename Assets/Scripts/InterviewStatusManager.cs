using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class InterviewStatusManager : MonoBehaviour
{
    [SerializeField] private GameObject player;
    [SerializeField] private TextMeshProUGUI greeting;
    [SerializeField] private TextMeshProUGUI firstTask;
    [SerializeField] private TextMeshProUGUI interviewText;
    [SerializeField] private TextMeshProUGUI congradsText;
    [SerializeField] private TextMeshProUGUI retryText;
    [SerializeField] private GameObject interviewBtnNext;
    [SerializeField] private GameObject interviewBtnRetry;

    private bool playerInPosition = false;

    // Start is called before the first frame update
    void Start()
    {
        IsPlayerInPosition();
    }

    // Update is called once per frame
    void Update()
    {
        IsPlayerInPosition();

        if (playerInPosition)
        {
            InitialzieInterview();
        }
        else
        {
            PauseInterview();
        }
    }

    private void IsPlayerInPosition()
    {
        if (player.transform.position.x < 7.5f)
        {
            playerInPosition = true;
        }
        else
        {
            playerInPosition = false;
        }
    }

    private void InitialzieInterview()
    {
        // When player is in position

        // hide the greeting and first task texts
        greeting.enabled = false;
        firstTask.enabled = false;

        // display the interview starter
        interviewText.enabled = true;
        interviewBtnNext.SetActive(true);
        //interviewBtnRetry.SetActive(true);
        if (interviewBtnRetry.activeSelf)
        {
            congradsText.enabled = true;
            retryText.enabled = true;
        }
    }

    private void PauseInterview()
    {
        // When player is not in position

        // display the greeting and first task texts
        greeting.enabled = true;
        firstTask.enabled = true;

        // hide the interview starter
        interviewText.enabled = false;
        interviewBtnNext.SetActive(false);
        //interviewBtnRetry.SetActive(false);
        congradsText.enabled = false;
        retryText.enabled = false;
    }
}
