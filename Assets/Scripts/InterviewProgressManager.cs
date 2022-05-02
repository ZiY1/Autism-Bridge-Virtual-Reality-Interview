using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class InterviewProgressManager : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI interviewText;
    [SerializeField] private TextMeshProUGUI congradsText;
    [SerializeField] private TextMeshProUGUI retryText;
    [SerializeField] private GameObject interviewBtnNext;
    [SerializeField] private GameObject interviewBtnRetry;

    [SerializeField] private AudioSource greetingAudio;
    [SerializeField] private AudioSource q1Audio;
    [SerializeField] private AudioSource q2Audio;
    [SerializeField] private AudioSource q3Audio;
    [SerializeField] private AudioSource endAudio;


    private int cursor = 0;
    private string[] interviewQuestionArr = { "Tell me something about yourself.", "Why did you decide to apply for this position?", "What are your strengths and weaknesses?" };

    private void Awake()
    {
        greetingAudio.PlayDelayed(2f);
    }


    public void DisplayNextInterviewQuestion()
    {
        if (cursor < interviewQuestionArr.Length)
        {
            if (cursor == 0)
            {
                q1Audio.Play(0);
            }
            else if (cursor == 1)
            {
                q2Audio.Play(0);
            }
            else if (cursor == 2)
            {
                q3Audio.Play(0);
            }

            // Display the next interview question
            interviewText.text = interviewQuestionArr[cursor++];
        } else
        {
            endAudio.Play(0);

            // Diable the next btn, enable the retry btn
            interviewBtnNext.SetActive(false);
            interviewBtnRetry.SetActive(true);

            // Clean the interview text
            interviewText.text = "";

            // Set the congrads text and retry text
            congradsText.enabled = true;
            retryText.enabled = true;
            congradsText.text = "Congratulations!";
            retryText.text = "You have answered all interview questions. Click restart to practice the interview again";
        }
    }

    public void RestartBtnOnPressed()
    {
        // Clean the congrads text and retry text
        congradsText.text = "";
        retryText.text = "";

        // Set cursor to 0
        cursor = 0;

        // Reset the interview text
        interviewText.text = "Click next to start the interview when you are ready";

        // Diable the retry btn, enable the next btn
        interviewBtnRetry.SetActive(false);
        interviewBtnNext.SetActive(true);
    }
}
