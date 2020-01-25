// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

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
	// Provided by our script
	uniform float4x4 _FrustumCornersES;
	uniform sampler2D _MainTex;
	uniform float4 _MainTex_TexelSize;
	uniform float4x4 _CameraInvViewMatrix;
	uniform float3 _SpherePos;
	uniform float _SphereRadius;
	uniform float _GridSpacing;
	uniform int _NSteps;


	// Output of vertex shader / input to fragment shader
	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float3 ray : TEXCOORD1;
	};

	v2f vert(appdata v)
	{
		v2f o;

		// Index passed via custom blit function in RaymarchGeneric.cs
		half index = v.vertex.z;
		v.vertex.z = 0.1;

		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv.xy;

#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
			o.uv.y = 1 - o.uv.y;
#endif

		// Get the eyespace view ray (normalized)
		o.ray = _FrustumCornersES[(int)index].xyz;

		// Transform the ray from eyespace to worldspace
		// Note: _CameraInvViewMatrix was provided by the script
		o.ray = mul(_CameraInvViewMatrix, o.ray);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		float3 rc = _CameraInvViewMatrix._14_24_34;
		float3 rayDir = i.ray / length(i.ray);

		//fixed4 col;
		//col.xyz = rayDir * 0.5 + 1;
		//col.w = 1;
		//return col;

		int iStep;
		for (iStep = 1;iStep <= _NSteps;++iStep)
		{
			float3 CS = frac(rc - _SpherePos);
			float b_2 = dot(rayDir, CS);
			float c = dot(CS, CS) - _SphereRadius * _SphereRadius;
			float bsqr_4 = b_2 * b_2;
			float sSqr = bsqr_4 - c;

			if (sSqr > 0)
			{
				float s = sqrt(sSqr);
				float d = -s - b_2;
				if (d < 0)
				{
					d = s - b_2;
					if (d < 0)
					{
						return fixed4(1, 1, 0, 1);
					}
				}
				return fixed4(d / _GridSpacing, (float)iStep/_NSteps, 1, 1);
			}
			else if ( sSqr == 0 )
			{
				/*float d = -dot(rayDir, rc - _SpherePos);*/
				return fixed4(1, 0, 0, 1);
			}
			rc += rayDir * _GridSpacing;
		}
		return fixed4(0, 0, 0, 1);
	}
			
			ENDCG
		}
	}
}
