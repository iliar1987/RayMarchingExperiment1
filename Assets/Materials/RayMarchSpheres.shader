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
			sampler2D _CameraDepthTexture;
			float4x4 _ClipToWorld;
			sampler2D _MainTex;
			float _NearPlane;

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldDirection : TEXCOORD1;
				float4 screenPosition : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;

				// No need for a matrix multiply here when a FMADD will do.
				o.vertex = v.vertex * float4(2, 2, 1, 1) - float4(1, 1, 0, 0);

				// Construct a vector on the Z = 0 plane corresponding to our screenspace location.
				float4 clip = float4((v.uv.xy * 2.0f - 1.0f) * float2(1, -1), 0.0f, 1.0f);
				// Use matrix computed in script to convert to worldspace.
				o.worldDirection = mul(_ClipToWorld, clip) - _WorldSpaceCameraPos;
				o.screenPosition = o.vertex;

				// UV passthrough.
				// Flipped Y may be a platform-specific difference - check OpenGL version.
				o.uv = v.uv;
				//o.uv.y = 1.0f - o.uv.y;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{ 
				fixed4 col = tex2D(_MainTex, i.uv);
				// Read depth, linearizing into worldspace units.
				//float depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv)));
				float depth = 1.0f;

				// Multiply by worldspace direction (no perspective divide needed).
				float3 worldspace = i.worldDirection * depth + _WorldSpaceCameraPos;

				// Draw a worldspace tartan pattern over the scene to demonstrate.  
				return col*float4(frac((worldspace)) + float3(0, 0, 0.1), 1.0f);
			}
			
			ENDCG
		}
	}
}
