Shader"MyShader/L_S_14"
{
    Properties
    {
        //命名要按标准来，这个属性才可以和Unity组件中的属性产生关联
        //比如说，在更改 Image 的源图片时，同时更改这个
        [PerRendererData]_MainTex("MainTex",2D) = "white"{}
        
        [PerRendererData]_Color("Color",color) = (1,1,1,1)
    }
    SubShader
    {
        //更改渲染队列（UI的渲染队列一般是半透明层的）
        Tags {"Queue" = "TransParent"}
        //混合模式
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex  vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            //存储 应用程序输入到顶点着色器的信息
            struct appdata
            {
                //顶点信息
                float4 vertex:POSITION;

                float2 uv : TEXCOORD;
            };
            //存储 顶点着色器输入到片元着色器的信息
            struct v2f
            {
                //裁剪空间下的位置信息
                float4 pos:SV_POSITION;
                float2 uv : TEXCOORD;
            };
            
            sampler2D _MainTex;
            fixed4 _Color;
            v2f vert(appdata v)
            {
                v2f o;
                //把顶点信息转化到裁剪坐标下
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 mainTex = tex2D(_MainTex,i.uv);
                return  mainTex * _Color;
            }
            
            ENDCG
        }
    }
}
