Shader "MyShader/L_S_13_e"
{
    Properties
    {
        //实现扭曲，就需要传入贴图来实现扰度
        _DistortTex("DistortTex",2D) = "white"{}
        
        _Distort("SpeedX(X) SpeedY(y) Distort(Z)",vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags{"Queue" = "Transparent"}
        //屏幕抓取需要单独使用一个Pass —— GrabPass{} 里面什么都不写，或者GrabPass{"_GrabTex"}
        GrabPass{"_GrabTex"}
        //使用Cull off 让两面都有扭曲
        Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                //从应用程序阶段的输入，多加一个uv，用于对扭曲纹理的采样
                float2 uv : TEXCOORD;
                
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 screenUV:TEXCOORD1;
            };

            //在使用抓取的屏幕前，需要像使用属性一样定义一下,_GrabTexture这个名字是Unity定义好的
            sampler2D _GrabTex;
            sampler2D _DistortTex;float4 _DistortTex_ST;
            float4 _Distort;

            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_DistortTex) + _Distort.xy * _Time.y;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //使用传入片元着色器的 pos 来计算得到，用于给抓取的屏幕采样的变量
                fixed2 screenUV = i.pos.xy / _ScreenParams.xy;
                 
                fixed4 distortTex = tex2D(_DistortTex,i.uv);

                //使用线性插值来控制UV的扭曲程度
                float2 uv = lerp(screenUV,distortTex,_Distort.z);
                //对抓取的屏幕进行采样
                fixed4 grabTex = tex2D(_GrabTex,uv);
                return grabTex;
                
            }
            ENDCG
        }
    }
}


