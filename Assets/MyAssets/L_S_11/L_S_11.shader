Shader "MyShader/L_S_11"
{
    SubShader
    {
        
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
                
                float2 screenUV = screenPos.xy / _ScreenParams.xy;
                return fixed4(screenUV,0,0);
            }
            ENDCG
        }
    }
}



