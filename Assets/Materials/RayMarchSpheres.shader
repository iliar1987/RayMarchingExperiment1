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
	uniform float _MinDist;
	uniform float _Fogginess;
	uniform float _StepMultiplier;
	uniform float _WavePropagationSpeed;
	uniform float _TurnPeriod;
	uniform float _TurnCompletionTime;


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

	float de_gridSpheres(float3 x)
	{
		//return length(frac(x/_GridSpacing)*_GridSpacing - _SpherePos) - _SphereRadius;
		return length(frac(x / _GridSpacing)*_GridSpacing - _SpherePos) - _SphereRadius;
	}

#define DE(x) de_gridSpheres(x)
//#define CALC_NORMAL(p,dx) calcNormal_Spheres(p,dx)
#define CALC_NORMAL(p,dx) calcNormal(p,dx)

	//A faster formula to find the gradient/normal direction of the DE(the w component is the average DE)
//credit to http://www.iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
	float3 calcNormal(float3 p, float dx) {
		const float3 k = float3(1, -1, 0);
		return normalize(k.xyy*DE(p + k.xyy*dx) +
			k.yyx*DE(p + k.yyx*dx) +
			k.yxy*DE(p + k.yxy*dx) +
			k.xxx*DE(p + k.xxx*dx));
	}

	float3 calcNormal_Spheres(float3 p, float dx)
	{
		return normalize(frac(p / _GridSpacing) * _GridSpacing - _SpherePos);
	}

	float3 RotateVec(float3 v, float3 axis, float theta)
	{
		return v * cos(theta) + cross(axis, v) * sin(theta) + axis * dot(axis, v) * (1 - cos(theta));
	}

	fixed4 frag(v2f i) : SV_Target
	{
		const float pi = 3.1415926f;
		float4 rc;
		rc.xyz = _CameraInvViewMatrix._14_24_34;
		rc.w = 0.0;
		//float3 rc= float3(0,0,0);
		float4 rayDir;
		rayDir.xyz = i.ray / length(i.ray);
		rayDir.w = 1;

		//fixed4 col;
		//col.xyz = rayDir * 0.5 + 1;
		//col.w = 1;
		//return col;

		fixed4 col;
		int iStep;
		col = fixed4(0, 0, 0, 1);
		for (iStep = 1;iStep <= _NSteps;++iStep)
		{
			float d = DE(rc.xyz)*_StepMultiplier;
			if (d < _MinDist)
			{
				float3 normal = CALC_NORMAL(rc, _MinDist);
				//col = fixed4(1.0, 0, 0, 1);
				float cellNum = floor(rc.x / _GridSpacing);
				float t = _Time.y - cellNum * _GridSpacing / _WavePropagationSpeed;
				float timeFromPeriodStart = fmod(t,_TurnPeriod);
				float inAnimationTime = smoothstep(_TurnPeriod - _TurnCompletionTime,_TurnPeriod, timeFromPeriodStart);
				int phase = (int)(t / _TurnPeriod) % 3;

				float angle = (phase + inAnimationTime) * 2 * pi / 3;
				float3 axis = float3(1, 1, 1);
				axis /= length(axis);
				col.xyz = RotateVec(normal,axis,angle) * 0.5 + 0.5;
				col.w = 1;
				break;
			}
			rc += rayDir * d;
		}
		float mulFactor = _Fogginess / rc.w;
		//col.g += rc.w / 10;
		if (mulFactor < 1)
		{
			col *= mulFactor;
		}
		return col;
	}
			
			ENDCG
		}
	}
}
