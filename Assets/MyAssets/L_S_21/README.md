<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader光照模型Phong

## Phong光照模型
Phone光照公式：Specular = SpecularColor * Ks * pow(max(0,dot(R,V)),Shininess)

    Specular:最终物体上的高光反射
    SpecularColor：高光的颜色
    Ks：反射系数
    R：反射单位向量
    V：顶点到观察点的单位向量
    Shininess：高光指数，用于模拟高光的范围
## 图示解释Phone光照模型

Phone光照公式：Specular = SpecularColor * Ks * pow(max(0,dot(R,V)),Shininess)  
图01  


    R 是公式中，我们未知的量，需要计算得出

1、由图可得，R 可以由 -L 加上 P 得出  
2、P等于2*M  
3、因为 N 和 L 均为单位向量，所以 M 的模可以由 N 和 L得出  
4、得到M的模后，乘以 单位向量N，得到M  
5、最后得出 P 和 R  
# Shader光照模型Phong的实现
## 对主平行光实现高光效果

Specular = SpecularColor * Ks * pow(max(0,dot(R,V)), Shininess)
使用公式计算出结果后，与Lambert公式结果相加输出即可
1、在属性面板定义高光颜色

    _SpecularColor(“Specular Color”,Color) = (1,1,1,1)

2、在属性面板定义高光系数

    _SpecularIntensity(“Specular Intensity”,Float) = 1

3、在属性面板定义高光范围系数

    _Shininess(“Shininess”,Float) = 1

4、获取 V (模型顶点的世界坐标 指到 相机世界坐标 的单位向量)

    1、_WorldSpaceCameraPos
    主相机的世界坐标位置，类型：float3

    2、得到模型顶点的世界坐标
    在 v2f 结构体加入TEXCOORD类型，用于存储模型顶点转化后世界坐标
    float3 worldPos : TEXCOORD2;

    3、在顶点着色器，用 unity_ObjectToWorld 矩阵对模型顶点坐标进行转化
    o.worldPos = mul(unity_ObjectToWorld,v.vertex);

    4、因为需要得到由模型顶点指向摄像机的向量
    所以，用摄像机的世界坐标减去模型顶点的世界坐标，并且进行归一化
    fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);

5、由上一篇推理出的公式得到　 R　向量

    fixed3 R = 2 * dot(N,L) * N - L;

6、由公式计算得出高光效果

Specular = SpecularColor * Ks * pow(max(0,dot(R,V)), Shininess)

    fixed4 Specular = _SpecularColor * _SpecularIntensity * pow(max(0,dot(R,V)),_Shininess);
## 使用已有的数学方法　reflect(I,N)　计算出 R

    reflect(I,N)
    根据入射光方向向量 I ，和顶点法向量 N ，计算反射光方向向量。其中 I 和 N 必须被归一化，需要非常注意的是，这个 I 是指向顶点的；函数只对三元向量有效。
    float3 reflect( float3 i, float3 n )
    {
    return i - 2.0 * n * dot(n,i);
    }
    注意：这里的 I 和上面的 L 不同，这个 I 是入射光单位向量，所以方向和上面的L相反

    fixed3 R = reflect(-L,N);

最后返回，Lambert模型 和 Phong模型计算结果的和

    return Specular+Diffuse;

# Shader光照模型Blinn-Phong原理及实现

## Blinn-Phong原理

Phong模型：
Specular = SpecularColor * Ks * pow(max(0,dot(R,V)),Shininess)
Blinn-Phong模型：
Specular = SpecularColor * Ks * pow(max(0,dot(N,H)),Shininess)

半角向量的计算方法  
半角向量 = 向量1 + 向量2  
即 H = L+ V

## Blinn-Phong实现

在上一篇 Phong 模型的基础上，进行如下修改即可：

    fixed3 H = normalize(L + V);
    fixed4 BlinnSpecular = _SpecularColor * _SpecularIntensity * pow(max(0,dot(N,H)),_Shininess);

