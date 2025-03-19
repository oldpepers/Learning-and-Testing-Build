Shader "MyShader/L_S_13_c"
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
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
            };

            //在使用抓取的屏幕前，需要像使用属性一样定义一下,_GrabTexture这个名字是Unity定义好的
            sampler2D _GrabTex;
            sampler2D _DistortTex;float4 _DistortTex_ST;
            float4 _Distort;
            
            
            //在顶点着色器的输入处，不用appdata,直接使用用到的参数，防止 SV_POSITION 重复定义
            v2f vert (
                float4 vertex : POSITION,
                //从应用程序阶段的输入，多加一个uv，用于对扭曲纹理的采样
                float2 uv : TEXCOORD,
                out float4 pos : SV_POSITION
            )
            {
                v2f o;
                pos = UnityObjectToClipPos(vertex);
                o.uv = TRANSFORM_TEX(uv,_DistortTex) + _Distort.xy * _Time.y;
                return o;
            }

            fixed4 frag (v2f i,UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
            {
                
                fixed2 screenUV = screenPos.xy / _ScreenParams.xy;

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


