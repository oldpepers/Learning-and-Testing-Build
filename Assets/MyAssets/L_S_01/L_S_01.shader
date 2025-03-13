Shader"MyShader/L_S_01"//shader路劲名
{
	Properties
	{
		//材质属性区域
	}
	SubShader//子着色器之一
	{
		pass//具体的一次渲染绘制
		{
			//Unity中写CG代码的格式
			CGPROGRAM
			//绑定顶点着色器的名字
			#pragma vertex vert
			//绑定片元着手器的名字
			#pragma fragment frag
			//引入需要使用的库
			#include "UnityCG.cginc"
			//定义顶点着色器传入的结构体
			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
			};
			//定义片元着色器传入的结构体
			struct v2f
			{
				float4 pos : SV_POSITION;
			};
			//定义顶点着色器函数，名字与上面绑定的名字对应
			v2f vert(appdata v)
			{
				v2f o = (v2f)0;
				//把点转化到裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			//定义片元着色器函数，名字与上面绑定的名字对应
			float4 frag(v2f i) : SV_TARGET
			{
				fixed4 value = fixed4(0.5,0.2,2,0.8);
				//最后输出的 思维变量 有两种写法 rgba 或 xyzw,不能混用
				//return value.rgba;
				//return value.xyzw;
				//当改变 rgba 或 xyzw的顺序时，4个值的顺序随着改变
				return value.arbg;
			}

			ENDCG
		}
	}
	CustomEditor ""//挂载自定义材质面板脚本
	FallBack ""//备用方案
}
//普通管线shader模板