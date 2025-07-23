// Simple phong shader based on nVidia plastic example

/******* Lighting Macros *******/
/** To use "Object-Space" lighting definitions, change these two macros: **/
#define LIGHT_COORDS "World"
// #define OBJECT_SPACE_LIGHTS /* Define if LIGHT_COORDS is "Object" */

float4x4 World : World;
float4x4 WorldInverseTranspose : WorldInverseTranspose;
float4x4 WorldViewProjection : WorldViewProjection;
float4x4 ViewInverse : ViewInverse;

cbuffer UpdateLights : register(b2)
{
	bool light0Enable : LIGHTENABLE
	<
		string Object = "Light 0";	// UI Group for lights, auto-closed
		string UIName = "Enable Light 0";
		int UIOrder = 20;
	> = false;	// maya manages lights itself and defaults to no lights

	int light0Type : LIGHTTYPE
	<
		string Object = "Light 0";
		string UIName = "Light 0 Type";
		string UIFieldNames ="None:Default:Spot:Point:Directional:Ambient";
		int UIOrder = 21;
		float UIMin = 0;
		float UIMax = 5;
		float UIStep = 1;
	> = 4;	

	float3 light0Color : LIGHTCOLOR 
	<
		string Object = "Light 0";
		string UIName = "Light 0 Color"; 
		string UIWidget = "Color"; 
		int UIOrder = 23;
	> = { 1.0f, 1.0f, 1.0f};

	float light0Intensity : LIGHTINTENSITY 
	<
		string Object = "Light 0";
		string UIName = "Light 0 Intensity"; 
		float UIMin = 0.0;
		float UIMax = 10;
		float UIStep = 0.01;
			int UIOrder = 24;
	> = { 1.0f };

	float3 light0Dir : DIRECTION 
	< 
		string Object = "Light 0";
		string UIName = "Light 0 Direction"; 
		string Space = "World"; 
		int UIOrder = 25;
		int RefID = 0; // 3DSMAX
	> = {100.0f, 100.0f, 100.0f}; 
}

float3 gDiffuseColor : DIFFUSE <
    string UIGroup = "Diffuse";
    string UIName =  "Diffuse Color";
    string UIWidget = "Color";
> = {1.0f,1.0f,1.0f};

float gDiffuseStrength <
    string UIGroup = "Diffuse";
    string UIName = "Diffuse Strength";
    string UIWidget = "slider";
    float UIMin = 0.0f;
	float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 1.0f;

//-------------------------------------------------------------------
// SHADOWS
Texture2D light0ShadowMap : SHADOWMAP
<
	string Object = "Light 0";	// UI Group for lights, auto-closed
	string UIWidget = "None";
	int UIOrder = 5010;
>;

float4x4 light0Matrix : SHADOWMAPMATRIX		
< 
	string Object = "Light 0";
	string UIWidget = "None"; 
>;

float shadowDepthBias : ShadowMapBias
<
		string UIGroup = "Shadows";
		string UIWidget = "Slider";
		float UIMin = 0.000;
		float UISoftMax = 10.000;
		float UIStep = 0.001;
		string UIName = "Shadow Bias";
		int UIOrder = 13;
> = {0.01f};

float shadowMultiplier
<
		string UIGroup = "Shadows";
		string UIWidget = "Slider";
		float UIMin = 0.000;
		float UIMax = 1.000;
		float UIStep = 0.001;
		string UIName = "Shadow Strength";
		int UIOrder = 12;
> = {1.0f};

#define SHADOW_FILTER_TAPS_CNT 10
float2 SuperFilterTaps[SHADOW_FILTER_TAPS_CNT] 
< 
	string UIWidget = "None"; 
> = 
{ 
    {-0.84052f, -0.073954f}, 
    {-0.326235f, -0.40583f}, 
    {-0.698464f, 0.457259f}, 
    {-0.203356f, 0.6205847f}, 
    {0.96345f, -0.194353f}, 
    {0.473434f, -0.480026f}, 
    {0.519454f, 0.767034f}, 
    {0.185461f, -0.8945231f}, 
    {0.507351f, 0.064963f}, 
    {-0.321932f, 0.5954349f} 
};

float shadowMapTexelSize 
< 
	string UIWidget = "None"; 
> = {0.00195313}; // (1.0f / 512)

SamplerState SamplerShadowDepth
{
	Filter = MIN_MAG_MIP_POINT;
	AddressU = Border;
	AddressV = Border;
	BorderColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
};

float Opacity : OPACITY
<
	string UIGroup = "Opacity";
	string UIWidget = "Slider";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.001;
	string UIName = "Opacity";
> = 1.0;

struct appdata
{
	float4 position	: POSITION;
	float2 texcoord : TEXCOORD0;
	float3 normal	: NORMAL;
};

struct vOutput
{
	float4 position	: POSITION;
	float2 texcoord : TEXCOORD0;
	float3 worldPos : TEXCOORD1;
	float3 worldNormal	: TEXCOORD2;
	float3 WorldView	: TEXCOORD5;
};

vOutput vert(appdata IN, uniform float4x4 WorldInverseTranspose, uniform float4x4 World,
	uniform float4x4 ViewInverse, uniform float4x4 WorldViewProjection, uniform float3 LightDir)
{
	vOutput Output;
    //Compute MVP vertex position
    float4 pos = mul(IN.position, WorldViewProjection);
    //Compute World Space normal
    float3 worldNormal = mul(float4(IN.normal,0.0f),WorldInverseTranspose).xyz;
	//Compute World Space vertex position
	float4 worldPos = mul(float4(IN.position.xyz, 1.0f),World);	// convert to "world" space
	Output.WorldView = normalize(ViewInverse[3].xyz - worldPos.xyz);
	
	Output.worldPos = worldPos;
    Output.position = pos;
    Output.worldNormal = worldNormal;
	Output.texcoord = IN.texcoord;

	return Output;
}

float ComputeShadows(vOutput IN)
{
	float shadow = 1.0f;

	float4 Pndc = mul( float4(IN.worldPos.xyz,1.0) ,  light0Matrix); 
	Pndc.xyz /= Pndc.w; 
	if ( Pndc.x > -1.0f && Pndc.x < 1.0f && Pndc.y  > -1.0f   
		&& Pndc.y <  1.0f && Pndc.z >  0.0f && Pndc.z <  1.0f ) 
	{ 
		float2 uv = 0.5f * Pndc.xy + 0.5f; 
		uv = float2(uv.x,(1.0-uv.y));	// maya flip Y
		float z = Pndc.z - shadowDepthBias / Pndc.w; 

		// we'll sample a bunch of times to smooth our shadow a little bit around the edges:
		shadow = 0.0f;
		for(int i=0; i<SHADOW_FILTER_TAPS_CNT; ++i) 
		{ 
			float2 suv = uv + (SuperFilterTaps[i] * shadowMapTexelSize);
			float val = z - light0ShadowMap.SampleLevel(SamplerShadowDepth, suv, 0 ).x;
			shadow += (val >= 0.0f) ? 0.0f : (1.0f / SHADOW_FILTER_TAPS_CNT);
		}

		// a single sample would be:
		// shadow = 1.0f;
		// float val = z - ShadowMapTexture.SampleLevel(SamplerShadowDepth, uv, 0 ).x;
		// shadow = (val >= 0.0f)? 0.0f : 1.0f;
		
		shadow = lerp(1.0f, shadow, shadowMultiplier);  
	} 

	return shadow;
}

float4 frag(vOutput IN) : COLOR
{
	float4 outColor = float4(0, 0, 0, 1);
	float3 worldNormal = normalize(IN.worldNormal);
	float3 lightDir = normalize(-light0Dir);

	float3 diffuse = saturate(dot(lightDir, worldNormal));

	if(light0Enable )
	{
		float shadow = 1.0f;
		shadow = ComputeShadows(IN);
		diffuse *= shadow;
		outColor.rgb = (diffuse) * gDiffuseColor * light0Color * light0Intensity  * Opacity;
		outColor.a = Opacity;
	}

	return outColor;
}

technique10 Simple10
<
	int isTransparent = 3;
	// string transparencyTest = "Opacity < 1.0 || (UseDiffuseTexture && UseDiffuseTextureAlpha) || UseOpacityMaskTexture || OpacityFresnelMax > 0 || OpacityFresnelMin > 0";
	// bool supportsAdvancedTransparency = true;
>
{
	pass p0
	{
		SetVertexShader(
			CompileShader(vs_4_0, vert(WorldInverseTranspose, World,ViewInverse, WorldViewProjection, light0Dir))
		);

		SetGeometryShader(NULL);

		SetPixelShader(
			CompileShader(ps_4_0, frag())
		);
	}
}


