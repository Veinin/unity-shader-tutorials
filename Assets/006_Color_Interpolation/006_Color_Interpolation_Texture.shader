Shader "Tutorial/006_Color_Blending/Texture"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _SecondaryTex("Secondary Texture", 2D) = "black" {}
        _Blend("Blend Value", Range(0, 1)) = 0
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

            float _Blend;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float2 main_uv = TRANSFORM_TEX(i.uv, _MainTex);
                float4 main_color = tex2D(_MainTex, main_uv);

                float2 secondary_uv = TRANSFORM_TEX(i.uv, _SecondaryTex);
                float4 secondary_color = tex2D(_SecondaryTex, secondary_uv);

                fixed4 col = lerp(main_color, secondary_color, _Blend);
                return col;
            }

            ENDCG
        }
    }
}