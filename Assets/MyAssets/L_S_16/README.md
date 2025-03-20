<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Unity中Shader的模板测试

## 什么是模板测试
### 模板缓冲区
帧缓存包含  
深度缓冲区（Depth Buffer）  
颜色缓冲区（Color Buffer）  
模板缓冲区（Stencil Buffer）  
自定义缓冲区
### 模板缓冲区中存储的值

    8bit = 2^8 = 256 = 0 ~ 255
### 模板测试是什么（看完以下流程就能知道模板测试是什么）
模板测试就是在渲染，后渲染的物体前，与渲染前的模板缓冲区的值进行比较，选出符合条件的部分，对后渲染的物体进行渲染

在没渲染物体时，模板缓冲区中的默认值为0  
图：01  
现在，我们在屏幕范围内渲染一个绿色的长方形  
图：02  
然后，如下图继续渲染一个红色的长方形  
图：03  
使用模板测试后，就可以实现很多独特的效果
例1：（当渲染红色物体前，如果之前的模板缓冲区值为1，才渲染对应区域的红色物体）  
图：04  
例2：（当渲染红色物体前，如果之前的模板缓冲区值为1，则不渲染对应区域的红色物体）  
图：05
## Unity中Shader实现模板测试Stencil
组件中的Mask  
Mask 和 Rect Mask 2D 是UI中的Mask  
Sprite Mask 是精灵中的Mask
### UI中的遮罩
1、Mask ——> 模板测试  
2、RectMask2D ——> UNITY_UI_CLIP_RECT
### 模板缓冲区Stencil一般是和Pass平行的部分，Pass部分写的是颜色缓冲区
Stencil:

    模板缓冲区(StencilBuffer)可以为屏幕上的每个像素点保存一个无符号整数值,这个值的具体意义视程序的具体应用而定.在渲染的过程中,可以用这个值与一个预先设定的参考值相比较,根据比较的结果来决定是否更新相应的像素点的颜色值.这个比较的过程被称为模板测试.
    将StencilBuffer的值与ReadMask与运算，然后与Ref值进行Comp比较，结果为true时进行Pass操作，否则进行Fail操作，操作值写入StencilBuffer前先与WriteMask与运算.

    模版缓冲中的默认值为:0
    公式：(Ref & ReadMask) Comp (StencilBufferValue & ReadMask)
    一般读取掩码ReadMask都是默认的，不做修改
    Stencil
    {
    Ref [_Stencil]
    ReadMask [_StencilReadMask]
    WriteMask [_StencilWriteMask]
    Comp [_StencilComp] ((UnityEngine.Rendering.CompareFunction))
    Pass [_StencilOp] (UnityEngine.Rendering.StencilOp)
    Fail [_Fail]
    ZFail [_ZFail]
    }

    Ref: 设定的参考值,这个值将用来与模板缓冲中的值进行比较.取值范围位为0-255的整数.
    ReadMask: ReadMask的值将和Ref的值以及模板缓冲中的值进行按位与（&）操作,取值范围也是0-255的整数,默认值为255(二进制位11111111),即读取的时候不对Ref的值和模板缓冲中的值产生修改,读取的还是原始值.
    WriteMask: WriteMask的值是当写入模板缓冲时进行的按位与操作,取值范围是0-255的整数,默认值也是255,即不做任何修改.
    Comp: 定义Ref与模板缓冲中的值比较的操作函数,默认值为always.
    Pass: 当模板测试（和深度测试）通过时,则根据（stencilOperation值）对模板缓冲值进行处理,默认值为keep.
    Fail: 当模板测试（和深度测试）失败时,则根据（stencilOperation值）对模板缓冲值进行处理，默认值为keep.
    ZFail: 当模板测试通过而深度测试失败时,则根据（stencilOperation值）对模板缓冲值进行处理，默认值为keep
Comp（比较操作）

    Less： 相当于“<”操作，即仅当左边<右边，模板测试通过，渲染像素.
    Greater： 相当于“>”操作，即仅当左边>右边，模板测试通过，渲染像素.
    Lequal： 相当于“<=”操作，即仅当左边<=右边，模板测试通过，渲染像素.
    Gequal： 相当于“>=”操作，即仅当左边>=右边，模板测试通过，渲染像素.
    Equal： 相当于“=”操作，即仅当左边=右边，模板测试通过，渲染像素.
    NotEqual： 相当于“!=”操作，即仅当左边！=右边，模板测试通过，渲染像素.
    Always： 不管公式两边为何值，模板测试总是通过，渲染像素.
    Never: 不管公式两边为何值，模板测试总是失败 ，像素被抛弃.

Pass(模版缓冲区的更新)

    Keep： 保留当前缓冲中的内容，即stencilBufferValue不变.
    Zero： 将0写入缓冲，即stencilBufferValue值变为0.
    Replace： 将参考值写入缓冲，即将referenceValue赋值给stencilBufferValue.
    IncrSat： 将当前模板缓冲值加1，如果stencilBufferValue超过255了，那么保留为255，即不大于255.
    DecrSat： 将当前模板缓冲值减1，如果stencilBufferValue超过为0，那么保留为0，即不小于0.
    NotEqual： 相当于“!=”操作，即仅当左边！=右边，模板测试通过，渲染像素.
    Invert： 将当前模板缓冲值（stencilBufferValue）按位取反.
    IncrWrap: 当前缓冲的值加1，如果缓冲值超过255了，那么变成0，（然后继续自增）.
    DecrWrap: 当前缓冲的值减1，如果缓冲值已经为0，那么变成255，（然后继续自减）.
### 实际使用
1，在使用模板缓冲区前，需要如下图设置一个遮罩图层  
2、设置完后，在内层的Image使用的材质的Shader中添加如下代码，即可实现只在有遮罩的部分，渲染后渲染的部分  
这里的 Stencil Id:1 对应的是Shader中的 Ref 1。
Comp使用Equal，则是用模板缓冲区的值于 Ref 的值相比
Pass使用Keep，则是比较通过的值，保存缓冲区中的值  
测试代码：L_S_16_a
### 让实现的模板测试更加方便自定义
1、在属性面板暴露一个int类型,提供给 Ref 使用

    _Ref(“Stencil Ref”,int) = 0

2、在属性面板暴露一个int类型,提供给 Comp 使用，并且设置成Unity内置的几个枚举类型[Enum(UnityEngine.Rendering.CompareFunction)]

    [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp(“Stencil Comp”,int) = 0

3、在属性面板暴露一个int类型,提供给 Pass 使用，并且设置成Unity内置的几个枚举类型[Enum(UnityEngine.Rendering.StencilOp)]

    [Enum(UnityEngine.Rendering.StencilOp)]_StencilOp(“Stencil Op”,int) = 0
测试代码：L_S_16_b
## Unity中Shader模板测试使用到的二进制
### 模板测试公式
1、简化版(在ReadMask默认值的情况下)

    Ref Comp StencilBufferValue

Ref：Shader中自定义的值
StencilBufferValue：模板缓冲区中的值
比较的结果，只有通过和不通过两种结果
2、完整版

    (Ref & ReadMask) Comp (StencilBufferVallue & ReadMask)

前半部分：Shader中自定义的值 和 ReadMask 中的值进行 与运算
后半部分：模板缓冲区中的值 和 ReadMask 中的值进行 与运算
比较的结果，只有通过和不通过两种结果
### 二进制的值
1、0 和 1组成  
2、符号

    最左边的这一位一般用来表示这个数是正数 还是 负数，这样的话这个数就是有符号整数。

    如果最左边这一位不用来表示正负数，而是和后面的连在一起表示整数，那么就不能区分这个数是正还是负，就只能是正数，这就是无符号整数。
二进制和十进制转化

    https://tool.oschina.net/hexconvert


### 在Shader中的实际操作

例：(给ReadMask赋值为 3，则在Ref值为 1,5···时显示出的效果是我们想要的效果)

    Stencil
    {

    Ref [_Ref]
    //以下两个属性一般不做修改
    ReadMask 3//[_StencilReadMask]
    //WriteMask [_StencilWriteMask]
    Comp [_StencilComp]
    Pass [_StencilOp]
    //Fail [_Fail]
    //ZFail [_ZFail]
    }

模板缓冲区中的值（1） 01
ReadMask的值（3） 11
01 & 11 = 01

Ref的值(5): 101
ReadMask :011
101 & 011 = 001

当Comp使用Equal时，左右两边的值相等

