Shader "Ethan/FlagWave"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}

        _Freq ("Wave Frequency", Range(0, 5)) = 3.0
        _Speed ("Wave Speed", Range(0, 10)) = 1.0
        _Amp ("Wave Amplitude", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Opaque" }
        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // Include URP core functionality
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION; // Object space position

                float3 normalOS : NORMAL; // Object space normal

                float2 uv : TEXCOORD0; // UV coordinates for texturing
                
                float4 tangentOS : TANGENT; // Tangent for normal mapping
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION; // Homogeneous clip-space position

                float3 normalWS : TEXCOORD1; // World space normal

                float3 tangentWS : TEXCOORD2; // World space tangent

                float2 uv : TEXCOORD0; // UV coordinates

                float3 bitangentWS : TEXCOORD3; // World space bitangent

                float3 viewDirWS : TEXCOORD4; // World space view direction
            };

            // Declare properties
            float4 _BaseColor;
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            float _Freq;
            float _Speed;
            float _Amp;

            // Vertex Shader with wave animation
            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float wave = sin(_Time.y * _Speed + IN.positionOS.x * _Freq) * _Amp;

                // Adjust the vertex y pos
                float3 displacedPos = IN.positionOS.xyz;
                displacedPos.y += wave;

                // Transform object space position to homogeneous clip-space position
                OUT.positionHCS = TransformObjectToHClip(displacedPos);

                // Calculate view direction in world space
                float3 worldPosWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPosWS);

                // Pass UV coordinates to the fragment shader
                OUT.uv = IN.uv;

                return OUT;
            }

            // Fragment Shader to apply texture and base color tint
            half4 frag(Varyings IN) : SV_Target
            {
                float2 uv = TRANSFORM_TEX(IN.uv, _MainTex);
                half4 flag = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * _BaseColor;

                // Apply final colour
                return flag;
            }
            
            ENDHLSL
        }
    }
}