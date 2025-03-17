Shader "MyShader/L_S_12_b"
{
    SubShader
    {
        Tags{"Queue" = "Transparent"}
        //屏幕抓取需要单独使用一个Pass —— GrabPass{} 里面什么都不写，或者GrabPass{"_GrabTex"}
        GrabPass{"_GrabTex"}
        
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
            //在顶点着色器的输入处，不用appdata,直接使用用到的参数，防止 SV_POSITION 重复定义
            v2f vert (
                float4 vertex : POSITION,
                out float4 pos : SV_POSITION
            )
            {
                v2f o;
                pos = UnityObjectToClipPos(vertex);
                return o;
            }

            fixed4 frag (v2f i,UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
            {
                
                fixed2 screenUV = screenPos.xy / _ScreenParams.xy;
                //对抓取的屏幕进行采样
                fixed4 grabTex = tex2D(_GrabTex,screenUV);
                return grabTex;
            }
            ENDCG
        }
    }
}

