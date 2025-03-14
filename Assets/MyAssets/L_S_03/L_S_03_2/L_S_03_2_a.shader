Shader "MyShader/L_S_03_2_a"
{
    Properties
    {
        //使用这个标签，可以使外部暴露属性，有标题
        [Header(Base)]
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _Clip("Clip",Range(0,1)) = 0

        
        //使用这个标签可以 在两行暴露属性之间加 间隙
        [Space(10)]
        [Header(Dissolve)]
        _DissolveTex("DissolveTex",2D) = "white"{}

        [NoScaleOffset]_RampTex("RampTex",2D) = "black" {}

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
            float _Clip;
            sampler2D _DissolveTex; 
           

            //这个四维向量，xyzw分别表示 Tilling 和 Offset 的 xy ,命名方式 在纹理名 后加 _ST
            float4 _DissolveTex_ST;

            sampler2D _RampTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            
            

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                //为了减少传入的值 ，所以就不创建新变量来存储，而是把 uv 改为  四维向量 来用
                //使用 o.uv 的 xy 来存放 原人物贴图
                //使用 o.uv 的 zw 来存放 噪波贴图缩放 和 偏移 后的值
                o.uv.xy = v.uv.xy;
                //o.uv.zw = v.uv * _DissolveTex_ST.xy + _DissolveTex_ST.zw;

                o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;

                fixed4 _mainTex = tex2D(_MainTex, i.uv.xy);
                col = _mainTex;
               
                //外部获取的 纹理 ，使用前都需要采样
                fixed4 dissolveTex = tex2D(_DissolveTex,i.uv.zw);
                //片段的取舍
                clip(dissolveTex.r -  _Clip);

                //进行视觉上的优化
                //smoothstep(min,max,x)
                //x < min ,y = min;
                //x > max ,y = max;
                //min < x < max,y = x;
                fixed4 rampTex = tex2D(_RampTex,smoothstep(_Clip,_Clip + 0.1,dissolveTex.r));
                col += rampTex;
                return col;
            }
            ENDCG
        }
    }
}

