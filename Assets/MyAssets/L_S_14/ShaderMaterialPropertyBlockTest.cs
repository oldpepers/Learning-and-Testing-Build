using UnityEngine;

public class ShaderMaterialPropertyBlockTest : MonoBehaviour
{
    [Header("生成的对象")] public GameObject gameObj;
    [Header("生成数量")] public int count = 100;
    [Header("生成范围")] public float range = 10;

    private GameObject [] gameObjects;
    private MaterialPropertyBlock prop;
        
    void Start()
    {
        gameObjects = new GameObject[count];
        prop = new MaterialPropertyBlock();

        for (int i = 0;i < count;i++) 
        {
            //随机位置并生成对象
            Vector2 pos = Random.insideUnitCircle * range;
            GameObject go = Instantiate(gameObj, new Vector3(pos.x, 0, pos.y),Quaternion.identity);
            gameObjects[i] = go;
        }
    }

        
    void Update()
    {
        //优化前，直接修改Shader中暴露的属性
        /*for (int i = 0;i < gameObjects.Length;i++)
        {
            float r = Random.Range(0f,1f);
            float g = Random.Range(0f,1f);
            float b = Random.Range(0f,1f);
            Color newColor = new Color(r, g, b, 1);
            gameObjects[i].GetComponentInChildren<MeshRenderer>().material.SetColor("_Color",newColor);
        }*/
            
        //优化后，使用MaterialPropertyBlock方案
        //该方案需要在Shader暴露属性中加上  [PerRendererData] 标签
        //这个是配合 SetPropertyBlock(prop);来使用的
        //这个可以用来更改同样材质球，都是不同物体的Shader属性
        for (int i = 0;i < gameObjects.Length;i++)
        {
            float r = Random.Range(0f,1f);
            float g = Random.Range(0f,1f);
            float b = Random.Range(0f,1f);
            Color newColor = new Color(r, g, b, 1);

            var mr = gameObjects[i].GetComponentInChildren<MeshRenderer>();
            mr.GetPropertyBlock(prop);
            prop.SetColor("_Color",newColor);
            mr.SetPropertyBlock(prop);
        }
    }
}
