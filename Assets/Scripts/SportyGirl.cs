using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SportyGirl : MonoBehaviour
{
    private Renderer renderer;
    private Shader standardShader;
    private Shader celShader;

    [SerializeField]
    public bool activateCel = true;
    
    private bool activateStandard = false; 

    void Start()
    {
        renderer = GetComponent<Renderer>();
        standardShader = Shader.Find("Standard");
        celShader = Shader.Find("Unlit/CelShader"); 
    }

    void Update()
    {
        if (activateCel && activateStandard)
        {
            renderer.material.shader = celShader; 
            activateStandard = false; 
        }
        else if (!activateCel && !activateStandard) 
        {
            renderer.material.shader = standardShader;
            activateStandard = true; 
        }

        transform.Rotate(new Vector3(0f, 0.3f, 0f));
    }
}
