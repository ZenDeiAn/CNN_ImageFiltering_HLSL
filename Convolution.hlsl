Texture2D InputTexture : register(t0); 
SamplerState Sampler : register(s0);

float4 main(float4 position : SV_POSITION) : SV_TARGET {
    float2 texCoord = float2(position.x * 0.5 + 0.5, position.y * 0.5 + 0.5);
    return InputTexture.Sample(Sampler, texCoord);
}