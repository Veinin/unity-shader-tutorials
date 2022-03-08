// 逐顶点漫反射
Shader "Tutorial/100_Diffuse_Vertex"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            // 定义该Pass在Unity的光照流水线中的角色
            // ForwardBase 	在前向渲染中使用，应用环境光、主方向光、顶点/SH 光源和光照贴图。
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM

            // 为了使用Unity内置的一些变量
            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            // 定义材质漫反射属性
            fixed4 _Diffuse;

            struct a2v 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert(a2v v)
            {
                v2f o;

                // 顶点位置从模型空间转换到裁剪空间
                o.position = UnityObjectToClipPos(v.vertex);

                // 获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 法线从模型空间转换到世界空间
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                // 光源方向可以由 _WorldSpaceLightPos0 来得到
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                // 使用 _LightColor0 来访问该 Pass 处理的光源的颜色和强度信息
                // 为了防止点积结果为负值，我们需要使用max操作，saturate(x) 函数可以把x限制到[0,1]之间
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                o.color = ambient + diffuse;

                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                return fixed4(i.color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}
