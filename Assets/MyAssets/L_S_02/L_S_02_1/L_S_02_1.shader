Shader "MyShader/L_S_02_1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
       
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            
            //这里对语义要求严格
            struct appdata
            {
                float4 vertex : POSITION;
                //在顶点获取到UV信息
                float2 uv : TEXCOORD;
                
            };
            //这里对语义要求不严格
            struct v2f
            {
                float4 pos : SV_POSITION;
                //接受顶点传入的uv
                float2 uv : TEXCOORD;
            };

            v2f vert(appdata v)
            {
                v2f o  = (v2f)0;
                //本地空间转化到齐次裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                //把顶点的uv传下去
                o.uv = v.uv;

                return o;
            }
            fixed4 frag(v2f i) : SV_TARGET
            {
                //进行顶点采样
                fixed4 tex = tex2D(_MainTex,i.uv);
                
                return tex;
            }


            ENDCG
        }
    }
}

