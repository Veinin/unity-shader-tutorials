// 逐像素高光反射
Shader "Tutorial/100_Specular_BlinnPhong"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            // 为了使用一些内置变量，如 _LightColor0
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;

                // 顶点位置从模型空间转换到裁剪空间
                o.position = UnityObjectToClipPos(v.vertex);
                // 法线从模型空间转换到世界空间
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 顶点坐标从对象空间转换到世界空间
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                // 获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i.worldNormal);
                // 计算世界空间光照方向
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // 使用 _LightColor0 来访问该 Pass 处理的光源的颜色和强度信息
                // 为了防止点积结果为负值，我们需要使用max操作，saturate(x) 函数可以把x限制到[0,1]之间
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                // 计算世界空间视角方向
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                // 视角方向 + 光照方向，归一化后获得新矢量
                fixed3 halfDir = normalize(worldLight + viewDir);
                // 计算高光反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                fixed3 color = ambient + diffuse + specular;

                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
}