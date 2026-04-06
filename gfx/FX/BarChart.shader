Includes = {
}
// Cz: 这个柱状图着色器的frame前三位表示下坐标，后三位表示上坐标，不得以0开头
//     color的r分量表示柱状图的宽度，g分量表示柱状图的高度，b分量表示边缘平滑程度，越小越平滑，0表示不平滑
//     colortwo的r分量表示柱状图的0-1颜色R，g分量表示柱状图的0-1颜色G，b分量表示柱状图的0-1颜色B，a分量表示柱状图的透明度
//     size表示柱状图的宽和总高，x分量表示宽度，y分量表示高度
PixelShader =
{
	Samplers =
	{
		TextureOne =
		{
			Index = 0
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "None"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
		TextureTwo =
		{
			Index = 1
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "None"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
	}
}


VertexStruct VS_INPUT
{
    float4 vPosition  : POSITION;
    float2 vTexCoord  : TEXCOORD0;
};

VertexStruct VS_OUTPUT
{
    float4  vPosition : PDX_POSITION;
    float2  vTexCoord0 : TEXCOORD0;
};


ConstantBuffer( 0, 0 )
{
	float4x4 WorldViewProjectionMatrix; 
	float4 vFirstColor;
	float4 vSecondColor;
	float CurrentState;
};


VertexShader =
{
	MainCode VertexShader
	[[
		
		VS_OUTPUT main(const VS_INPUT v )
		{
			VS_OUTPUT Out;
		   	Out.vPosition  = mul( WorldViewProjectionMatrix, v.vPosition );
			Out.vTexCoord0  = v.vTexCoord;
		
			return Out;
		}
		
	]]
}

PixelShader =
{
	MainCode PixelColor
	[[
		
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
            float width = vFirstColor.r * 1000.f;
            float height = vFirstColor.g * 1000.f;
            float edgeSmooth = vFirstColor.b * 10.f;

			float value = CurrentState * 1000000.f;
			float topY = floor(value / 1000.f) / height;
			float bottomY = mod(value, 1000.f) / height;

            float modX = mod(floor(v.vTexCoord0.x * width), 15.f);
            if ((modX < 5.f) && vSecondColor.r == 0.95) {
                return float4(0, 0, 0, 0);
            }

            float currentY = v.vTexCoord0.y;

            float distToTop = (currentY - topY) * height;
            float distToBottom = (bottomY - currentY) * height;

            if (currentY >= topY && currentY <= bottomY) {
                if (edgeSmooth <= 0.001f) {
                    return vSecondColor;
                }
                float edgeDist = min(distToTop, distToBottom);
                float intensity = saturate(edgeDist / edgeSmooth);
                
                float4 toRet = vSecondColor;
                toRet.a *= intensity;
                return toRet;
            } else {
                return float4(0, 0, 0, 0);
            }
		}
		
	]]

	MainCode PixelTexture
	[[
		
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
            return float4(1, 1, 1, 1);
		}
		
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}


Effect Color
{
	VertexShader = "VertexShader"
	PixelShader = "PixelColor"
}

Effect Texture
{
	VertexShader = "VertexShader"
	PixelShader = "PixelTexture"
}
