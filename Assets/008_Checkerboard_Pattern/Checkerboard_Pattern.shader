Shader "Tutorial/008_Checkerboard_Pattern"
{
    Properties
    {
        _Scale ("Pattern Size", Range(0,10)) = 1
        _EvenColor("Color 1", Color) = (0, 0, 0, 1)
        _OddColor("Color 2", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags {}

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            float _Scale;
            float4 _EvenColor;
            float4 _OddColor;

            v2f vert(appdata v)
            {
                v2f o;
                // 计算裁剪空间中的坐标
                o.position = UnityObjectToClipPos(v.vertex);
                // 计算顶点在世界空间中的坐标
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                // 缩放位置，并对数值进行下限调整，以便获得整数。
                float3 adjustedWorldPos = floor(i.worldPos / _Scale);
                // 添加不同的维度
                float chessboard = adjustedWorldPos.x + adjustedWorldPos.y + adjustedWorldPos.z;
                // 除以2得到小数部分，结果为偶数的数值为0，奇数的数值为0.5
                chessboard = frac(chessboard * 0.5);
                // 乘以2，使奇数为白色，偶数为灰色
                chessboard *= 2;

                // 在偶数场的颜色（0）和奇数场的颜色（1）之间进行插值
                float4 color = lerp(_EvenColor, _OddColor, chessboard);
                return color;
            }

            ENDCG
        }
    }
}