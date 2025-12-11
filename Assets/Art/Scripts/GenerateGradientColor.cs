using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GenerateGradientColor : MonoBehaviour
{
    public Gradient gradient;
    public int resolution = 128;
    public Material mat;
    private const string _GradientTex = "_GradientTex";

    void Update()
    {
        GenerateGradientColorToShader(gradient, _GradientTex);
    }

    public void GenerateGradientColorToShader(Gradient gradient, string texName)
    {
        Texture2D tex = new Texture2D(resolution, 1, TextureFormat.ARGB32, false, true);
        tex.filterMode = FilterMode.Bilinear;
        tex.wrapMode = TextureWrapMode.Clamp;

        for(int i = 0; i < resolution; i++)
        {
            tex.SetPixel(i, 0, gradient.Evaluate(i * 1.0f / resolution).linear);
        }
        tex.Apply(false, false);

        mat.SetTexture(texName, tex);
    }


}