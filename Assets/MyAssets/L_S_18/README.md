<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader光强与环境色
实现思路：

1、首先使用前向渲染模式  
2、获取到场景中的灯
## 1、在Pass中使用前向渲染模式

    Tags{“LightMode”=“ForwardBase”}

## 2、使用系统变量 _LightColor0 获取场景中的主平行灯

_LightColor0
主平行灯的颜色值,rgb = 颜色x亮度; a = 亮度

    需要引用 Lighting.cginc

测试代码：  
L_S_18_a  
## 当我们在片元着色器结果处返回 fixed4(_LightColor0.rgb,1)这个结果时，会发现，小球的亮度还是会随着主环境光的亮度改变而改变

    return fixed4(_LightColor0.rgb,1);

## 获取Unity中的环境光的颜色

    unity_AmbientSky — 环境光（Gradient）中的Sky Color.
    unity_AmbientEquator — 环境光（Gradient）中的Equator Color.
    unity_AmbientGround — 环境光（Gradient）中的Ground Color.
    UNITY_LIGHTMODEL_AMBIENT — 环境光(Color)中的颜色，等同于环境光（Gradient）中的Sky Color.

分别与这三个 一 一 对应
unity_AmbientSky — 环境光（Gradient）中的Sky Color.  
unity_AmbientEquator — 环境光（Gradient）中的Equator Color.  
unity_AmbientGround — 环境光（Gradient）中的Ground Color.  

# Shader的Lambert光照的实现
一、分别获取Lambert光照模型的每个参数
Lambert光照模型公式

Diffuse = Ambient + Kd * LightColor * max(0,dot(N,L))

在获取 环境光颜色 和 主平行光颜色 前记着引入库 Lighting.cginc
1、使用 Unity 封装的参数 unity_AmbientSky 获取环境光色

    float Ambient = unity_AmbientSky;

2、在属性面板定义一个float类型参数作为光照系数

    Properties
    {
    //光照系数
    _DiffuseIntensity(“Diffuse Intensity”,float) = 1
    }

3、获取主平行光的颜色

    fixed4 LightColor = _LightColor0;

4、获取世界空间下的顶点法向量

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //在应用程序阶段传入到顶点着色器中，时加入顶点法向量信息
                half3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                //定义一个3维向量，用于接受世界坐标顶点法向量信息
                half3 worldNormal:TEXCOORD1;
                
            };

            float _DiffuseIntensity;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //把顶点法线坐标转化为世界坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Lambert光照模型的结果
                //Diffuse = Ambient + Kd * LightColor * max(0,dot(N,L))
                //使用 Unity 封装的参数 获取环境光色
                float Ambient = unity_AmbientSky;

                //在属性面板定义一个 可调节的参数 用来作为光照系数，调节效果的强弱
                half Kd = _DiffuseIntensity;

                //获取主平行光的颜色
                fixed4 LightColor = _LightColor0;

                //获取顶点法线坐标（并且让其归一化）
                fixed3 N = normalize(i.worldNormal);

                //获取反射点到光源的向量

                
                
                
                return fixed4(N,1);
            }

5、获取反射点指向光源的向量

    fixed3 L = _WorldSpaceLightPos0;

    _WorldSpaceLightPos0;
    平行灯: (xyz=位置,z=0)),已归一化
    其它类型灯: (xyz=位置,z=1)

6、使用Lambert光照公式，计算出光照影响的结果

    fixed4 Diffuse = Ambient + Kd * LightColor * dot(N,L);

因为 当 顶点法线 与 反射点指向光源的向量 垂直 或成钝角时，光照效果就该忽略不计 所以，这里使用 max(a,b)函数来限制 点积的结果范围

    fixed4 Diffuse = Ambient + Kd * LightColor * max(0,dot(N,L));

