<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Tilling（缩放度）和Offset（偏移度）

### Tilling（缩放度）

控制纹理在单位UV空间内的重复次数，数值越大纹理密度越高。例如Tilling(2,2)表示UV空间内水平和垂直方向各重复两次16。
效果类似于调整周期函数的周期长度，通过缩小纹理的显示范围实现重复平铺。  
### Offset（偏移度）

平移纹理坐标，改变纹理起始采样位置。例如Offset(0.5,0)会使纹理向右移动50%的宽度310。
本质是函数图像的平移操作，常用于动态调整贴图位置（如水流、烟雾效果）
### Shader声明方式

需定义float4 _MainTex_ST（命名规则：纹理名+_ST），其中：
.xy存储Tilling参数，.zw存储Offset参数。
使用内置宏TRANSFORM_TEX(uv, _MainTex)自动完成缩放偏移计算，等价于：
uv = uv * _MainTex_ST.xy  + _MainTex_ST.zw。  
案例 L_S_02_2_a
### 顶点着色器优化

UV变换建议在顶点着色器中进行，避免片元着色器逐像素计算带来的性能损耗  
案例 L_S_02_2_b(未曾用内置宏定义)
案例 L_S_02_2_c(使用内置宏定义)
### 属性面板联动
在材质Inspector中调整Tilling/Offset时，需确保贴图的WrapMode设为Repeat。
### 法线贴图处理
对法线贴图使用Tilling/Offset时需注意切线空间转换，避免法线方向错误。
### 精度问题
高精度需求场景（如地形）建议使用float4存储UV数据，避免精度丢失。