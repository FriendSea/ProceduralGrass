Shader "Custom/GrassBendPaintShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BendMap("Bend Map", 2D) = "white" {}
		_BendScale("Bend Scale", Range(0, 1)) = 0.3
		_BendPos("Bend Position", Vector) = (0, 0, 0, 0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			float _BendScale;
			float4 _BendPos;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv2 = (v.uv - 0.5 + _BendPos.xy)/_BendScale + 0.5;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _BendMap;
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 bend = tex2D(_BendMap, i.uv2);
				col.xyz = bend.a * bend.xyz + (1-bend.a)*col.xyz;
				return col;
			}
			ENDCG
		}
	}
}
