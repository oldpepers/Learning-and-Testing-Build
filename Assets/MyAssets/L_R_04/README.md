<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# 前向渲染路径ForwardRenderingPath

## 一、前向渲染路径的特点

    一个物体在受到多个灯光影响时，可能会产生一个或者多个Pass，具体取决于多个因素!

    注意：前向渲染路径的消耗是和实时光的数量成正比的，所以在使用前向渲染路径时，一定要控制实时光的数量。

## 二、渲染方式

    前向渲染路径同时包含了：延迟渲染路径的中的 逐像素渲染 和 顶点照明渲染路径中的 逐顶点渲染

1、逐像素(效果最好)
2、逐顶点(效果次之)
3、SH球谐(效果最差)
## 三、Unity中对灯光设置 后，自动选择对应的渲染方式
1、如果一个灯被标记为 NotImportant，则这个灯会采用逐顶点或者SH。
2、最亮的一盏平行灯采用逐像素渲染方式（如果没被主动标记为NotImportant）
3、被标记为Important的灯采用逐像素光照（一般Unity默认的是Auto）
4、如果上面产生逐像素的灯数量小于工程中的像素灯数量的话，则会有更多的灯采用逐像素

ForwardBase 逐像素 逐顶点 SH球谐  
ForwardAdd 逐像素  
### 1、ForwardBase仅用于一个逐像素的平行灯，以及所有的逐顶点与SH

如果场景中有 一个逐像素的平行灯，则需要在ForwardBase这个Pass中实现：这个逐像素的效果，还有所有的逐顶点效果以及所有的SH球谐效果
### 2、ForwardAdd用于其他所有的逐像素灯
## 、在Unity看一下像素灯的设置
1、在默认情况下，即使项目设置中像素灯的数量为0，Unity也会默认把场景中最亮的一盏平行灯作为作为逐像素灯
2、在设置中，把逐像素灯设置为0后，点光源就变成逐顶点光照了  
当把像素灯设置为1个后，可以看见这个点光源的渲染分成了两个部分  

    一个物体上最多只会受4个逐顶点光照的影响，所以当灯源大于4个时，多余的逐顶点光照会不渲染。选择的规则，优先渲染靠近物体中心的顶点光照。
    聚光灯也和点光源一样
# 光照模型Lambert 
## 公式
Diffuse=Ambient+Kd*LightColor+dot(N,L)  
Diffuse:最终物体上的漫反射光强  
Ambient：环境光强度，为了简化设计，环境光强采用一个常数表示  
Kd：物体材质对光的反射系数  
LightColor：光源的颜色光枪  
N：顶点的单位发现  
L：顶点只想光源的单位向量  


A：可以理解为环境光的颜色  
K：反射系数  
LC：主要的入射光的颜色  
N：当前顶点的法向量  
L：顶点指向光源的单位向量  
这个公式中，最主要的就是点积部分