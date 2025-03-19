<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader抓取屏幕并实现扭曲效果

## 实现抓取后的屏幕扭曲
实现思路：
1、屏幕扭曲要借助传入 UV 贴图进行扭曲
2、传入贴图后在顶点着色器的输入参数处，传入一个 float2 uv : TEXCOORD，用于之后对扭曲贴图进行采样
3、最后在片元着色器阶段使用lerp(screenUV,distortTex,_Distort);进行线性插值对扭曲程度进行控制

代码实现：
L_S_13_a

## 在扭曲的效果上实现流动效果
实现思路：

    在顶点着色器处，使用扭曲贴图的Tiling 及 offset 后与_Time相乘即可，流动速度，暴露两个float变量控制流速即可

代码实现：
L_S_13_b

## 为了节省性能，把_Distort 、_SpeedX 和 _SpeedY三个变量用一个四维变量存储

优化后：
L_S_13_c

## 继续进行优化

### 在之前顶点着色器的输入中，放弃了使用结构体传入，而是直接从应用程序阶段传入参数，这样写的话，对于程序来说，不方便扩张，所以需要对其进行修改实现
1、定义结构体用于传入顶点坐标系

    struct appdata
    {
    float4 vertex : POSITION;
    //从应用程序阶段的输入，多加一个uv，用于对扭曲纹理的采样
    float2 uv : TEXCOORD;
    };

2、因为UnityObjectToClipPos是从本地空间转换到裁剪空间，但是没有进行透视除法，所以需要对其进行透视除法，用转化后的结果的 xyz / w 就可以进行透视除法

    v2f vert (appdata v)
    {
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv,_DistortTex) + _Distort.xy * _Time.y;
    //把本地空间转化到其次裁剪空间后的结果,进行透视除法后, 传给 screenUV
    o.screenUV.xyz = o.pos.xyz / o.pos.w;
    return o;
    }

3、因为屏幕坐标的原点一般在左上角（DirectX） 或 左下角（OpenGL） （我的是DirectX平台，所以在左上角。），会造成显示的位置，和我们需要的位置不同，所以需要对其进行计算平移缩放处理



    DirectX平台:fixed2 uv = fixed2(i.screenUV.x * 0.5,i.screenUV.y * -0.5) + 0.5;
    OpenGL平台:fixed2 uv = i.screenUV * 0.5 + 0.5;

改到顶点着色器中计算

    DirectX平台:
    o.screenUV.x = o.screenUV.x * 0.5 + 0.5;
    o.screenUV.y = o.screenUV.y * -0.5 + 0.5;
    OpenGL平台:
    o.screenUV.x = o.screenUV * 0.5 + 0.5;



但是这样是插值计算的会有误差瑕疵，所以还是改在片元着色器中计算

    DirectX平台:
    fixed2 uv = i.screenUV.xy / i.screenUV.w;
    uv.x = uv.x * 0.5 +0.5;
    uv.y = uv.y * -0.5 + 0.5;
### 改用Unity内置提供的方法（平台间互通）

    ComputeScreenPos(float4 pos)
    pos为裁剪空间下的坐标位置，返回的是某个投影点下的屏幕坐标位置
    由于这个函数返回的坐标值并未除以齐次坐标，所以如果直接使用函数的返回值的话，需要使用：tex2Dproj(_ScreenTexture, uv.xyw);
    也可以自己处理其次坐标,使用：tex2D(_ScreenTexture, uv.xy / uv.w);

在顶点着色器：o.screenUV = ComputeScreenPos(o.pos);  
在片元着色器：fixed4 grabTex = tex2Dproj(_GrabTex,i.screenUV);
## 一个最简化的思路
在之前写的shader中，用于对屏幕坐标取样的pos是在顶点着色器中完成计算的，然而还有一种更为简洁的方法，就是用顶点着色器中传给片元着色器的pos来给屏幕抓取进行采样
原理：在顶点着色器中，o.pos是裁剪坐标，若不对其做出处理直接传到片元着色器中，则在片元着色器中，传入的i.pos就是屏幕坐标。

    //使用传入片元着色器的 pos 来计算得到，用于给抓取的屏幕采样的变量
    fixed2 screenUV = i.pos.xy / _ScreenParams.xy;
代码实现：
L_S_13_e