
Shader "MyShader/L_S_09"
{
    Properties
    
    {
        [Header(RenderingMode)]
        //暴露两个属性，分别对应 源混合类型 和 目标混合类型
        //源混合类型
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("Src Blend",int) = 0
        //目标混合类型
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend",int) = 0
        //暴露属性来控制 剔除哪里
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull",int) = 1

        [Header(Base)]
        //用来控制颜色混合
        _Color("Color",COLOR) = (1,1,1,1)
        //用来控制亮度
        _Intensity("Intensity",Range(-4,4)) = 1
        //主纹理
        _MainTex ("Texture", 2D) = "white" {}
        //控制 X 轴的移动速度
        _MainUVSpeedX("MainUVSpeed X",float) = 0
        //控制 Y 轴的移动速度
        _MainUVSpeedY("MainUVSpeed Y",float) = 0
        
        [Header(Mask)]
        //流动贴图
        _MaskTex("MaskTex",2D) = "white"{}
        //流动贴图 X 轴上的移动速度
        _MaskUVSpeedX("MaskUVSpeed X",float) = 0
        //流动贴图 Y　轴上的移动速度
        _MaskUVSpeedY("MaskUVSpeed Y",float) = 0

        [Header(Distort)]
        _DistortTex("DistortTex",2D) = "white"{}
        _Distort("Distort",Range(0,1)) = 0
        _DistortUVSpeedX("DistortUVSpeed X",float) = 0
        _DistortUVSpeedY("DistortUVSpeed Y",float) = 0

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
            
            sampler2D _MainTex;float4 _MainTex_ST;
            
            fixed4 _Color;
            half _Intensity;
            float _MainUVSpeedX,_MainUVSpeedY;

            sampler2D _MaskTex;float4 _MaskTex_ST;
            float _MaskUVSpeedX,_MaskUVSpeedY;

            sampler2D _DistortTex;float4 _DistortTex_ST;
            float _Distort;
            float _DistortUVSpeedX,_DistortUVSpeedY;
            struct appdata
            {
                //为了节省空间，使用 把两个 float2 合并为一个 float4
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                //这个存储纹理扭曲的信息
                float2 uv2 : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //这个保存主纹理的信息
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + float2(_MainUVSpeedX,_MainUVSpeedY) * _Time.y;
                //这个保存遮罩贴图的信息 (为了也实现流动，和 上面使用一样的方法)
                o.uv.zw = TRANSFORM_TEX(v.uv,_MaskTex) + float2(_MaskUVSpeedX,_MainUVSpeedY) * _Time.y;
                //这个保存纹理扭曲的贴图信息
                o.uv2 = TRANSFORM_TEX(v.uv,_DistortTex) + float2(_DistortUVSpeedX,_DistortUVSpeedY) * _Time.y;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //先对扭曲纹理进行采样
                fixed4 distortTex = tex2D(_DistortTex,i.uv2);
                //使用lerp (A,B,alpha)函数进行线性插值
                float2 distort = lerp(i.uv.xy,distortTex,_Distort);
                //再用采样后的结果，给主要纹理采样，实现扭曲效果
                fixed4 col = tex2D(_MainTex, distort);
                //一般使用 * 来颜色混合
                col *= _Color * _Intensity;

                //对遮罩贴图进行纹理采样
                fixed4 maskTex = tex2D(_MaskTex,i.uv.zw);
              
                //最后 返回 遮罩 和 原结果相乘的结果
                return col * maskTex;
            }
            ENDCG
        }
    }
}
