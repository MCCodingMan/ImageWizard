//
//  CISurfaceBlur.swift
//  ImageWizard
//
//  Created by zjkj on 2024/5/28.
//
import Foundation
import MetalPetal

class MTISurfaceBlurFilter: NSObject, MTIUnaryFilter {
    
    let kernel: MTIRenderPipelineKernel
    let weights: MTIVector
    var inputImage: MTIImage?
    var outputPixelFormat: MTLPixelFormat = .unspecified
    var threshold: Float = 10.0
    
    init(radius: Int) {
        let weightsCount = radius * 2 - 1
        assert(weightsCount > 0)
        
        var weights = [Float](repeating: 0, count: weightsCount)
        for i in 0..<radius {
            weights[radius - 1 + i] = MTISurfaceBlurFilter.gaussianDistributionPDF(Float(i), sigma: Float(radius))
            weights[radius - 1 - i] = weights[radius - 1 + i]
        }
        
        self.weights = MTIVector(floatValues: weights, count: UInt(weightsCount))
        
        let constants = MTLFunctionConstantValues()
        var radiusValue = radius
        constants.setConstantValue(&radiusValue, type: .int, withName: "metalpetal::surfaceblur::mtiSurfaceBlurKernelRadius")
        
        self.kernel = MTIRenderPipelineKernel(
            vertexFunctionDescriptor: MTIFunctionDescriptor(name: MTIFilterPassthroughVertexFunctionName),
            fragmentFunctionDescriptor: MTIFunctionDescriptor(
                name: "metalpetal::surfaceblur::mtiSurfaceBlur",
                constantValues: constants,
                libraryURL: MTIDefaultLibraryURLForBundle(Bundle(for: MTISurfaceBlurFilter.self))
            ),
            vertexDescriptor: nil,
            colorAttachmentCount: 1,
            alphaTypeHandlingRule: .general
        )
        
        super.init()
    }
    
    private static func gaussianDistributionPDF(_ x: Float, sigma: Float) -> Float {
        return 1.0 / sqrt(2 * .pi * sigma * sigma) * exp((-x * x) / (2 * sigma * sigma))
    }
    
    var outputImage: MTIImage? {
        guard let inputImage = inputImage else {
            return nil
        }
        
        return kernel.apply(
            to: [inputImage],
            parameters: ["weights": weights,
                         "bsigma": threshold / 255.0 * 2.0],
            outputDimensions: inputImage.dimensions,
            outputPixelFormat: outputPixelFormat
        )
    }
}
