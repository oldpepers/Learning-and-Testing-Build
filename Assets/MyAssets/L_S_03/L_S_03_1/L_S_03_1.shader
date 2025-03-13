Shader "MyShader/L_S_03_1"
{
    Properties
    {
        //使用这个标签，可以使外部暴露属性，有标题
        [Header(Base)]
        _MainTex ("Texture", 2D) = "white" {}
        _Value("Clip",Range(0,1)) = 0
        //使用这个标签可以 在两行暴露属性之间加 间隙
        [Space(10)]
        [Header(Dissolve)]
        _DissolveTex("DissolveTex",2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Value;
            sampler2D _DissolveTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                //外部获取的 纹理 ，使用前都需要采样
                fixed4 dissolve = tex2D(_DissolveTex,i.uv);
                //片段的取舍
                clip(dissolve.r -  _Value);
                return col;
            }
            ENDCG
        }
    }
}

