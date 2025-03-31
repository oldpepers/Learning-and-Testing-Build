Shader "MyShader/P1_6_5"
{
    Properties
    {
        [Enum(Off,0,On,1)]_ZWrite("ZWrite",int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest",int) = 0
        //使用这个标签，可以使外部暴露属性，有标题
        [Header(Base)]
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _Clip("Clip",Range(0,1)) = 0
        //使用这个标签可以 在两行暴露属性之间加 间隙
        [Space(10)]
        [Header(Dissolve)]
        _DissolveTex("DissolveTex",2D) = "black"{}

        [NoScaleOffset]_RampTex("RampTex(RGB)",2D) = "black" {}
        
    }
    SubShader
    {
        Tags{"Queue" = "Geometry"}
        Blend Off
        Cull Back
        /*ZWrite [_ZWrite]
        
        ZTest [_ZTest]*/
        
        UsePass "MyShader/L_S_23_b/XRay"
        
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


            //因为 在使用渐变纹理时，只使用了 渐变纹理的 u 坐标，所以把  sampler2D 换为 sampler
            sampler _RampTex;

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
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                //外部获取的 纹理 ，使用前都需要采样
                fixed4 dissolveTex = tex2D(_DissolveTex,i.uv.zw);
                
                //片段的取舍
                clip(dissolveTex.r -  _Clip);

                //进行归一化
                fixed4 dissolveValue = saturate((dissolveTex.r - _Clip) / (_Clip + 0.1 - _Clip));

                fixed4 rampTex = tex1D(_RampTex,dissolveValue.r);

                //col += rampTex;
                return col;
            }
            ENDCG
        }
    }
}



