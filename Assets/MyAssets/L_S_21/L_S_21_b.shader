Shader "MyShader/L_S_21_b"
{
    Properties
    {
        [Header(Diffuse)]
        //光照系数
        _DiffuseIntensity("Diffuse Intensity",float) = 1
        [Header(Specular)]
        //高光颜色
        _SpecularColor("Specular Color",Color) = (1,1,1,1)
        //高光系数
        _SpecularIntensity("Specular Intensity",Float) = 1
        //高光范围系数
        _Shininess("Shininess",Float) = 1
        
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
                //用于存储模型顶点的世界坐标
                float3 worldPos : TEXCOORD2;
            };

            half _DiffuseIntensity;
            fixed4 _SpecularColor;
            float _SpecularIntensity,_Shininess;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //把顶点法线本地坐标转化为世界坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //把模型的顶点坐标从本地坐标转化到世界坐标
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
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
                //fixed4 Diffuse = Ambient + (Kd * LightColor * dot(N,L));
                //因为 当 顶点法线 与 反射点指向光源的向量 垂直 或成钝角时，光照效果就该忽略不计
                //所以，这里使用 max(a,b)函数来限制 点积的结果范围
                fixed4 Diffuse = Ambient + Kd * LightColor * max(0,dot(N,L));
                
                //return Diffuse;

                //Phong模型公式
                //Specular = SpecularColor * Ks * pow(max(0,dot(R,V)), Shininess)

                // 获取 V (模型顶点的世界坐标 指到 到摄像机世界坐标的单位向量)
                fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                //使用之前计算得到的公式
                //fixed3 R = 2 * dot(N,L) * N - L;
                //使用自带的计算反射光的函数
                fixed3 R = reflect(-L,N);
                    
                fixed4 Specular = _SpecularColor * _SpecularIntensity * pow(max(0,dot(R,V)),_Shininess);

                //BlinnSpecular = SpecularColor * Ks * pow(max(0,dot(N,H)), Shininess)
                fixed3 H = normalize(L + V);
                fixed4 BlinnSpecular = _SpecularColor  * _SpecularIntensity * pow(max(0,dot(N,H)),_Shininess);
                
                return BlinnSpecular+Diffuse;
            }
            ENDCG
        }
        Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //加入Unity自带的宏，用于区分不同的光照
            //只声明我们需要的变体
            //#pragma multi_compile POINT SPOT
            
            #pragma multi_compile_fwdadd
            //剔除我们不需要的变体
            #pragma skip_variants DIRECTIONAL POINT_COOKIE DIRECTIONAL_COOKIE
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //使用光照衰减贴图，需要引入 AutoLight.cginc 库
            #include "AutoLight.cginc"
            
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
                //定义一个三维向量，用于存放模型顶点 从本地坐标 转化为 世界坐标
                float3 worldPos : TEXCOORD2;
            };

            half _DiffuseIntensity;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //把顶点法线本地坐标转化为世界坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //把模型顶点从本地坐标转化为世界坐标
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                /*#if POINT
                return fixed4(0,1,0,1);
                #elif SPOT
                return 0;
                #endif*/

                
                //把模型顶点从世界坐标转化为灯光坐标
                //unity_WorldToLight
                //从世界空间转换到灯光空间下，等同于旧版的_LightMatrix0
                //因为转化时使用的是4行的矩阵，所以 要把模型的顶点坐标增加一个w = 1,使坐标转化准确
                //float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
                //return lightCoord.x;
                //使用Unity自带的光照衰减贴图进行纹理采样
                //fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord));

                //使用Unity自带的方法实现光照衰减
                UNITY_LIGHT_ATTENUATION(atten,0,i.worldPos)

                
                //获取主平行光的颜色
                fixed4 LightColor = _LightColor0 * atten;
                //获取顶点法线坐标(让其归一化)
                fixed3 N = normalize(i.worldNormal);
                //获取反射点指向光源的向量(因为内置了获取的方法，所以不用向量减法来计算)
                fixed3 L = _WorldSpaceLightPos0;
                //因为计算点光源时不需要考虑环境光，所以在Lambert光照模型中删除环境光的影响
                fixed4 Diffuse = LightColor * max(0,dot(N,L));
                
                return Diffuse;
                
            }
            ENDCG
        }
    }
}

