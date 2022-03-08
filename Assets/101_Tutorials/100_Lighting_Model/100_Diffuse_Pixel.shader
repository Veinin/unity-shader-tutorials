// 逐顶点漫反射
Shader "Tutorial/100_Diffuse_Pixel"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;

                // 顶点位置从模型空间转换到裁剪空间
                o.position = UnityObjectToClipPos(v.vertex);
                // 法线从模型空间转换到世界空间
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                // 获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 获得世界空间法线
                fixed3 worldNormal = normalize(i.worldNormal);
                // 光源方向可以由 _WorldSpaceLightPos0 来得到
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                // 使用 _LightColor0 来访问该 Pass 处理的光源的颜色和强度信息
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}