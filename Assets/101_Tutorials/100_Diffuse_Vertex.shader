// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

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
                o.position = UnityObjectToClipPos(v.vertex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
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
