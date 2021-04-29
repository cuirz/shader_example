#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING

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
    LIGHTING_COORDS(3, 4)
};

sampler2D _MainTex;
float4 _MainTex_ST;
float _Gloss;
float4 _Color;

Interpolators vert(MeshData v)
{
    Interpolators o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_VERTEX_TO_FRAGMENT(o); // lighting, actually

    return o;
}

float4 frag(Interpolators i) : SV_Target
{
    // #ifdef USE_LIGHTING
    #if defined(USE_LIGHTING)
        // diffuse lighting
        float3 N = normalize(i.normal);
        float3 L = normalize(UnityWorldSpaceLightDir(i.wPos));
        float attenuation = LIGHT_ATTENUATION(i);
        float3 lambert = saturate(dot(N, L));
        float3 diffuseLight = (lambert * attenuation) * _LightColor0.xyz;
        // return float4(diffuseLight, 1);


        // specular lighting
        float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
        float3 R = reflect(-L, N); // users for Phong
        float3 H = normalize(L + V);
        float3 specularLight = saturate(dot(H, N)) * (lambert > 0); // Blinn-Phong
        // float3 specularLight = saturate(dot(V,R));
        float specularExponent = exp2(_Gloss * 11) + 2;
        specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation; // specular exponent
        specularLight *= _LightColor0.xyz;

        // float fresnel = (1 - dot(V, N)) * frac(_Time.y * 2);
        float fresnel = (1 - dot(V, N)) * (cos(_Time.y * 4) * 0.5 + 0.5);


        return float4(diffuseLight * _Color + specularLight, 1);

    #else
        return _Color;
    #endif


    // sample the texture
    // fixed4 col = tex2D(_MainTex, i.uv);

    // return col;
}
