Shader "Tutorial/009_Fresnel"
{
    Properties
    {
        _Color("Tint", Color) = (0, 0, 0, 1)
        _MainTex("Texture", 2D) = "white" {}
        _Metallic("Metalness", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0
        [HDR] _Emission("Emission", color) = (0, 0, 0)

        _FresneColor("Fresnel Color", Color) = (1, 1, 1, 1)
        [PowerSlider(4)] _FresnelExponent("Fresnel Exponent", Range(0.25, 4)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color;
            
        half _Metallic;
        half _Smoothness;
        half3 _Emission;

        float3 _FresneColor;
        float _FresnelExponent;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
            INTERNAL_DATA
        };

        void surf(Input i, inout SurfaceOutputStandard o)
        {
            // 纹理采样与色调
            fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            o.Albedo = col.rgb;

            // 应用金属度和平滑度
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;

            // 得到法线与视图方向的点积
            float fresnel = dot(i.worldNormal, i.viewDir);
            // 反转菲涅尔，使大的数值在外面
            fresnel = saturate(1 - fresnel);
            // 将菲涅尔值提高到指数幂，以便能够调整它
            fresnel = pow(fresnel, _FresnelExponent);
            // 将菲涅尔值与颜色结合起来
            float3 fresnelColor = fresnel * _FresneColor;
            // 将菲涅尔值应用于反射
            o.Emission = _Emission + fresnelColor;
        }

        ENDCG
    }
}