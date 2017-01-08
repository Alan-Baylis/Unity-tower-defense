 Shader "Grail/_GS AO-UV2 | MASK-UV2" {
     Properties {
		 _Color ("Main Color", Color) = (1,1,1,1)
		_Color2 ("Overlay Color", Color) = (1,1,1,1)
         _MainTex ("Albedo (RGB)", 2D) = "white" {}
         _Glossiness ("Smoothness", Range(0,1)) = 0.5
         _Metallic ("Metallic", Range(0,1)) = 0.0
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_SpecMap ("Specular map", 2D) = "white" {}
		_OverlayMap ("Mask (stencil)", 2D) = "alpha" {}
		_OverlayTex ("Masked texture", 2D) = "white" {}
		_MultiplyWithA ("Multiply with albedo (1 = true)", Int) = 0
		_AOMap ("AO Map", 2D) = "white" {}
		_Intensity ("Intensity of ambient texture", Float) = 1
		_Intensity2 ("Intensity of AO", Float ) = 1
		_Intensity3 ("Intesity of Overlay", Float) = 1
     }
     SubShader {
         Tags { "RenderType"="Opaque" }
         LOD 200
         
         CGPROGRAM
         #pragma surface surf Standard vertex:vert fullforwardshadows
         #pragma target 3.0
        struct Input {
            float4 vertex : POSITION;
            float2  texcoord : TEXCOORD0;
            float2 texcoord1 : TEXCOORD1;
			float3    viewDir;
			INTERNAL_DATA
        };
 
        struct v2f {
            float4 vertex : POSITION;
            float2  texcoord : TEXCOORD0;
            float2 texcoord1 : TEXCOORD1;
        };
		
		/*inline float3 WorldSpaceViewDir( in float4 v )
		{
			return _WorldSpaceCameraPos.xyz - mul(_Object2World, v).xyz;
		}*/
 
         void vert (inout appdata_full v, out Input o)
         {
             UNITY_INITIALIZE_OUTPUT(Input,o);	
		     o.texcoord = v.texcoord.xy;
             o.texcoord1 = v.texcoord1.xy;
			 
         }
 
         sampler2D _MainTex;
		 uniform float4 _MainTex_ST;
         half _Glossiness;
         half _Metallic;
         fixed4 _Color;
		 

		sampler2D _BumpMap;
		sampler2D _SpecMap;
		sampler2D _AOMap;
		half _Intensity2;
		half _Intensity;
		fixed4 _Color2;
		half _Shininess;
		sampler2D _OverlayMap;
		uniform float4 _OverlayMap_ST;
		half _Intensity3;

		sampler2D _OverlayTex;
		half _MultiplyWithA;
 
         void surf (Input IN, inout SurfaceOutputStandard o) 
         {

			float2 maskUV = (IN.texcoord1 * _OverlayMap_ST.xy + _OverlayMap_ST.zw);
		
			fixed4 tex = tex2D(_MainTex, (IN.texcoord * _MainTex_ST.xy + _MainTex_ST.zw));
			fixed4 overlayTex = tex2D(_OverlayTex, (IN.texcoord * _MainTex_ST.xy + _MainTex_ST.zw));
			fixed4 AOtex = tex2D(_AOMap, IN.texcoord1);
			fixed4 overlayMap = tex2D (_OverlayMap, maskUV);

			// Set contrast of AO
			AOtex.rgb = ((AOtex.rgb - 0.5f) * max(_Intensity2, 0)) + 0.5f;
			
			float4 output = (tex * _Intensity) * _Color ;
			float4 overlayOutput = (overlayMap * _Intensity3) ;

			float3 lerped;
			if(_MultiplyWithA != 1) lerped = lerp(output.rgb,overlayTex.rgb * _Color2,overlayOutput.a);
			else lerped = lerp(output.rgb,overlayTex.rgb  * _Color2 * output.rgb,overlayOutput.a);

			o.Albedo = (lerped * _Intensity) * AOtex.g;
             o.Metallic = _Metallic;
             o.Smoothness = _Glossiness;
			o.Alpha = tex.a * _Color.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, (IN.texcoord * _MainTex_ST.xy + _MainTex_ST.zw)));		 
         }
         ENDCG
     } 
     FallBack "Diffuse"
 }