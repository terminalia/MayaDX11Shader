// Simple phong shader based on nVidia plastic example

/******* Lighting Macros *******/
/** To use "Object-Space" lighting definitions, change these two macros: **/
#define LIGHT_COORDS "World"
// #define OBJECT_SPACE_LIGHTS /* Define if LIGHT_COORDS is "Object" */

// how many mip map levels should Maya generate or load per texture. 
// 0 means all possible levels
// some textures may override this value, but most textures will follow whatever we have defined here
// If you wish to optimize performance (at the cost of reduced quality), you can set NumberOfMipMaps below to 1
#define NumberOfMipMaps 0

float4x4 World : World;
float4x4 WorldInverseTranspose : WorldInverseTranspose;
float4x4 WorldViewProjection : WorldViewProjection;
float4x4 ViewInverse : ViewInverse;

//	LIGHTS
bool light0Enable : LIGHTENABLE
<
	string UIGroup = "Lighting";
	string Object = "Light 0";	// UI Group for lights, auto-closed
	string UIName = "Enable Light 0";
	int UIOrder = 0;
> = false;	// maya manages lights itself and defaults to no lights

int light0Type : LIGHTTYPE
<
	string Object = "Light 0";
	string UIName = "Light 0 Type";
	string UIFieldNames ="None:Default:Spot:Point:Directional:Ambient";
	float UIMin = 0;
	float UIMax = 5;
	float UIStep = 1;
	int UIOrder = 1;
> = 4;	

float3 light0Color : LIGHTCOLOR 
<
	string Object = "Light 0";
	string UIName = "Light 0 Color"; 
	string UIWidget = "Color"; 
	int UIOrder = 2;
> = { 1.0f, 1.0f, 1.0f};

float light0Intensity : LIGHTINTENSITY 
<
	string Object = "Light 0";
	string UIName = "Light 0 Intensity"; 
	float UIMin = 0.0;
	float UIMax = 10;
	float UIStep = 0.01;
	int UIOrder = 3;
> = { 1.0f };

float3 light0Dir : DIRECTION 
< 
	string Object = "Light 0";
	string UIName = "Light 0 Direction"; 
	string Space = "World"; 
	int UIOrder = 4;
	int RefID = 0; // 3DSMAX
> = {100.0f, 100.0f, 100.0f}; 

// DIFFUSE

float3 DiffuseColor : DIFFUSE <
    string UIGroup = "Diffuse";
    string UIName =  "Diffuse Color";
    string UIWidget = "Color";
	int UIOrder = 10;
> = {1.0f,1.0f,1.0f};

bool UseDiffuseTexture
<
	string UIGroup = "Diffuse";
	string UIName = "Diffuse Map";
	int UIOrder = 11;
> = false;

bool UseDiffuseTextureAlpha
<
	string UIGroup = "Diffuse";
	string UIName = "Diffuse Map Alpha";
	int UIOrder = 12;
> = false;

Texture2D DiffuseTexture
<
	string UIGroup = "Diffuse";
	string ResourceName = "";
	string UIWidget = "FilePicker";
	string UIName = "Diffuse Map";
	string ResourceType = "2D";	
	int mipmaplevels = NumberOfMipMaps;
	int UIOrder = 13;
	// int UVEditorOrder = 1;
>;

SamplerState SamplerDiffuse
{
	Filter = ANISOTROPIC;
	AddressU = Wrap;
	AddressV = Wrap;
};

float TextureAlphaLimit
<
	string UIGroup = "Diffuse";
	string UIWidget = "Slider";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.00001;
	int UIOrder = 14;
	string UIName = "Texture Alpha Cutoff";
> = 1.0;

// FRESNEL (RIM LIGHT)

float3 FresnelColor
<
	string UIGroup = "Diffuse";
	string UIName = "Fresnel Color";
	string UIWidget = "ColorPicker";
	int UIOrder = 15;
> = {1.0f, 1.0f, 1.0f };

float FresnelPower
<
	string UIGroup = "Diffuse";
	string UIName = "Fresnel Power"; 
	float UIMin = 0.0;
	float UIMax = 20;
	float UIStep = 0.01;
	int UIOrder = 16;
> = { 1.0f };




// SPECULARITY

bool blinnEnable
<	
	string UIGroup = "Specularity";
	string UIName = "Enable Blinn";
	int UIOrder = 20;
> = false;	// maya manages lights itself and defaults to no lights

float3 SpecularColor : Specular
<
	string UIGroup = "Specularity";
	string UIName = "Specular Color";
	string UIWidget = "ColorPicker";
	int UIOrder = 21;
> = {1.0f, 1.0f, 1.0f };

float SpecularPower
<
	string UIGroup = "Specularity";
	string UIWidget = "Slider";
	float UIMin = 0.0;	// 0 for anisotropic
	// float UISoftMax = 100.0;
	float UIMax = 128;
	float UIStep = 0.01;
	string UIName = "Specular Power";
	int UIOrder = 22;
> = 20.0;

float SpecularStrength
<
	string UIGroup = "Specularity";
	string UIWidget = "Slider";
	float UIMin = 0.0;	// 0 for anisotropic
	// float UISoftMax = 100.0;
	float UIMax = 10;
	float UIStep = 0.01;
	string UIName = "Specular Strength";
	int UIOrder = 23;
> = 1.0;

bool UseSpecularTexture
<
	string UIGroup = "Specularity";
	string UIName = "Specular Map";
	int UIOrder = 24;
> = false;

Texture2D SpecularTexture
<
	string UIGroup = "Specularity";
	string ResourceName = "";
	string UIWidget = "FilePicker";
	string UIName = "Specular Map";
	string ResourceType = "2D";
	int mipmaplevels = NumberOfMipMaps;
	int UIOrder = 15;
	int UVEditorOrder = 4;
>;

SamplerState SamplerSpecular
{
	Filter = ANISOTROPIC;
	AddressU = Wrap;
	AddressV = Wrap;
};

//-------------------------------------------------------------------
// NORMAL MAP
bool UseNormalTexture
<
	string UIGroup = "Normal Map";
	string UIName = "Normal Map";
	int UIOrder = 20;
> = false;

bool SupportNonUniformScale
<
	string UIGroup = "Normal Map";
	string UIName = "Support Non-Uniform Scale";
	int UIOrder = 21;
> = true;

float normalMapStrength
<
	string UIGroup = "Normal Map";
	string UIWidget = "Slider";
	string UIName = "Normal Map Strength";
	float UIMin = 0.000;
	float UISoftMax = 10.000;
	float UIStep = 0.001;
	int UIOrder = 23;
> = {0.01f};

Texture2D NormalTexture
<
	string UIGroup = "Normal Map";
	string ResourceName = "";
	string UIWidget = "FilePicker";
	string UIName = "Normal Map";
	string ResourceType = "2D";
	int mipmaplevels = 0;	// If mip maps exist in texture, Maya will load them. So user can pre-calculate and re-normalize mip maps for normal maps in .dds
	int UIOrder = 22;
	// int UVEditorOrder = 5;
>;

SamplerState SamplerNormal
{
	Filter = ANISOTROPIC;
	AddressU = Wrap;
	AddressV = Wrap;
};

//-------------------------------------------------------------------
// SHADOWS

Texture2D light0ShadowMap : SHADOWMAP
<
	string Object = "Light 0";	// UI Group for lights, auto-closed
	string UIWidget = "None";
	int UIOrder = 30;
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
		int UIOrder = 31;
> = {0.01f};

float shadowMultiplier
<
		string UIGroup = "Shadows";
		string UIWidget = "Slider";
		float UIMin = 0.000;
		float UIMax = 1.000;
		float UIStep = 0.001;
		string UIName = "Shadow Strength";
		int UIOrder = 32;
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

//-------------------------------------------------------------------
// TRANSPARENCY

float Opacity : OPACITY
<
	string UIGroup = "Opacity";
	string UIWidget = "Slider";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.001;
	string UIName = "Opacity";
	int UIOrder = 100;
> = 1.0;

struct appdata
{
	float4 position	: POSITION;
	float2 texcoord : TEXCOORD0;
	float3 normal	: NORMAL;
	float3 binormal : BINORMAL;
	float3 tangent : TANGENT;
};

struct vOutput
{
	float4 position	: POSITION;
	float2 texcoord : TEXCOORD0;
	float3 worldPos : TEXCOORD1;
	float3 worldNormal	: NORMAL;
	float4 worldTangent : TANGENT;
	float3 worldCameraDir : TEXCOORD5;
};

vOutput vert(appdata IN, uniform float4x4 WorldInverseTranspose, uniform float4x4 World,
	uniform float4x4 ViewInverse, uniform float4x4 WorldViewProjection, uniform float3 LightDir)
{
	vOutput Output;
    //Compute MVP vertex position
    float4 pos = mul(IN.position, WorldViewProjection);

	//Compute World Space normal
	float3 worldNormal;
	if (!SupportNonUniformScale)
    	worldNormal = mul(float4(IN.normal,0.0f), World).xyz;
	else 
		worldNormal = mul(float4(IN.normal,0.0f), WorldInverseTranspose).xyz;
	
	//Compute World Space tangent
	float4 worldTangent;
	if (!SupportNonUniformScale)
		worldTangent.xyz = mul(float4(IN.tangent, 0.0f), World).xyz;
	else 
		worldTangent = mul(float4(IN.tangent, 0.0f), WorldInverseTranspose);

	worldTangent.w = 1.0f;
	if (dot(cross(IN.normal.xyz, IN.tangent.xyz), IN.binormal.xyz) < 0.0) worldTangent.w = -1;
		
	
	//Compute World Space vertex position
	float4 worldPos = mul(float4(IN.position.xyz, 1.0f),World);	// convert to "world" space
	//Compute World Space camera position
	float3 worldCameraPos = ViewInverse[3].xyz;
	//Computee World Space camera direction
	float3 worldCameraDir = worldCameraPos - worldPos;
	
	Output.worldCameraDir = worldCameraDir;
	Output.worldPos = worldPos;
    Output.position = pos;
    Output.worldNormal = worldNormal;
	Output.worldTangent = worldTangent;
	Output.texcoord = float2(IN.texcoord.x, 1.0f - IN.texcoord.y);

	return Output;
}

float ComputePhong(float3 lightDir, float3 worldNormal, float3 worldCameraDir)
{
	float specular = SpecularStrength * pow(saturate(dot(reflect(-lightDir, worldNormal), worldCameraDir)), SpecularPower);

	return specular;
}

float ComputeBlinn(float diffuse, float3 lightDir, float3 worldNormal, float3 worldCameraDir)
{
	float3 halfwayDir = normalize(worldCameraDir + lightDir);
	float specular = dot(halfwayDir, worldNormal);
	float4 litV = lit(diffuse, specular, SpecularPower);
	specular = SpecularStrength * diffuse * litV.z;

	return specular;
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

	float2 uv = IN.texcoord;

	// NORMAL MAP
	if (UseNormalTexture) {
		
		float3 Tangent = normalize(IN.worldTangent.xyz);
		float3 Binormal = cross(worldNormal, Tangent);
		Binormal *= IN.worldTangent.w;
		float3x3 toWorld = float3x3(Tangent, Binormal, worldNormal);

		float3 NormalMap = NormalTexture.Sample(SamplerNormal, uv).xyz * 2 - 1;
		NormalMap.xy *= normalMapStrength;
		NormalMap = mul(NormalMap.xyz, toWorld);

		worldNormal = normalize(NormalMap.rgb);
	}

	if(light0Enable )
	{
		// DIFFUSE LIGHTING
		
		float3 diffuse = saturate(dot(lightDir, worldNormal));
		float diffuseAlpha = 1.0f;

		if (UseDiffuseTexture) {
			float4 diffuseTex = DiffuseTexture.Sample(SamplerDiffuse, uv);
			diffuse *= DiffuseColor * diffuseTex;

			if (UseDiffuseTextureAlpha) {
				diffuseAlpha = diffuseTex.a;
				//Apply Texture Alpha Cut Off
				clip(diffuseAlpha - TextureAlphaLimit);
			}
		}

		// SPECULAR LIGHTING
		float3 specular;
		float3 fresnel = pow(1- saturate(dot(normalize(IN.worldCameraDir), worldNormal)), FresnelPower) * FresnelColor;
		
		if (blinnEnable) {
			specular = ComputeBlinn(diffuse, lightDir, worldNormal, normalize(IN.worldCameraDir)) * SpecularColor;
		}
		else {
			specular = ComputePhong(lightDir, worldNormal, normalize(IN.worldCameraDir)) * SpecularColor;
		}

		if (UseSpecularTexture) {
			float4 specularTex = SpecularTexture.Sample(SamplerSpecular, uv);
			specular *= specularTex.r;
			fresnel = pow(1- saturate(dot(normalize(IN.worldCameraDir), worldNormal)), FresnelPower) * FresnelColor * specularTex.b;
		}

		// FRESNEL (RIM)
		

		
		float shadow = 1.0f;
		shadow = ComputeShadows(IN);

		float3 totalLight = (diffuse * shadow + specular * shadow + fresnel) * light0Color * light0Intensity * Opacity;

		
		// totalLight *= shadow;

		
		outColor.rgb = totalLight;
		
		
		//outColor.rgb = diffuse * light0Color * light0Intensity  * saturate(diffuseAlpha * Opacity);
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


