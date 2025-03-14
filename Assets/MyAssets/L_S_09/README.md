<!-- 码云挂件,在码云、Typora下style无效 -->
<div style="position: absolute; right: 0 ;top: 0; opacity: 70%;">

</div>

# Shader的UV扭曲效果

## 实现的思路
1、在属性面板暴露一个 扭曲贴图的属性  
2、在片元结构体中，新增一个float2类型的变量，用于独立存储将用于扭曲的纹理的信息  
3、在顶点着色器中，根据需要使用TRANSFORM_TEX对Tilling 和 Offset 插值；以及根据需要使用_Time相乘实现流动效果  
4、在片元着色器中，使用fixed4变量来存储，对扭曲纹理的采样结果

    fixed4 distortTex = tex2D(_DistortTex,i.uv2);

5、使用lerp(A,B,alpha)进行线性插值

    float2 distort = lerp(i.uv.xy,distortTex,_Distort);

6、最后用 线性插值后的结果对 主纹理进行采样

    fixed4 col = tex2D(_MainTex, distort);
