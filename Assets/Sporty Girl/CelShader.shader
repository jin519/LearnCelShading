Shader "Unlit/CelShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowStrength("Shadow Strength", Range(0, 1)) = 0.5 
        _OutlineWidth("Outline Width", Range(0, 0.01)) = 0.005
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags 
            {
                "LightMode" = "ForwardBase"
                "PassFlags" = "OnlyDirectional"
            }

            Cull Off

            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL; 
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ShadowStrength;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Normalizing vector so it's length always 1.
                float3 normal = normalize(i.worldNormal);

                // Calculating Dot Product for surface normal and light direction.
                // _WorldSpaceLightPos0 - built-in Unity variable
                float NdotL = dot(_WorldSpaceLightPos0, normal);

                // Calculating light intensity on the surface.
                // If surface faced towards the light source (NdotL > 0), 
                // then it is completely lit.
                // Otherwise we use Shadow Strength for shading
                float lightIntensity = NdotL > 0 ? 1 : _ShadowStrength;

                // Sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // Apply shading
                col *= lightIntensity;

                return col;
            }

            ENDCG
        }

        Pass 
        {
            Cull Off

            Stencil
            {
                Ref 1
                Comp Greater
            }

            CGPROGRAM
                    
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            // Declare variables
            half _OutlineWidth;
            static const half4 OUTLINE_COLOR = half4(0,0,0,0);

            v2f vert(appdata v)
            {
                // Convert vertex position and normal to the clip space
                float4 clipPosition = UnityObjectToClipPos(v.vertex);
                float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, v.normal));

                // Calculating vertex offset.
                // Taking into account "perspective division" and multiplying it with W component
                // to keep constant offset
                // independent from distance to the camera
                float2 offset = normalize(clipNormal.xy) * _OutlineWidth * clipPosition.w;

                // We also need take into account aspect ratio.
                // _ScreenParams - built-in Unity variable
                float aspect = _ScreenParams.x / _ScreenParams.y;
                offset.y *= aspect;

                // Applying offset
                clipPosition.xy += offset;

                v2f o;
                o.vertex = clipPosition;

                return o;
            }

            fixed4 frag() : SV_Target
            {
                // All pixels of the outline have the same constant color
                return OUTLINE_COLOR;
            }

            ENDCG
        }
    }
}
