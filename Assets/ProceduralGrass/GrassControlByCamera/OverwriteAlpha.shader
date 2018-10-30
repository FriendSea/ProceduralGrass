Shader "Custom/OverwriteAlpha"
{
	Properties
	{
		_Alpha ("Alpha", Range(0,1))=1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			ColorMask A

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			float _Alpha;
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = 0;
				col.a = _Alpha;
				return col;
			}
			ENDCG
		}
	}
}
