using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public GameUIManager gameUIManager;
    public Character playerCharacter;
    private bool gameIsOver;

    private void Awake()
    {
        playerCharacter = GameObject.FindWithTag("Player").GetComponent<Character>();
    }
    public void GameOver()
    {
        gameUIManager.ShowGameOverUI();
    }

    public void GameIsFinished()
    {
        gameUIManager.ShowGameIsFinishedUI();
    }

    void Update()
    {
        if (gameIsOver) return;

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            gameUIManager.TogglePauseUI();
        }

        if(playerCharacter.currentState == Character.CharacterState.Dead)
        {
            gameIsOver = true;
            GameOver();
        }
    }

    public void ReturnToTheMainMenu()
    {
        Time.timeScale = 1;
        SceneManager.LoadScene("MainMenu");
    }

    public void Restart()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
      
}
