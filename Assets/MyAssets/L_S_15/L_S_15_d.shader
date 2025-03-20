Shader"MyShader/L_S_15_d"
{
    Properties
    {
        //命名要按标准来，这个属性才可以和Unity组件中的属性产生关联
        //比如说，在更改 Image 的源图片时，同时更改这个
        [PerRendererData]_MainTex("MainTex",2D) = "white"{}
        _StencilComp ("Stencil Comparison", Float) = 8.000000
        _Stencil ("Stencil ID", Float) = 0.000000
        _StencilOp ("Stencil Operation", Float) = 0.000000
        _StencilWriteMask ("Stencil Write Mask", Float) = 255.000000
        _StencilReadMask ("Stencil Read Mask", Float) = 255.000000
        _ColorMask ("Color Mask", Float) = 15.000000
        
        [Toggle]_GrayEnabled("Gray Enabled",int) = 0
    }
    
    SubShader
    {
        //更改渲染队列（UI的渲染队列一般是半透明层的）
        Tags {"Queue" = "TransParent"}
        //混合模式
        Blend SrcAlpha OneMinusSrcAlpha
        
        ColorMask [_ColorMask]
        
        Stencil
        {
            Ref [_Stencil]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
            Comp [_StencilComp]
            Pass [_StencilOp]
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex  vert
            #pragma fragment frag
            //声明一个变体，用于RectMask使用
            #pragma multi_compile _ UNITY_UI_CLIP_RECT
            //声明一个变体用于控制UI去色,因为需要由程序动态修改，所以使用变体 multi_compile
            //宏的定义规则，_开关名大写_ON
            #pragma multi_compile _ _GRAYENABLED_ON
            
            #include <UnityUI.cginc>

            #include "UnityCG.cginc"
            //存储 应用程序输入到顶点着色器的信息
            struct appdata
            {
                //顶点信息
                float4 vertex:POSITION;
                float2 uv : TEXCOORD;
                //这里定义一个语义为Color的4维向量，用于传入顶点颜色,设置语义为COLOR后，这个变量就会与顶点颜色对应
                fixed4 color:COLOR;
            };
            //存储 顶点着色器输入到片元着色器的信息
            struct v2f
            {
                //裁剪空间下的位置信息（SV_POSITION是必须的）
                float4 pos:SV_POSITION;
                float2 uv : TEXCOORD;
                //这里的语义主要代表精度不同，TEXCOORD 在这里只是代表高精度
                fixed4 color : COLOR;
                //定义一个四维变量存储顶点信息
                float4 vertex : TEXCOORD1;
            };
            
            sampler2D _MainTex;
            fixed4 _Color;
            //在使用 RectMask 需要使用的变体时，需要声明一个四维变量 _ClipRect
            float4 _ClipRect;
            
            
            v2f vert(appdata v)
            {
                v2f o;
                //把顶点信息转化到裁剪坐标下
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                o.vertex = v.vertex;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                float value = 0;
                #if UNITY_UI_CLIP_RECT
                    //法1、使用if有助于理解
                    /*if(_ClipRect.x < i.vertex.x && _ClipRect.z > i.vertex.x && _ClipRect.y < i.vertex.y && _ClipRect.w > i.vertex.y)
                    {
                        return 1;
                    }
                    else
                    {
                        return 0;
                    }*/
                    //法2、利用step来优化if
                    //value =  step(_ClipRect.x,i.vertex.x) * step(i.vertex.x,_ClipRect.z) * step(_ClipRect.y,i.vertex.y) * step(i.vertex.y,_ClipRect.w);
                    //法3、使用step进行向量比较，减少step的使用数量
                    /*fixed2 rect = step(_ClipRect.xy,i.vertex.xy) * step(i.vertex.xy,_ClipRect.zw);
                    value = rect.x * rect.y;*/
                    //法4、利用Unity自带函数实现
                    value = UnityGet2DClipping(i.vertex,_ClipRect);
                #else
                    return 0.5;
                #endif
                
                fixed4 mainTex = tex2D(_MainTex,i.uv);

                fixed4 col = mainTex * i.color * value * mainTex.a;
                
                #if _GRAYENABLED_ON
                //法1、使用结果的单一的颜色通道输出（效果差，性能好）
                //col.rgb = col.b;
                //法2、使用去色公式去色 dot(rgb,fixed3(0.22,0.707,0.071))
                //col.rgb = col.r * 0.22 + col.g * 0.707 + col.b * 0.071;
                //法3、使用Unity封装的函数去色（内部实现使用了法二的去色公式，不过使用了向量的点积实现的）
                col.rgb = Luminance(col);
                //法4、
                #endif
                
                
                return  col;
            }
            
            ENDCG
        }
    }
}
