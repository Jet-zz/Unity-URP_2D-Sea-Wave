Shader "SeaWave"
{
    Properties
    {
        _SeaColor("SeaColor", Color) = (0,0.0,1,0)
        [HDR]_LineColor("LineColor", Color) = (1,1,1,0)
		_Frequency("Frequency", Range( 0 , 5)) = 0
		_Amplitude("Amplitude", Range( 0 , 1)) = 0
		_Speed("Speed", Range( 0 , 10)) = 0
        // _Alpha("Alpha", Range(0,1)) = 1
        _LineWidth("LineWidth",Range( 0 , 1)) = 1
        
        [HideInInspector]_ToStart("ToStart",Range( 0 , 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

        Pass
        {
            // Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZWrite Off
			ZTest LEqual

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
			float4 _SeaColor;
            float4 _LineColor;
			float _Frequency;
			float _Speed;
			float _Amplitude;
            // float _Alpha;
            float _ToStart;
            float _LineWidth;
			CBUFFER_END

            sampler2D _GradientTex;
            float4 _GradientTex_ST;
            TEXTURE2D(_CameraSortingLayerTexture);
            SAMPLER(sampler_CameraSortingLayerTexture);
           
            struct VertexInput
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos  : TEXCOORD1; 
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                o.uv = v.uv;

                float edge = saturate(((o.uv.y - _ToStart) / (1.0 - _ToStart)));
                // float wave = v.positionOS.x * _Frequency + _Time.y * _Speed;
                // wave = sin(wave) * _Amplitude;
                // wave = sin(wave) * _Amplitude;
                // wave *= edge;
                // v.positionOS.y += wave;

                float wave1 = sin(v.positionOS.x * _Frequency + _Time.y * _Speed);
                float wave2 = sin(v.positionOS.x * _Frequency * 1.7 + _Time.y * _Speed * 1.3 + 2.1);
                // float wave3 = sin(v.positionOS.x * _Frequency * 2.3 - _Time.y * _Speed * 0.7 + 4.3);
                float wave = (wave1 + 0.5) * (wave2 * 0.25);// * wave3;
                wave *= _Amplitude;
                wave *= edge;
                v.positionOS.y += wave;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionHCS = vertexInput.positionCS;
                o.screenPos = ComputeScreenPos(o.positionHCS);
                return o;
            }

            float4 frag(VertexOutput i) : SV_Target
            {
                //去掉屏幕颜色，使用屏幕的明暗度 采样(重新映射)一个渐变颜色(色系)
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float3 sceneColor = SAMPLE_TEXTURE2D(_CameraSortingLayerTexture, sampler_CameraSortingLayerTexture, screenUV);
                float y = i.uv.y;
                float mask = step(_LineWidth , y);

                float luminance = dot(sceneColor, float3(0.299, 0.587, 0.114));
                float3 waterPaletteColor = tex2D(_GradientTex, float2(luminance, 0.0)).rgb;

                float3 seaColor = waterPaletteColor;
                float3 lineColor = _LineColor.rgb;

                float3 finalColor = lerp(seaColor, lineColor , mask);

                float4 col;
                col.rgb = finalColor;
                return float4(col.rgb, 1);
                
                // float y = i.uv.y;
                // float mask = step(_LineWidth , y);

                // //海水颜色
                // float3 seaColor = _SeaColor.rgb;
                // float seaAlpha = _SeaColor.a;

                // //浪线颜色
                // float3 lineColor = _LineColor.rgb;
                // float lineAlpha = 1;

                // float3 finalColor = lerp(seaColor, lineColor , mask);
                // float finalAlpha = lerp(seaAlpha, lineAlpha , mask);
                
                // return float4(finalColor, finalAlpha);
            }
            ENDHLSL
        }
    }
}
