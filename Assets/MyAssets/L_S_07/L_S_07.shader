Shader "MyShader/L_S_07"
{
    Properties
    
    {
        _MainTex ("Texture", 2D) = "white" {}

        //暴露两个属性，分别对应 源混合类型 和 目标混合类型
        //源混合类型
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("Src Blend",int) = 0
        //目标混合类型
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend",int) = 0
        //暴露属性来控制 剔除哪里
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull",int) = 1

        //用来控制颜色混合
        _Color("Color",COLOR) = (1,1,1,1)
        //用来控制亮度
        _Intensity("Intensity",Range(-4,4)) = 1
        
        //控制 X 轴的移动速度
        _MainUVSpeedX("MainUVSpeed X",float) = 0
        //控制 Y 轴的移动速度
        _MainUVSpeedY("MainUVSpeed Y",float) = 0
    }
    SubShader
    {
        Tags{"Queue" = "Transparent"}

        //混合
        Blend [_SrcBlend][_DstBlend]
        
        Cull [_Cull]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            half _Intensity;
            float _MainUVSpeedX,_MainUVSpeedY;


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
                //用于存储 Tilling 和 Offset 后的结果
                o.uv = TRANSFORM_TEX(v.uv, _MainTex) + float2(_MainUVSpeedX,_MainUVSpeedY) * _Time.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 col = tex2D(_MainTex, i.uv);
                //一般使用 * 来颜色混合
                col *= _Color * _Intensity;
                return col;
            }
            ENDCG
        }
    }
}

