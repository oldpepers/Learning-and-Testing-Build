<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader光强与环境色
## 点光源的适配
把上一篇文章中 ForwardBase 的 Pass 复制粘贴 到 与 该Pass平行的程序块，然后再对其做之后点光源的灯光适配（因为点光源 和 聚光灯效果，是在ForwordAdd中实现的）  
把复制后的光照模式改为ForwardAdd

    Tags{“LightMode”=“ForwardAdd”}

测试代码：L_S_19_a

但是，会发现不受主平行光的影响了，所以需要进行修改

并且，由于默认的混合模式为 Blend One Zero。
渲染时，由于主平行光先渲染，点光源后渲染，所以颜色缓冲区会被后渲染的点光源覆盖。
所以修改ForwordAdd 的 Pass 中 混合模式为 Blend One One

    Blend One One

因为计算点光源时不需要考虑环境光，所以在Lambert光照模型中删除环境光的影响

在ForwardAdd的Pass中的片元着色器中，把最后的输出结果修改为如下：

    fixed4 Diffuse = LightColor * max(0,dot(N,L));

把片元着色器简化为：

            fixed4 frag (v2f i) : SV_Target
            {
                //获取主平行光的颜色
                fixed4 LightColor = _LightColor0;
                //获取顶点法线坐标(让其归一化)
                fixed3 N = normalize(i.worldNormal);
                //获取反射点指向光源的向量(因为内置了获取的方法，所以不用向量减法来计算)
                fixed3 L = _WorldSpaceLightPos0;
                //因为计算点光源时不需要考虑环境光，所以在Lambert光照模型中删除环境光的影响
                fixed4 Diffuse = LightColor * max(0,dot(N,L));

                return Diffuse;
            }
测试代码：L_S_19_b
## 不同灯光类型的支持与区分
加入聚光灯后，会发现小球只渲染了聚光灯的效果  
目前场景只支持一盏逐像素灯，在 聚光灯 和 点光源 之间，谁的强度大，谁就变成逐像素灯  
### 使用内置的宏定义生成Shader变体来区分是什么类型的光照

    #pragma multi_compile_fwdadd
    定义在LightMode=ForwardAdd的Pass中，在此Pass中用来计算其它的逐像素光照.而此指令的作用是一次性生成Unity在ForwardAdd中需要的各种内置宏.
    DIRECTIONAL DIRECTIONAL_COOKIE POINT POINT_COOKIE SPOT

        DIRECTIONAL :判断当前灯是否为平行灯.
        DIRECTIONAL_COOKIE :判断当前灯是否为Cookie平行灯.
        POINT :判断当前灯是否为点灯.
        POINT_COOKIE :判断当前灯是否为Cookie点灯.
        SPOT :判断当前灯是否为聚光灯.

在 ForwardAdd 的 Pass 中加入这条宏

    #pragma multi_compile_fwdadd

### 剔除无用的变体，节省性能

因为Shader变体的数量是一般是倍数增加，所以在设计时，就要尽量减少Shader的变体数量
Shader变体的数量，会直接影响 ShaderLab 的内存，打包到手机会影响到 Native 内存

    法一：手动声明我们需要的变体
    #pragma multi_compile POINT SPOT	

    法二：剔除不需要的变体
    #pragma skip_variants XXX01 XXX02...
    剔除指定的变体，可同时剔除多个

最终测试代码：L_S_19_d