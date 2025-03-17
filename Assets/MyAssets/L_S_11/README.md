<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader的屏幕坐标

## 屏幕坐标

1、屏幕像素坐标 以屏幕左下角为（0,0）右上角为（屏幕最大横坐标像素，屏幕最大纵坐标像素）如为1920*1080屏幕，右上角为（1920,1080）  
2、屏幕坐标归一化坐标=当前坐标/总像素

## 在Unity中获取 当前屏幕像素 和 总像素
获取屏幕总像素,使用_ScreenParams参数

    _ScreenParams
    屏幕的相关参数，单位为像素。
    x表示屏幕的宽度
    y表示屏幕的高度
    z表示1+1/屏幕宽度
    w表示1+1/屏幕高度
获取当前片段上的像素

    UNITY_VPOS_TYPE screenPos : VPOS
    1.当前片断在屏幕上的位置(单位是像素,可除以_ScreenParams.xy来做归一化),此功能仅支持#pragma target 3.0及以上编译指令
    2.大部分平台下VPOS返回的是一个四维向量，部分平台是二维向量，所以需要用UNITY_VPOS_TYPE来统一区分.
    3.在使用VPOS时，就不能在v2f中定义SV_POSITION，这样会冲突，所以需要把顶点着色器的输入放在()的参数中，并且SV_POSITION添加out.
怎么使用:在片元着色器传入参数时使用

    fixed4 frag (v2f i,UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
    {
    }
VPOS这个类型因为在不同平台不统一，有的是 float2 有的是 float4 ，所以使用Unity提供的类型 UNITY_VPOS_TYPE，让Unity自动处理

    当使用UNITY_VPOS_TYPE screenPos : VPOS作为片元着色器的输入时，需要对顶点着色器的输入做出修改
