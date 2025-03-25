<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader的光照衰减
## 一、衰减原理
1、使用一张黑白渐变贴图用于纹理采样
2、把模型从世界坐标转化为灯光坐标（即以灯光为原点的坐标系）
3、用转化后的模型坐标，对黑白渐变纹理进行纹理采样
4、最后，把采样后的结果与光照模型公式的结果相乘输出
## 二、光照衰减实现
### 1、Unity内部已经给我们提供了一张非线性黑白渐变的UV贴图

这张UV贴图名字是固定的：_LightTexture0
注意：需要引入库 AutoLight.cginc

    使用模型的uv进行采样，看看这张图大概的样子
    fixed atten = tex2D(_LightTexture0,i.uv);
    return atten;
### 2、把模型从世界坐标转化到灯光坐标下（使用矩阵相乘实现转化的效果）

1.在 v2f 中定义一个 float3 类型的 TEXCOORD，来存放顶点坐标转化到世界坐标之后坐标信息

    1

    float3 worldPos : TEXCOORD2;

2.在顶点着色器中，把模型顶点的本地坐标转化为世界坐标(使用了unity_ObjectToWorld矩阵)

    1

    o.worldPos = mul(unity_ObjectToWorld,v.vertex);

3.把模型顶点从世界坐标转化为灯光坐标(使用了unity_WorldToLight矩阵)

    1

    //因为转化时使用的是4行的矩阵，所以 要把模型的顶点坐标增加一个w = 1,使坐标转化准确
    float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;

在这里，我们输出一下lightCoord的灰度图看一下效果

    return lightCoord.x;
## 3、使用Unity自带的光照衰减贴图进行纹理采样

    fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord));

注意：这里的纹理采样不能直接使用lightCoord  
可以这样理解，我们需要的效果是灯光靠近模型之后  
越近，采样越靠uv的左边，灯光越亮（白色）  
那么我们就可以使用lightCoord的点积来给光照衰减uv进行纹理采样  
不使用模长的原因：向量点积计算量比计算模长计算量小  

可以由下图理解，当 a 模长越小，dot(a,a)越小  
则在纹理采样时，越靠近纹理的左边（白色）



    fixed4 LightColor = _LightColor0 * atten;

## 三、使用Unity自带的方法，实现光源的衰减效果
destName:out用于存放衰减值得变量
input:用于控制阴影的变量（目前用不上，传入0）
worldPos:模型的世界坐标

    UNITY_LIGHT_ATTENUATION(atten,0,i.worldPos)
