<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# clip方法的使用
片段的取舍一般用 clip(value) 函数

value > 0 保留  
value < 0 舍弃

# 简单实现消融的逻辑
1、使用 2D 类型接受一个噪音材质属性_DissolveTex  
2、使用一个属性 _Value 限制范围在 （0，1）之间，然后用外部传入的噪音材质属性的rgb中随便取一个来减去_Value,以实现随机消融的效果