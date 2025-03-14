<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Unity中Shader的时间

## _Time.xyzw分别代表什么

### _Time.x
表示场景加载后经过的时间除以 20，即 t/20（t 单位为秒）。  
应用场景：适合需要缓慢变化的动画效果（如云层缓慢移动）。
### _Time.y
直接表示场景加载后经过的时间 t（秒）。  
应用场景：最常用的分量，用于大多数基于时间的动画（如水流、UV 偏移）。
### _Time.z
表示时间 t 乘以 2，即 t*2。  
应用场景：需要快速变化的效果（如高频闪烁）。
### _Time.w
表示时间 t 乘以 3，即 t*3。  
应用场景：极速变化的动态效果（如快速旋转）。

## _Time怎么使用

    // 示例：使用 _Time.y 控制 UV 偏移
    float2 uv = i.uv  + _Time.y * _Speed;

    // 示例：使用 _Time.x 实现缓慢颜色渐变
    float3 color = sin(_Time.x) * _BaseColor;

单位统一性：所有分量均以秒为单位，但通过倍数调整可实现不同速率的变化。  
性能优化：对 _Time.y 的操作建议在顶点着色器中进行，避免在片元着色器中逐像素计算。  
与其他时间变量对比：  
_SinTime/_CosTime：存储时间 t 的正弦/余弦值，用于周期性动画。  
unity_DeltaTime：存储帧时间增量（如 dt 和 1/dt），用于物理模拟。  
通过灵活选择 _Time.xyzw 分量，开发者可以高效控制 Shader 的动态效果，同时平衡性能与视觉表现。
