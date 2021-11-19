Shader "Tutorial/001_Basic_Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // 声明属性
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // 定义属性
            sampler2D _MainTex;
            // ST 为 SamplerTexture 意思，声明 _MainTex 是一张采样图
            // #define TRANSFORM_TEX(tex, name) (tex.xy * name##_ST.xy + name##_ST.zw)
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 将模型顶点的uv和Tiling、Offset两个变量进行运算，计算出实际显示用的定点uv。
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 通过UV坐标对贴图进行颜色采样
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
