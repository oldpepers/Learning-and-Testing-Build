<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# 消融视觉效果优化smoothstep(min,max,x)
## 在clip(value) 的 基础上 用 smoothstep(min,max,x)，并且增加一个渐变纹理对消融边缘进行视觉上的优化

在用噪音纹理 对 渐变纹理进行采样，让噪音纹理中黑色的地方对应 渐变纹理 黑色的地方，以实现边缘渐变的效果，在取样后 与 原本的纹理 取样的结果相加就可以

## 优化思路 
原始案例L_S_03_2_a
smoothstep函数包含的功能 

    float smoothstep(min,max,x)
    {
    //归一化（线性插值）
    float t = saturate(x - min) / （max - min);
    //平滑
    return t * t * (3 - 2 * t);
    }

t 函数是 没处理平滑前
f 函数是 处理平滑后
因为我们目前不需要平滑处理，直接用 smoothstep 比较消耗性能，所以需要优化  
修改后案例L_S_03_2_b  
最后优化：

    因为 在使用渐变纹理时，只使用了 渐变纹理的 u 坐标，所以把 sampler2D 换为 sampler

修改以下两处

    sampler2D _RampTex; -->sampler _RampTex;

    fixed4 rampTex = tex2D(_RampTex,dissolveValue); -->fixed4 rampTex = tex1D(_RampTex,dissolveValue.r);
