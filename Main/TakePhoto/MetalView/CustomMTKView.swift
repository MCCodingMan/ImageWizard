//
//  CustomMTKView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/5/27.
//

import UIKit
import MetalKit
import AVFoundation


struct MetalBufferDataModel {
    
    var videoDataBuffer: CMSampleBuffer?
    var texture: MTLTexture?
    var renderImage: CIImage?
    
    init(videoDataBuffer: CMSampleBuffer? = nil, texture: MTLTexture? = nil, renderImage: CIImage? = nil) {
        self.videoDataBuffer = videoDataBuffer
        self.texture = texture
        self.renderImage = renderImage
    }
}


class CustomMTKView: MTKView, MTKViewDelegate {
    private var textureCache: CVMetalTextureCache!
    private var metalQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var currentTexture: MTLTexture?
//    private var maskTexture: MTLTexture?
    private var depthState: MTLDepthStencilState!
    
    private let vertexData: [Float] = [-1, -1, 1, 1,
                                        1, -1, 1, 0,
                                        -1,  1, 0, 1,
                                        1,  1, 0, 0]
    
    var bufferData = MetalBufferDataModel()

    override init(frame: CGRect, device: MTLDevice?) {
        super.init(frame: frame, device: device)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        delegate = self
        preferredFramesPerSecond = 60
        isOpaque = true
        framebufferOnly = false
        clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        enableSetNeedsDisplay = false
        colorPixelFormat = .bgra8Unorm
        depthStencilPixelFormat = .depth32Float
        contentMode = .scaleAspectFill
        setUpMtkInfo()
    }
    
    func setUpMtkInfo() {
        if let defaultDevice = device {
            self.device = defaultDevice
            if let queue = defaultDevice.makeCommandQueue() {
                metalQueue = queue
            }else{
                print("metalQueue初始化失败")
            }
            let library = defaultDevice.makeDefaultLibrary()
            if library == nil {
                print("library初始化失败")
            }
            let vertexFunction = library!.makeFunction(name: "vertexShader")
            let fragmentFunction = library!.makeFunction(name: "fragmentShader")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.colorAttachments[0].pixelFormat = self.colorPixelFormat
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.vertexDescriptor = createPlaneMetalVertexDescriptor()
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            
            pipelineState = try? defaultDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
            let depthDescriptor = MTLDepthStencilDescriptor()
            depthDescriptor.isDepthWriteEnabled = true
            depthDescriptor.depthCompareFunction = .less
            depthState = defaultDevice.makeDepthStencilState(descriptor: depthDescriptor)
            CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, defaultDevice, nil, &textureCache)
        }else{
            print("device初始化失败")
        }
    }
    
    /// The app uses a quad to draw a texture onscreen. It creates an `MTLVertexDescriptor` for this case.
    func createPlaneMetalVertexDescriptor() -> MTLVertexDescriptor {
        let mtlVertexDescriptor: MTLVertexDescriptor = MTLVertexDescriptor()
        // Store position in `attribute[[0]]`.
        mtlVertexDescriptor.attributes[0].format = .float2
        mtlVertexDescriptor.attributes[0].offset = 0
        mtlVertexDescriptor.attributes[0].bufferIndex = 0
        
        // Store texture coordinates in `attribute[[1]]`.
        mtlVertexDescriptor.attributes[1].format = .float2
        mtlVertexDescriptor.attributes[1].offset = MemoryLayout<SIMD2<Float>>.stride
        mtlVertexDescriptor.attributes[1].bufferIndex = 0
        
        // Set stride to twice the `float2` bytes per vertex.
        mtlVertexDescriptor.layouts[0].stride = 2 * MemoryLayout<SIMD2<Float>>.stride
        mtlVertexDescriptor.layouts[0].stepRate = 1
        mtlVertexDescriptor.layouts[0].stepFunction = .perVertex
        
        return mtlVertexDescriptor
    }
    
    
    func updateTexture() {
        if let texture = bufferData.texture {
            currentTexture = texture
        }else if let imageBuffer = bufferData.videoDataBuffer {
            currentTexture = updateCurrentTexture(CMSampleBufferGetImageBuffer(imageBuffer))
        }
    }
    
    func updateCurrentTexture(_ pixelBuffer: CVPixelBuffer?) -> MTLTexture? {
        guard let pixelBuffer else {
            return nil
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var textureRef: CVMetalTexture?
        var texture: MTLTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, pixelBuffer, nil, .bgra8Unorm, width, height, 0, &textureRef)
        if result == kCVReturnSuccess, let textureRef {
            texture = CVMetalTextureGetTexture(textureRef)
        }
        return texture
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    lazy var context = CIContext(mtlCommandQueue: self.metalQueue)
    
    func draw(in view: MTKView) {
        updateTexture()
        guard let drawable = view.currentDrawable else { return }
        guard let commandBuffer = metalQueue.makeCommandBuffer() else { return }
        if let renderImage = bufferData.renderImage {
            drawableSize = renderImage.extent.size
            context.render(renderImage, to: drawable.texture, commandBuffer: commandBuffer, bounds: renderImage.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
        }else{
            guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
            
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.setDepthStencilState(depthState)
                renderEncoder.setRenderPipelineState(pipelineState)
                
                renderEncoder.setVertexBytes(vertexData, length: vertexData.count * MemoryLayout<Float>.stride, index: 0)
                renderEncoder.setFragmentTexture(currentTexture, index:0)
//                renderEncoder.setFragmentTexture(maskTexture, index: 1)
                renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
                renderEncoder.endEncoding()
            }
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
