Shader "Tutorial/100_Diffuse_Vertex_2"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct a2v 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                fixed3 color : COLOR;
                float2 uv : TEXCOORD0;
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

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= fixed4(i.color, 1);
                return col;
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}
