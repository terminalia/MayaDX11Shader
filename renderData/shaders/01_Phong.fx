// Simple phong shader based on nVidia plastic example

/******* Lighting Macros *******/
/** To use "Object-Space" lighting definitions, change these two macros: **/
#define LIGHT_COORDS "World"
// #define OBJECT_SPACE_LIGHTS /* Define if LIGHT_COORDS is "Object" */

float4x4 World : World;
float4x4 WorldInverseTranspose : WorldInverseTranspose;
float4x4 WorldViewProjection : WorldViewProjection;
float4x4 ViewInverse : ViewInverse;

float3 gLightDirection : DIRECTION <
    string UIGroup = "Lights";
    string Object = "DirectionalLight0";
    string UIName =  "Directional Light 0";
    string Space = (LIGHT_COORDS);
> = {0.7f,-0.7f,-0.7f};

float3 gLightColor : SPECULAR <
    string Object = "DirectionalLight0";
    string UIName =  "Directional Light 0 Color";
    string UIWidget = "Color";
> = {1.0f,1.0f,1.0f};

float3 gAmbientColor : AMBIENT <
    string UIGroup = "Lights";
    string UIName =  "Ambient Color";
    string UIWidget = "Color";
> = {0.07f,0.07f,0.07f};

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

float3 gSpecularColor : DIFFUSE <
    string UIGroup = "Specularity";
    string UIName =  "Specular Color";
    string UIWidget = "Color";
> = {1.0f,1.0f,1.0f};

float gSpecularStrength <
    string UIGroup = "Specularity";
    string UIName = "Specular Strength";
    string UIWidget = "slider";
    float UIMin = 0;
	float UIMax = 5;
    float UIStep = 0.01f;
> = 0.4f;

float gSpecularPower <
    string UIGroup = "Specularity";
    string UIName = "Specular Power";
    string UIWidget = "slider";
    float UIMin = 0;
	float UIMax = 512;
    float UIStep = 0.01f;
> = 32.0f;

struct appdata
{
	float4 position	: POSITION;
	float3 normal	: NORMAL;
};

struct vOutput
{
	float4 position	: POSITION;
	float3 LightVec		: TEXCOORD1;
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
	Output.LightVec = -normalize(float3(LightDir.xyz));
	Output.WorldView = normalize(ViewInverse[3].xyz - worldPos.xyz);
	
    Output.position = pos;
    Output.worldNormal = worldNormal;

	return Output;
}

void phong(
	vOutput IN,
	uniform float Ks,
	uniform float SpecExpon,
	float3 LightColor,
	uniform float3 AmbiColor,
	out float3 DiffuseContrib,
	out float3 SpecularContrib)
{
	float3 Ln = normalize(IN.LightVec.xyz);
	float3 Nn = normalize(IN.worldNormal);
	float3 Vn = normalize(IN.WorldView);
	float3 Hn = normalize(Vn + Ln);
	float4 litV = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
	DiffuseContrib = litV.y * LightColor + AmbiColor;
	SpecularContrib = litV.z * Ks * LightColor;
}

float4 phongPS(
	vOutput IN,
	uniform float3 SurfaceColor,
	uniform float Ks,
	uniform float SpecExpon,
	uniform float3 LampColor,
	uniform float3 AmbiColor) : COLOR
{
	float3 diffContrib;
	float3 specContrib;
	phong(IN,Ks,SpecExpon,LampColor,AmbiColor,diffContrib,specContrib);
	float3 result = (specContrib * gSpecularColor) + (SurfaceColor * diffContrib);
    result *= gDiffuseStrength;
	return float4(result,1.0f);
}

technique10 Simple10
{
	pass p0
	{
		SetVertexShader(
			CompileShader(
				vs_4_0,
				vert(
					WorldInverseTranspose,
					World,
					ViewInverse,
					WorldViewProjection,
					gLightDirection)));

		SetGeometryShader(NULL);

		SetPixelShader(
			CompileShader(
				ps_4_0,
				phongPS(
					gDiffuseColor,
					gSpecularStrength,
					gSpecularPower,
					gLightColor,
					gAmbientColor)));
	}
}


