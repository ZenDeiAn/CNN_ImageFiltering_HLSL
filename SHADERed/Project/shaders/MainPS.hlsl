cbuffer vars : register(b0)
{
	float2 uResolution;
};

SamplerState smp : register(s0);
Texture2D tex : register(t0);

float4 convolve(float2 uvm, float3x3 kernel)
{
    float2 texelSize = 1.0 / uResolution;
    float4 color = 0.0;
    
    for (int y = -1; y <= 1; y++)
    {
    	for (int x = -1; x <= 1; x++)
    	{
    		int indexY = y+1;
    		int indexX = x+1;
    		color += (tex.Sample(smp, uvm + texelSize * float2(x, y)) * kernel[indexY][indexX]);
    	}
    }

    return color;
}

float4 main(float4 fragCoord : SV_POSITION) : SV_TARGET
{
	float3x3 kernel_sharpened = float3x3(
	    0.0, -1.0, 0.0,
	   -1.0,  5.0, -1.0,
	    0.0, -1.0,  0.0
	);
	
	float3x3 kernel_diagonalEdged = float3x3(
	   1.0, 0.0, -1.0,
	   0.0,  0.0, 0.0,
	   -1.0, 0.0,  1.0
	);
	
	float3x3 kernel_gaussianBlurred = float3x3(
	   1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0,
	   2.0 / 16.0,  4.0 / 16.0, 2.0 / 16.0,
	   1.0 / 16.0, 2.0 / 16.0,  1.0 / 16.0
	);
	
	float3x3 kernel_blurred = float3x3(
	    1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0,
	    2.0 / 16.0, 4.0 / 16.0, 2.0 / 16.0,
	    1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0
	);
	
	float3x3 kernel_Edged = float3x3(
       -1.0, -1.0, -1.0,
       -1.0,  8.0, -1.0,
       -1.0, -1.0, -1.0
    );
	
    float2 uv = fragCoord.xy / uResolution;

    float2 cellSize = 1.0 / float2(3, 2);
    int cellX = int(uv.x / cellSize.x);
    int cellY = int(uv.y / cellSize.y);

    float2 localUV = frac(uv / cellSize);

    if (cellX == 0 && cellY == 0)
    {
        return tex.Sample(smp, localUV);
    }
    else if (cellX == 1 && cellY == 0)
    {
        return convolve(localUV, kernel_sharpened);
    }
    else if (cellX == 2 && cellY == 0)
    {
        return convolve(localUV, kernel_diagonalEdged);
    }
    else if (cellX == 0 && cellY == 1)
    {
        return convolve(localUV, kernel_gaussianBlurred);
    }
    else if (cellX == 1 && cellY == 1)
    {
        return convolve(localUV, kernel_blurred);
    }
    else if (cellX == 2 && cellY == 1)
    {
        return convolve(localUV, kernel_Edged);
    }

    return float4(0.0, 0.0, 0.0, 1.0);
}