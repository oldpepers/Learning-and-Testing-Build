Shader "MyShader/L_S_18_b"
{
    Properties
    {
        //光照系数
        _DiffuseIntensity("Diffuse Intensity",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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

                //获取顶点法线坐标(让其归一化)
                fixed3 N = normalize(i.worldNormal);

                //获取反射点指向光源的向量(因为内置了获取的方法，所以不用向量减法来计算)
                fixed3 L = _WorldSpaceLightPos0;

                //使用Lambert公式计算出光照
                //fixed4 Diffuse = Ambient + Kd * LightColor * dot(N,L);
                //因为 当 顶点法线 与 反射点指向光源的向量 垂直 或成钝角时，光照效果就该忽略不计
                //所以，这里使用 max(a,b)函数来限制 点积的结果范围
                fixed4 Diffuse = Ambient + Kd * LightColor * max(0,dot(N,L));
                
                return Diffuse;
            }
            ENDCG
        }
    }
}

