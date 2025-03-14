<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Unity中Shader的混合模式

## 混合操作

片断着色器 》写入时进行Blend操作》 Frame Buffer帧缓冲区  
源颜色*SrcFactor BlendOP DstFactor * 目标颜色  
之前代码中写的 Blend one one  
第一个 one 代表源颜色
第二个 one 代表目标颜色  
BlendOP默认是 + （Add）

混合因子

    One：源或目标的完整值
    Zero：0
    SrcColor：源的颜色值
    SrcAlpha：源的Alpha值
    DstColor：目标的颜色值
    DstAlpha：目标的Alpha值
    OneMinusSrcColor：1-源颜色得到的值
    OneMinusSrcAlpha：1-源Alpha得到的值
    OneMinusDstColor：1-目标颜色得到的值
    OneMinusDstAlpha：1-目标Alpha得到的值

常用的几种混合类型

    Blend SrcAlpha OneMinusSrcAlpha// Traditional transparency
    Blend One OneMinusSrcAlpha// Premultiplied transparency
    Blend One One
    Blend OneMinusDstColor One // Soft Additive
    Blend DstColor Zero // Multiplicative
    Blend DstColor SrcColor // 2x Multiplicative

常用的混合操作符有：  
Add：源+目标  
Sub：源-目标  
RevSub：目标-源  
Min：源与目标中最小值  
Max：源与目标中最大值
## 在 Shader 中暴露两个属性 来调节 混合的效果

    暴露的两个属性分别代表：源混合模式 和 目标混合模式
    //源混合类型
    [Enum(UnityEngine.Rendering.BlendMode)]
    _SrcBlend(“Src Blend”,int) = 0
    //目标混合类型
    [Enum(UnityEngine.Rendering.BlendMode)]
    _DstBlend(“DstBlend”,int) = 0