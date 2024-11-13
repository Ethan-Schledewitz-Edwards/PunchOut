using UnityEngine;

public class LUTToggle : MonoBehaviour
{
    [SerializeField] GameObject LutOverlay;

    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Jump"))
        {
            LutOverlay.SetActive(!LutOverlay.activeInHierarchy);
        }
    }
}
