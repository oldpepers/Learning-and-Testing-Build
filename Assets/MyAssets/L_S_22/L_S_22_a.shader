Shader "MyShader/L_S_22_a"
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
        //是否开启深度写入
        [Enum(Off,0,On,1)]_ZWrite("ZWrite",int) = 0
        

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
        //用一个开关来控制 shader 的变种，即效果就是控制 遮罩效果的是否生效
        [Toggle]_MaskEnable("Mask Enabled",int) = 0
        //流动贴图
        _MaskTex("MaskTex",2D) = "white"{}
        //流动贴图 X 轴上的移动速度
        _MaskUVSpeedX("MaskUVSpeed X",float) = 0
        //流动贴图 Y　轴上的移动速度
        _MaskUVSpeedY("MaskUVSpeed Y",float) = 0

        [Header(Distort)]
        //用一个开关来控制 UV 扭曲 shader 的变种
        [MaterialToggle(DISTORTENABLE)]_DistortEnable("Distort Enabled",int) = 0
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
        
        ZWrite [_ZWrite]
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //根据对应的开关 来定义用于shader变种的预编译 条件（属性名大写加_ON）
            #pragma shader_feature _ _MASKENABLE_ON
            //使用MaterialToggle后定义shader_feature时，可以不用加_ON 
            #pragma shader_feature _ DISTORTENABLE
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

                #if _MASKENABLE_ON
                    //这个保存遮罩贴图的信息 (为了也实现流动，和 上面使用一样的方法)
                    o.uv.zw = TRANSFORM_TEX(v.uv,_MaskTex) + float2(_MaskUVSpeedX,_MainUVSpeedY) * _Time.y;
                #endif

                #if DISTORTENABLE
                    //这个保存纹理扭曲的贴图信息
                    o.uv2 = TRANSFORM_TEX(v.uv,_DistortTex) + float2(_DistortUVSpeedX,_DistortUVSpeedY) * _Time.y;
                #endif
                

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                //一般使用 * 来颜色混合
                col = _Color * _Intensity;

                float2 distort = tex2D(_DistortTex,i.uv.xy);

                #if DISTORTENABLE
                    //先对扭曲纹理进行采样
                    fixed4 distortTex = tex2D(_DistortTex,i.uv2);
                    //使用lerp (A,B,alpha)函数进行线性插值
                    distort = lerp(i.uv.xy,distortTex,_Distort);
                    //再用采样后的结果，给主要纹理采样，实现扭曲效果
                #endif

                fixed4 mainTex = tex2D(_MainTex, distort);
                col *= mainTex;
              
                #if _MASKENABLE_ON
                    //对遮罩贴图进行纹理采样
                    fixed4 maskTex = tex2D(_MaskTex,i.uv.zw);
                    col *= maskTex;
                #endif

                
                //最后 返回 遮罩 和 原结果相乘的结果
                return col;

            }
            ENDCG
        }
    }
}
