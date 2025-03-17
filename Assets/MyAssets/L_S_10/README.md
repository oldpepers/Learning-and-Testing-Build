<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader的变体shader_feature

## 变体的类型

1、multi_compile —— 无论如何都会被编译的变体  
2、shader_feature —— 通过材质的使用情况来决定是否编译的变体

## 使用 shader_feature 来控制 shader 效果的变化
1、首先在属性面板暴露一个开关属性，用于配合shader_feature来控制shader的变体

    [Toggle]_MaskEnable(“Mask Enabled”,int) = 0

2、在CG代码中，申明 shader_feature

    //根据对应的开关 来定义用于shader变种的预编译 条件（开关名大写加_ON）
    #pragma shader_feature _MASKENABLE_ON

3、使用 预编译指令 #if 和 定义好的 shader_feature 作为条件来进行变种操作

    #if _MASKENABLE_ON
    //对遮罩贴图进行纹理采样
    fixed4 maskTex = tex2D(_MaskTex,i.uv.zw);
    col *= maskTex;
    #endif

开关的另外一种写法[MaterialToggle(NAMEENABEL)],这样写后可以直接用NAMEENABEL作为变体名

    [MaterialToggle(DISTORTENABLE)]_DistortEnable(“Distort Enabled”,int) = 0

    //使用MaterialToggle后定义shader_feature时，可以不用加_ON
    #pragma shader_feature _ DISTORTENABLE

    #if DISTORTENABLE