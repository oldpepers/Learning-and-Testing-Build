//XRay效果
Shader "MyShader/L_S_23_a"
{
    SubShader
    {
        Pass
        {
            //使用半透明排序
            Tags{"Queue" = "Transparent"}
            
            Blend One One
            
            ZTest Greater
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //传入顶点法向量
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                //存放模型顶点的世界坐标
                float3 worldPos : TEXCOORD1;
                //存放世界空间下的法向量
                half3 worldNormal : TEXCOORD2;
            };
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //使用矩阵变换，把模型的顶点坐标转化为世界坐标
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                //把顶点法向量转化为世界坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = 1;
                //得到从模型顶点 指向 摄像机的 单位向量 
                fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                //得到模型世界坐标下的法向量
                fixed3 N = normalize(i.worldNormal);
                //计算点积
                fixed VdotN = dot(V,N);
                //模拟菲涅尔效果（中间暗周围亮）
                fixed fresnel = 2 * pow(1 - VdotN,2);

                c.rgb = fresnel * fixed4(1,0,4,0);

                //做出流动分层的效果
                fixed v = frac(i.worldPos.y * 20  - _Time.y);

                c.rgb *= v;
                return c;
            }
            ENDCG
        }
    }
}

