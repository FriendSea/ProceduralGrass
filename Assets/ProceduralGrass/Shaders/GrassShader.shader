Shader "Custom/GrassShader"
{
	Properties
	{
		_GrassTex ("Texture", 2D) = "white" {}
		_Width("Grass Width", Range(0, 1)) = 0.1
		_Height("Grass height", Range(0, 1)) = 0.5
		_Wind("Wind factor", Range(0, 1)) = 0.1
		_Displace("Randomize Position", Range(0, 1)) = 0.2
		_Density("Grass Density", int) = 5
		_MainTex("Grass Map", 2D) = "blue" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull Off
		CGINCLUDE
			#include "UnityCG.cginc"
		
			#ifdef UNITY_PASS_FORWARDBASE
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			#include "AutoLight.cginc"
			#endif
           
           	struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 tangent : TANGENT;
			};
		
			struct v2g
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
				float3 tangent : TEXCOORD2;
			};
			
			struct g2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float cutheight : TEXCOORD1;
			#ifdef UNITY_PASS_FORWARDBASE
				UNITY_FOG_COORDS(2)
				SHADOW_COORDS(3)
			#endif
			};

			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = float4(UnityObjectToViewPos(v.vertex), 1);
				o.uv = v.uv;
				o.normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				o.tangent = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent));
				return o;
			}
			
			float random (fixed2 p) { 
				return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 43758.5453);
        	}
		
			float _Width;
			float _Height;
			float _Wind;
			float _Displace;
			sampler2D _MainTex;
			void grass(v2g v,  inout TriangleStream<g2f> outStream){
				g2f o;
				float3 widthVector = normalize(cross(v.normal, float3(0,0,1)));
				float3 binormal = cross(v.normal, v.tangent);
				float3 displace = ((random(v.uv)-0.5)*v.tangent+(random(v.uv+1)-0.5)*binormal)*_Displace;
				float4 tex = tex2Dlod(_MainTex, float4(v.uv,0,0));
				tex.xy-=0.5;
				o.cutheight = tex.a;
				
        		o.pos = v.vertex;
        		o.pos.xyz+=widthVector*_Width/2;
        		o.pos.xyz += displace;
        		o.pos = mul(UNITY_MATRIX_P, o.pos);
        		o.uv = float2(1,0);
        	#ifdef UNITY_PASS_FORWARDBASE
        		UNITY_TRANSFER_FOG(o,o.pos);
        		TRANSFER_SHADOW(o)
        	#endif
        		outStream.Append(o);
        		
        		o.pos = v.vertex;
        		o.pos.xyz+=-widthVector*_Width/2;
        		o.pos.xyz += displace;
        		o.pos = mul(UNITY_MATRIX_P, o.pos);
        		o.uv = float2(0,0);
        	#ifdef UNITY_PASS_FORWARDBASE
        		UNITY_TRANSFER_FOG(o,o.pos);
        		TRANSFER_SHADOW(o)
        	#endif
        		outStream.Append(o);
        		
        		o.pos = v.vertex;
        		o.pos.xyz += (tex.x*v.tangent+tex.y*binormal+tex.z*v.normal)*_Height*(random(v.uv)+0.5);
        		o.pos.xyz+=displace;
        		o.pos.xyz += v.tangent*_Wind * sin(_Time.z+v.uv.x*5);
        		o.pos = mul(UNITY_MATRIX_P, o.pos);
        		o.uv = float2(0.5, 1);
        	#ifdef UNITY_PASS_FORWARDBASE
        		UNITY_TRANSFER_FOG(o,o.pos);
        		TRANSFER_SHADOW(o)
        	#endif
        		outStream.Append(o);
        		
        		outStream.RestartStrip();
			}
			
			float _Density;
			[maxvertexcount(84)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream){
				v2g v;
				for(int i=0;i<_Density;i++){
					for(int j=0;j<_Density-i;j++){
						float w1 = i/_Density;
						float w2 = j/_Density;
						float w0 = 1 - w1 - w2;
						v.vertex = input[0].vertex * w0 + input[1].vertex * w1 + input[2].vertex * w2;
						v.uv = input[0].uv * w0 + input[1].uv * w1 + input[2].uv * w2;
						v.normal = input[0].normal * w0 + input[1].normal * w1 + input[2].normal * w2;
						v.tangent = input[0].tangent * w0 + input[1].tangent * w1 + input[2].tangent * w2;
						grass(v, outStream);
					}
				}
			}
		ENDCG
		
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
           
           #include "Lighting.cginc"
			
			sampler2D _GrassTex;
			fixed4 frag (g2f i) : SV_Target
			{
				clip(1-i.uv.y-i.cutheight);
				fixed4 tex = tex2D(_GrassTex, i.uv);
				fixed4 col=0;
				col.rgb =tex.rgb * ShadeSH9(float4(0,1,0,1));
				float atten = SHADOW_ATTENUATION(i);
				col+=tex*_LightColor0*atten*atten;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
		
		Pass{
			Tags {"LightMode" = "ShadowCaster"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			
			fixed4 frag (g2f i) : SV_Target
			{
				clip(1-i.uv.y-i.cutheight);
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
		
	}
}
