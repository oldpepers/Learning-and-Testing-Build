<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Unity中Shader的面剔除Cull

## Shader的面

    使用 Cull Off | Back | Front

Cull Off : 关闭剔除，正反面都渲染  
Cull Back：剔除背面  
Cull Front：剔除正面

默认的Cull是：Cull Back，剔除背面

Cull语句可以写在 SubShader 或 Pass 语句块中

## 暴露一个属性来控制

    //暴露属性来控制 剔除哪里
    [Enum(UnityEngine.Rendering.CullMode)]
    _Cull(“Cull”,int) = 1

## 如何区分正反面

    点到面的环绕方式决定了法线方向
    法线所指的方向，就是面的正方向
    右手逆时针为正
    右手顺时针为负