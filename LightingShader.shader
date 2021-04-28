Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        //        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            // #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"


            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Gloss;

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // diffuse lighting
                float3 N = i.normal;
                float3 L = _WorldSpaceLightPos0.xyz;
                float3 diffuseLight = saturate(dot(N, L)) * _LightColor0.xyz;
                // return float4(diffuseLight, 1);


                // specular lighting
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 R = reflect(-L,N);
                float3 specularLight = saturate(dot(V,R));
                specularLight = pow( specularLight,_Gloss); // specular exponent
                return float4(V, 1);


                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);

                // return col;
            }
            ENDCG
        }
    }
}