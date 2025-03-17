<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Unity中Shader的屏幕抓取 GrabPass

## 抓取指令

屏幕的抓取需要使用一个Pass

    GrabPass{}

    GrabPass{“NAME”}

在使用抓取的屏幕前，需要像使用属性一样定义一下,_GrabTexture这个名字是Unity定义好的

    sampler2D _GrabTexture;

为了优化节省性能：一次抓取就存储下来渲染完，再进行下次抓取

    使用：GrabPass{“NAME”}

使用这个抓取后，对应的定义名也要换成 NAME