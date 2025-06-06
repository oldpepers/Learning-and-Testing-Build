<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# ui Shader相关操作

## UI Shader的基本功能
1、暴露一个 2D 类型的属性来接受UI的纹理

    //命名要按标准来，这个属性才可以和Unity组件中的属性产生关联
    //比如说，在更改 Image 的源图片时，同时更改这个
    [PerRendererData]_MainTex(“MainTex”,2D) = “white”{}

2、设置shader的层级为TransParent半透明渲染层级，一般UI都是在这个渲染层级

    //更改渲染队列（UI的渲染队列一般是半透明层的）
    Tags {“Queue” = “TransParent”}

3、更改混合模式，是 UI 使用的纹理，该透明的地方透明

    //混合模式
    Blend SrcAlpha OneMinusSrcAlpha

代码案例：
L_S_15_a
## UI组件对Shader调色

### 原理

在Shader中直接暴露的Color属性，不会与UI的Image组件中的Color形成属性绑定。因为UI的Image组件中更改的颜色是顶点颜色，如果需要在修改组件中的颜色时，使Shader中的颜色也同时改变。那么就需要在应用程序阶段传入到顶点着色器的数据增加一个变量，用于给顶点着色器使用。

### 实现
1、在结构体 appdata 中，加入一个用COLOR语义的变量，用于代表传入的顶点颜色

    //定义一个语义为Color的4维向量，用于传入顶点颜色,设置语义为COLOR后，这个变量就会与顶点颜色对应
    struct appdata
    {
    //顶点信息
    float4 vertex:POSITION;
    float2 uv : TEXCOORD;
    //这里定义一个语义为Color的4维向量，用于传入顶点颜色,设置语义为COLOR后，这个变量就会与顶点颜色对应
    fixed4 color:COLOR;
    };

2、在结构体 v2f 中，加入一个用 TEXCOORD1语义定义变量，这里的语义其实没有什么含义，主要作用是精度的不同。

    在传入到片元着色器的数据中，只有 SV_POSITION 语义是必要的，这个用于存储转化到裁剪坐标下的位置信息。

    //存储 顶点着色器输入到片元着色器的信息
    struct v2f
    {
    //裁剪空间下的位置信息（SV_POSITION是必须的）
    float4 pos:SV_POSITION;
    float2 uv : TEXCOORD;
    //这里的语义主要代表精度不同，TEXCOORD 在这里只是代表高精度，可以使用COLOR语义，代表低精度
    fixed4 color : TEXCOORD1;
    };

代码案例：
L_S_15_b
## Shader 一样根据UI层级自动适配Shader中模板测试值
代码案例：
L_S_15_c
## Shader中UI材质去色功能实现
一、实现思路
1、在属性面板暴露一个 开关 来控制去色变体  
2、声明一个变体  
3、在片元着色器实现去色  

    去色的方案
    1、只输出结果的单通道值，一般来说结果不太理想，比较节省性能
    2、使用去色公式 dot(rgb,fixed3(0.22,0.707,0.071))
    3、使用Unity封装的函数，内部使用向量的点积实现了第二步的去色 Luminance(float rgb)

二、实现
1、定义开关

    [Toggle]_GrayEnabled(“Gray Enabled”,int) = 0

2、声明变体

    //声明一个变体用于控制UI去色,因为需要由程序动态修改，所以使用变体 multi_compile
    //宏的定义规则，_开关名大写_ON
    #pragma multi_compile _ _GRAYENABLED_ON

3、在片元着色器中，使用宏判断是否去色
法1、只输出结果的单通道值，一般来说结果不太理想，比较节省性能

    col.rgb = col.r;
    col.rgb = col.g;
    col.rgb = col.b;
法2、使用去色公式 dot(rgb,fixed3(0.22,0.707,0.071))

    col.rgb = col.r * 0.22 + col.g * 0.707 + col.b * 0.071;
法3、利用内置官方函数去色 Luminance(float rgb)

    col.rgb = Luminance(col);

代码实现：L_S_15_d