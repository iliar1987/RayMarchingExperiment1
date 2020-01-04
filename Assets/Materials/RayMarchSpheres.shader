Shader "Hidden/RayMarchSpheres"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors
				//col.rgb = 1 - col.rgb;
				
				float fov_half = atan(1.0f / unity_CameraProjection._m11);

				float2 xy = (i.uv - 0.5f)*2.0f;
				float theta = fov_half * length(xy);
				float phi = atan2(xy.y, xy.x);

				float3 right = unity_WorldToCamera._11_12_13;
				float3 up = unity_WorldToCamera._21_22_23;
				float3 forward = unity_WorldToCamera._31_32_33;

				float3 ray = cos(theta) * forward + sin(theta) * (cos(phi) * right + sin(phi) * up);

				const float pi = 3.1415926f;
				
				col.rgb = ray*2 + 0.5f;

				return col;
			}
			ENDCG
		}
	}
}
