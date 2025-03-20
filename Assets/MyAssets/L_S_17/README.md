<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader遮罩RectMask2D
## 需要定义一个变体UNITY_UI_CLIP_RECT
UNITY_UI_CLIP_RECT

    当父级物体有Rect Mask 2D组件时激活.
    需要先手动定义此变体#pragma multi_compile _ UNITY_UI_CLIP_RECT
    同时需要声明：_ClipRect(一个四维向量，四个分量分别表示RectMask2D的左下角点的xy坐标与右上角点的xy坐标.)
    UnityGet2DClipping (float2 position, float4 clipRect)即可实现遮罩.

    //声明一个变体，用于RectMask使用
    #pragma multi_compile _ UNITY_UI_CLIP_RECT

注意： 上面的 _ 前后均有空格

    在片元着色器使用以下代码测试看看基本功能
    #if UNITY_UI_CLIP_RECT
    return 1;
    #else
    return 0.5;
    #endif
测试代码：L_S_17_a
## 需要申明一个_ClipRect,这是使用上面这个变体需要使用的，这个属性并没有在Properties声明

    同时需要声明：_ClipRect(一个四维向量，四个分量分别表示RectMask2D的左下角点的xy坐标与右上角点的xy坐标.)
这个坐标是用来存储RectMask所占的位置信息    
因为UI是一个矩形，所以记录了 左下角 和 右上角 顶点信息 后就可以知道 RectMask所占的位置  

注意：在UGUI中模型顶点的本地坐标，经过顶点着色器传入片段着色器会转化为屏幕坐标（即看见的坐标值很大不是UI模型的本地坐标，而是UI模型的屏幕坐标）
### 现在我们用简单的代码测试一下 _ClipRect 的使用

    主要逻辑：
    1、在应用程序阶段传入顶点着色器的结构体中 加入 顶点信息
    2、在顶点着色着色器传入片元着色器的结构体中 加入 顶点信息
    3、在 片元着色器中，使用 _ClipRect 的坐标信息用于判断，符合条件的返回 1（半透明白） ，不符合返回 0.5（半透明灰）

测试代码：L_S_17_b 

### 然后我们基于以上的基础，让 内层UI只在 _ClipRect 范围内渲染

测试代码：L_S_17_c
因为 if 语句在 Shader 中十分消耗性能，所以要避免使用 if 语句 ，if只适合用于理解原理（三目运算符也是同理）

    我们使用Math中的 step(a,b) 函数来解决这个问题
    如果a<=b返回1,否则返回0.

    如果使用 这个 Math 方法，则可以按这样的思路设计，使用宏判断后，在宏判断中记录 step 后的值，然后最后与需要输出的颜色混合输出即可。（因为0乘任何数等于0）

    所以这里把之前的条件语句转化为了如下语句
    value = step(_ClipRect.x,i.vertex.x) * step(i.vertex.x,_ClipRect.z) * step(_ClipRect.y,i.vertex.y) * step(i.vertex.y,_ClipRect.w);

### 以上代码还可以再进一步优化，因为 step 不只可以用与点之间的比较，可以用于向量之间的比较，所以在以上代码的基础上，减少step的使用

    fixed2 rect = step(_ClipRect.xy,i.vertex.xy) * step(i.vertex.xy,_ClipRect.zw);
    value = rect.x * rect.y ;

因为我们使用的混合模式为

    Blend SrcAlpha OneMinusSrcAlpha

所以使用 纹理采样后的透明值 与输出结果相乘，即可让透明部分透明

    return mainTex * i.color * value * mainTex.a;

### 使用 UnityGet2DClipping (float2 position, float4 clipRect)

    需要导入库：#include <UnityUI.cginc>

    value = UnityGet2DClipping(i.vertex,_ClipRect);
    //函数实现 和 法3一样

最终测试代码:L_S_17_d