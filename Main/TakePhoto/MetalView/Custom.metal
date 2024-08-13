//
//  Custom.metal
//  ImageWizard
//
//  Created by zjkj on 2024/5/27.
//
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexIn vertexShader(uint vertexID [[vertex_id]]) {
    float4 positions[4] = {
        float4(-1.0, -1.0, 0.0, 1.0),
        float4( 1.0, -1.0, 0.0, 1.0),
        float4(-1.0,  1.0, 0.0, 1.0),
        float4( 1.0,  1.0, 0.0, 1.0)
    };

    float2 texCoords[4] = {
        float2(0.0, 1.0),
        float2(1.0, 1.0),
        float2(0.0, 0.0),
        float2(1.0, 0.0)
    };

    VertexIn out;
    out.position = positions[vertexID];
    out.texCoord = texCoords[vertexID];
    return out;
}

//fragment float4 fragmentShader(VertexIn in [[stage_in]],
//                              texture2d<float> texture1 [[texture(0)]],
//                              texture2d<float> texture2 [[texture(1)]]) {
//    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
//    float4 color1 = texture1.sample(textureSampler, in.texCoord);
//    float4 color2 = texture2.sample(textureSampler, in.texCoord);
//    return mix(color1, color2, 0);
//}

fragment float4 fragmentShader(VertexIn in [[stage_in]],
                              texture2d<float> texture1 [[texture(0)]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    return texture1.sample(textureSampler, in.texCoord);
}
