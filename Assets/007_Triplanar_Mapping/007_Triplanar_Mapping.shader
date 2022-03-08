Shader "Tutorial/007_Triplanar_Mapping"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Tint", Color) = (0, 0, 0, 0)
        _Sharpness ("Blend sharpness", Range(1, 64)) = 1
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                fixed4 position : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            float _Sharpness;

            v2f vert(appdata v)
            {
                v2f o;
                // 计算渲染对象在剪辑空间中的位置
                o.position = UnityObjectToClipPos(v.vertex);
                // 计算顶点的世界坐标
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos;
                // 计算世界空间法线
                float3 worldNormal = mul((float3x3) unity_WorldToObject, v.normal);
                o.normal = worldNormal;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                // 计算三个投影的UV坐标
                float2 uv_front = TRANSFORM_TEX(i.worldPos.xy, _MainTex);
                float2 uv_side = TRANSFORM_TEX(i.worldPos.zy, _MainTex);
                float2 uv_top = TRANSFORM_TEX(i.worldPos.xz, _MainTex);

                // 读取三个投影的uv位置的纹理
                fixed4 col_front = tex2D(_MainTex, uv_front);
                fixed4 col_side = tex2D(_MainTex, uv_side);
                fixed4 col_top = tex2D(_MainTex, uv_top);

                // 根据法线生成权重
                float3 weights = i.normal;
                // 显示物体两边的纹理（正反两面）。
                weights = abs(i.normal);
                // 使过渡更鲜明
                weights = pow(weights, _Sharpness);
                // 限制总和为1
                weights = weights / (weights.x + weights.y + weights.z);

                // 将权重与投射的颜色相结合
                col_front *= weights.z;
                col_side *= weights.x;
                col_top *= weights.y;

                // 结合投射的颜色
                fixed4 col = col_front + col_side + col_top;

                // 纹理颜色与色调颜色相乘
                col *= _Color;

                return col;
            }

            ENDCG
        }
    }
}
