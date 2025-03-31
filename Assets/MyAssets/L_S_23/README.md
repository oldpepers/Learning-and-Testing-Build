<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader的XRay透视效果

## 模拟菲涅尔效果

就是模拟出像之前光照一样，模型中间亮，周围暗的相反效果
使用模型顶点指向摄像机的单位向量 与 顶点法向量 点积后的结果

    fixed3 VdotN = dot(V,N);

### 1、获取 V 向量

    使用 摄像机的世界坐标 - 模型顶点的世界坐标

v2f中：

    float3 worldPos : TEXCOORD1;

顶点着色器中：

    //使用矩阵变换，把模型的顶点坐标转化为世界坐标
    o.worldPos = mul(unity_ObjectToWorld,v.vertex);

片元着色器中：

    fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);

### 2、获取 N 向量

    把模型的顶点法向量转化为世界坐标即可

appdata中:

    half3 normal : NORMAL;

v2f中：

    //存放世界空间下的法向量
    half3 worldNormal : TEXCOORD2;

顶点着色器中：

    //把顶点法向量转化为世界坐标
    o.worldNormal = UnityObjectToWorldNormal(v.normal);

片元着色器中：

    fixed3 N = normalize(i.worldNormal);

### 3、点积输出效果

    fixed VdotN = dot(V,N);
    return VdotN;

### 4、模拟出菲涅尔效果(中间暗，周围亮)

    fixed fresnel = 2 * pow(1- VdotN,2);
## 实现 ＸRay 效果
### 1、使用半透明排序、修改混合模式、加点颜色

    //使用半透明排序
    Tags{“Queue” = “Transparent”}
    Blend One One

加点颜色

    c.rgb = fresnel * fixed4(1,0,4,0);
    return c;

### 2、增加分层效果（使用 frac 函数，只取小数部分）

    fixed v = frac(i.worldPos.x * 20);
    c.rgb *= v;

### 3、增加分层流动效果

    //做出流动分层的效果
    fixed v = frac(i.worldPos.y * 20 - _Time.w);
    c.rgb *= v;

### 4、把深度测试改为大于等于通过，以实现 XRay 效果

最终代码：L_S_23

# Shader的Pass的复用

## 一、怎么实现Pass的复用
1、给需要引用的Pass给定特定的名字

    Name “PassName”

2、在需要引用 Pass 的Shader中，在Pass的平行位置使用 UsePass “ShaderPath + PassName”

    UsePass “ShaderPath+PassName”

## 二、实现一个没被遮挡的部分显示模型原本的样子，遮挡部分显示模型的XRay效果
1、在上一篇的 XRay 效果的Shader中的Pass中给定Pass的名字为XRay

    Name “XRay”

2、在人物的Shader中，使用UsePass “ShaderPath+PassName”

    UsePass “MyShader/L_S_23_b/XRay”
