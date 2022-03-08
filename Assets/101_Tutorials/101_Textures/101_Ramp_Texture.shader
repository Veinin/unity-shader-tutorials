// 渐变纹理
Shader "Tutorial/101_Ramp_Texture"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _RampTex("Ramp Tex", 2D) = "white"{}
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

            fixed4 _Color;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
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
                // 获取渐变纹理UV
                o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                // 计算世界空间光照方向
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // 得到环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                // 使用 fixed2(halfLambert, halfLambert) 对渐变纹理进行采样
                fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color;
                fixed3 diffuse = _LightColor0.rgb * diffuseColor;

                // 计算世界空间视角方向
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                // 视角方向 + 光照方向，归一化后获得新矢量
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // 计算高光反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                fixed3 color = ambient + diffuse + specular;

                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}