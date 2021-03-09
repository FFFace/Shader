// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


Shader "Custom/test_noNormal"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("NormalMap", 2D) = "white" {}
        _SpecularMap("SpecularMap", 2D) = "white" {}
        _Specular("Specular", Range(0,1)) = 0.0
        _Smoothness("Smoothness", Range(0,1)) = 0.0
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        _DissolveMap("DissolveMap", 2D) = "whtie" {}
        _DissolveColor("DissolveColor", Color) = (1,1,1,1)
        _DissolveAmount("DissolveAmount", Range(0,1)) = 0
        _DissolveWidth("DissolveWidth", Range(0,1)) = 0
        _AlphaTest("Alpha", Range(0,1)) = 0
        _OutlineBold("Outline Bold", Range(-1,1)) = 0.1
        _RedColor("Color RedControll", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Geometry" "RenderType"="Transparent" }
        LOD 200
            cull off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf _BandedLighting fullforwardshadows alphatest:_AlphaTest vertex:vertex
        //#pragma vertex vertex
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _DissolveMap;
        sampler2D _SpecularMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_DissolveMap;
            float2 uv_SpecularMap;
            float3 viewDir;
            float3 lightDir;
            float3 vertex;
            //float3 worldNormal; INTERNAL_DATA
            //float outline;
        };

        struct SurfaceOutputCustom
        {
            fixed3 Albedo;
            fixed3 Normal;
            fixed3 Emission;
            half Specular;
            fixed Gloss;
            fixed Alpha;
            half Outline;
        };

        half _Glossiness;
        half _Metallic;
        half _OutlineBold;
        half _DissolveAmount;
        half _DissolveWidth;
        half _Specular;
        half _RedColor;
        half _Smoothness;
        fixed4 _Color;
        fixed4 _DissolveColor;
        fixed4 _SpecularColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vertex(inout appdata_tan i, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.lightDir = WorldSpaceLightDir(i.vertex);
        }

        void surf (Input IN, inout SurfaceOutputCustom o)
        {
            _Color.g = _Color.g - _Color.g * (saturate((_SinTime.w +1)* 0.5)) * _RedColor;
            _Color.b = _Color.b - _Color.b * (saturate((_SinTime.w +1)* 0.5)) * _RedColor;
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 mask = tex2D(_DissolveMap, IN.uv_DissolveMap + _Time.x);
            fixed4 smap = tex2D(_SpecularMap, IN.uv_SpecularMap);
            //o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

            half dissolveWidth = ceil(mask.r - (_DissolveAmount + _DissolveWidth));

            half toneDot = dot(IN.lightDir, o.Normal) * 0.5f + 0.5f;
            half tone = ceil(toneDot * 2) / 2;

            half outline = dot(IN.viewDir, o.Normal) * 0.5f + 0.5f;
            outline -= _OutlineBold;
            outline = ceil(outline);

            float3 fSpecularColor;
            float3 fReflectVector = reflect(IN.lightDir, IN.viewDir);
            float fRDotV = saturate(dot(fReflectVector, o.Normal));
            float spec = ceil(pow(fRDotV, _Specular) * _Smoothness * _SpecularColor.rgb * smap.r -0.3);
            fSpecularColor = spec * _Smoothness * _SpecularColor.rgb * smap.a;

            o.Albedo = ((c + fSpecularColor) * tone * outline * dissolveWidth) + (_DissolveColor * (ceil(mask.r) - dissolveWidth));
            half dissolve = ceil(mask.r - _DissolveAmount);
            o.Alpha = dissolve;            

            o.Emission = o.Albedo;
            o.Gloss = smap.r;
        }

        float4 Lighting_BandedLighting(SurfaceOutputCustom s, float3 lightDir, float3 viewDir, float atten)
        {
            float4 fFinalColor;
            fFinalColor.rgb = (s.Albedo);
            fFinalColor.a = s.Alpha;

            return fFinalColor;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
