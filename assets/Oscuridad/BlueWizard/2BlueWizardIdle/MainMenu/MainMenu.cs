using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{

    public void CargarNivel(string nombreNivel) => SceneManager.LoadScene(nombreNivel);

    public void salir() => Application.Quit();


}
