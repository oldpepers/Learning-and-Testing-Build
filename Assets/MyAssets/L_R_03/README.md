<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# 渲染路径RenderingPath

## 一、什么是渲染路径

    为进行光照计算而设计的渲染方式
## 二、渲染路径有哪些
 1，前向渲染路径（Forward Rendering Path）  
 2，延迟渲染路径（Deferred Rendering Path）  
 3，顶点照明渲染路径（Vertex Lit Rendering Path,Legacy）  
 4,旧的延迟渲染路径（Deferred Rendering Path，Legacy）  
### 1、前向渲染路径

    Unity中默认的渲染路径

### 2、延迟渲染路径

    高保真的渲染光照效果
原理  
几何处理G-Buffer Pass  
RT0 RT1 RT2 RT3 RT4 (Depth+Stencil Buffer) >G-Buffer > 光照处理LightingPass  
光照处理Lighting Pass
只需要渲染出一个屏幕大小的二维矩形，使用第一步在G-buffer中存储的数据对此矩阵的每一个片段进行计算光照  
优点  
1，影响一个物体的光源数量是没有限制的  
2，每一个光源都是逐像素级别的效果，并且可以正确的计算法线贴图及阴影  
缺点  
1，不支持半透明效果  
2，不支持抗锯齿  
3，内存开销较大  
4，不支持正交相机  
支持条件  
1，显卡必须支持 multiple render targets（MRT），既多渲染目标  
2，ShaderModel在3.0及以上  
3，手机平台在OpenGl3.0及以上  
### 3、顶点照明渲染路径(已过时)
早起为了兼容各种设备，使用的一种高性能，效果差的渲染路径  
优点  
1，性能最优  
2，支持的硬件最广  
3，一个物体仅渲染一次，并且所有的光照计算都在顶点执行  
缺点 
不支持像素级别的效果，比如阴影、高质量高光等  
### 4、旧的渲染路径（已过时）
# Shader中的渲染路径LightMode
## 一、在Shader中如何区分不同的渲染路径
### 1、Pass Tag
Always:默认设置，任何情况下都会渲染，没有灯光信息  
ForwardBase：前向渲染中的基础Pass  
ForwardAdd：前向渲染中的额外Pass  
Deferred：延迟渲染  
ShadowCaster：渲染对象的shadowmap或者depthTexture  
MotionVectors：用于计算物体的MotonVectors  
PrepassBase：用于旧的延迟渲染
PrepassFinal:用于旧的延迟渲染  
Vertex：用于顶点光照渲染（当物体没有光照贴图时）  
VertexLMRGBM：用于顶点光照渲染（PC与筑基平台下，当物体有光照贴图时）  
VertexLM:用于顶点光照渲染（手机平台下，当物体有光照贴图时）
### 2、LightMode的不同类型
Always:默认设置，任何情况下都会渲染，没有灯光信息  
ForwardBase：前向渲染中的基础Pass  
ForwardAdd：前向渲染中的额外Pass  
Deferred：延迟渲染  
ShadowCaster：渲染对象的shadowmap或者depthTexture  
MotionVectors：用于计算物体的MotionVectors  
PrepassBase：用于旧的延迟渲染  
PrepassFinal:用于旧的延迟渲染  
Vertex：用于顶点光照渲染（当物体没有光照贴图时）  
VertexLMRGBM：用于顶点光照渲染（PC与筑基平台下，当物体有光照贴图时）  
VertexLM:用于顶点光照渲染（手机平台下，当物体有光照贴图时）