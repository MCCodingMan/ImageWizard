//
//  IWImageFilterHandler.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/10.
//

import Foundation
import Harbeth
import BBMetalImage
import OpenGLES

class AppMetal {
    
    static let defaultDevice = BBMetalDevice.sharedDevice
    
    static let context = CIContext(mtlDevice: defaultDevice)
}

class IWImageFilterHandler {
    static func corefilter(with image: CGImage, filterName: String) -> CGImage {
        let filter = IWCoreImageFilter.createCIFilter(with: filterName)
        let ciImage = CIImage(cgImage: image)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let outPutImage = filter?.outputImage {
            if let cgImage = outPutImage.costomCGImage {
                return cgImage
            }
        }
        return image
    }
    
}

extension CIImage {
    enum TransitionError: Error {
        case failur
    }
    
    func toMTLTexture(with cropType: ImageCropType, needAdjustOrientation: Bool = false) throws -> MTLTexture {
        
        // 获取 CIImage 的尺寸
        let width = Int(extent.width)
        let height = Int(extent.height)
        
        let imageRatio = Double(width) / Double(height)
        let currenRatio = imageRatio > 1 ? cropType.horizontalRatio : cropType.ratio
        
        // 创建 MTLTextureDescriptor
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .rgba8Unorm
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        
        if imageRatio < 1 {
            if currenRatio > imageRatio {
                textureDescriptor.width = width
                textureDescriptor.height = Int(Double(width) / currenRatio)
            }else{
                textureDescriptor.width = Int(Double(height) * currenRatio)
                textureDescriptor.height = height
            }
        }else{
            if currenRatio > imageRatio {
                textureDescriptor.width = width
                textureDescriptor.height = Int(Double(width) / currenRatio)
            }else{
                textureDescriptor.width = Int(Double(height) * currenRatio)
                textureDescriptor.height = height
            }
        }
        
        
        // 创建 MTLTexture
        if let texture = AppMetal.defaultDevice.makeTexture(descriptor: textureDescriptor) {
            let flippedImage = needAdjustOrientation ? transformed(by: CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -extent.height)) : self
            
            // 渲染 CIImage 到 MTLTexture
            
            let bounds = CGRect(x: (width - textureDescriptor.width) / 2, y: (height - textureDescriptor.height) / 2, width: textureDescriptor.width, height: textureDescriptor.height)
            AppMetal.context.render(flippedImage, to: texture, commandBuffer: nil, bounds: bounds, colorSpace: colorSpace ?? CGColorSpaceCreateDeviceRGB())
            
            return texture
        }
        throw TransitionError.failur
    }
}

extension CIImage {
    
    func applyFilters(with filtersMap: [(filterName: String, filterParam: [String: Any])]) -> Self {
        var ciImage = self
        for filterTup in filtersMap {
            ciImage = ciImage.applyingFilter(filterTup.filterName, parameters: filterTup.filterParam) as! Self
        }
        return ciImage
    }
    
    var costomCGImage: CGImage? {
        AppMetal.context.createCGImage(self, from: extent)
    }
    
    func applyingC7Beauty() -> CIImage {
        self -->>> [C7CombinationBeautiful(smoothDegree: 0.0)]
    }
    
    func applyBeautyFilters() -> CIImage {
        // 创建一个高斯模糊滤镜
           let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
           gaussianBlurFilter?.setValue(self, forKey: kCIInputImageKey)
           gaussianBlurFilter?.setValue(10.0, forKey: kCIInputRadiusKey)  // 调整模糊半径
           
           guard let blurredImage = gaussianBlurFilter?.outputImage else { return self }
           
           // 将模糊图像与原始图像混合
           let blendFilter = CIFilter(name: "CIOverlayBlendMode")
           blendFilter?.setValue(blurredImage, forKey: kCIInputBackgroundImageKey)
           blendFilter?.setValue(self, forKey: kCIInputImageKey)
           
           guard let blendedImage = blendFilter?.outputImage else { return self }

        return blendedImage
    }
    
    func cropImage(with type: ImageCropType) -> CIImage {
        var ratio: Double = 16.0 / 9.0
        switch type {
            case .image16_9:
                ratio = 16.0 / 9.0
            case .image4_3:
                ratio = 4.0 / 3.0
            case .image1_1:
                ratio = 1.0
        }
        let currenRatio = Double(extent.height) / Double(extent.width)
        if ratio < currenRatio {
            let rect = CGRect(x: 0.0, y: 0.0, width: Double(extent.width), height: Double(extent.width) * ratio)
            return cropped(to: rect)
        }else{
            let offsetx = Double(extent.width) - Double(extent.height) / ratio
            let rect = CGRect(x: offsetx / 2, y: 0.0, width: Double(extent.height) / ratio, height: Double(extent.height))
            return cropped(to: rect)
        }
    }
}

extension Data {
    var ciImage: CIImage? {
        CIImage(data: self, options: [.applyOrientationProperty: true, .colorSpace: CGColorSpaceCreateDeviceRGB()])
    }
    
    var cgImage: CGImage? {
        if let source = CGImageSourceCreateWithData(self as CFData, nil) {
            return CGImageSourceCreateImageAtIndex(source, 0, nil)
        }
        return nil
    }
}

extension CGImage {
    
    func applyingC7Beauty() -> CGImage {
        let beauty = CustomBeautyFilter()
        beauty.distanceNormalizationFactor = 8
        beauty.stepOffset = 4.0
        beauty.edgeStrength = 1.0
        beauty.sharpeness = 1.0
        beauty.smoothDegree = 1
        let hsb = CustomHSBFilter()
        hsb.brightness = 1.1
        hsb.saturation = 1.1
        return self ->> beauty ->> hsb
    }
    
    func applyBBMetalBeauty() -> CGImage? {
        let beautyFilter = BBMetalCustomBeautyFilter(distanceNormalizationFactor: 4, stepOffset: 2, edgeStrength: 1, smoothDegree: 0.5, sharpeness: 1, brightness: 1.1, saturation: 1.2, hue: 0)
        return beautyFilter.filteredTexture(with: bb_metalTexture!)?.bb_cgimage
    }
    
    func BBMetalFilter(_ filters: [BBMetalBaseFilter]) -> CGImage {
        guard filters.count > 0 else {
            return self
        }
        let source = BBMetalStaticImageSource(cgimage: self)
        var previewFilter: BBMetalBaseFilter?
        for filter in filters {
            if previewFilter != nil {
                previewFilter!.add(consumer: filter)
            }else{
                source.add(consumer: filter)
            }
            previewFilter = filter
        }
        previewFilter?.runSynchronously = true
        source.transmitTexture()
        if let output = previewFilter?.outputTexture?.bb_cgimage {
            return output
        }
        return self
    }
    
    var uiImage: UIImage {
        var imageOrientation = UIImage.Orientation.up
        switch UIDevice.current.orientation {
            case .landscapeLeft:
                imageOrientation = .left
            case .landscapeRight:
                imageOrientation = .right
            case .portraitUpsideDown:
                imageOrientation = .down
            default:
                imageOrientation = .up
        }
        return UIImage(cgImage: self, scale: 1.0, orientation: imageOrientation)
    }
    
    var imageData: Data? {
        let data = NSMutableData()
        if let destination = CGImageDestinationCreateWithData(data as CFMutableData, UTType.heic.identifier as CFString, 1, nil) {
            CGImageDestinationAddImage(destination, self, nil)
            if CGImageDestinationFinalize(destination) {
                return data as Data
            }
        }
        return nil
    }
    
    func cropImage(with type: ImageCropType) -> CGImage {
        let currenRatio = Double(width) / Double(height)
        if type.ratio > currenRatio {
            let rect = CGRect(x: 0.0, y: 0.0, width: Double(width), height: Double(width) / type.ratio)
            if let image = cropping(to: rect) {
                return image
            }
        }else{
            let offsetx = Double(width) - Double(height) * type.ratio
            let rect = CGRect(x: offsetx / 2, y: 0.0, width: Double(height) * type.ratio, height: Double(height))
            if let image = cropping(to: rect) {
                return image
            }
        }
        return self
    }
}

extension UIImage {
    
    var customCIImage: CIImage? {
        CIImage(image: self, options: [.applyOrientationProperty: true, .colorSpace: CGColorSpaceCreateDeviceRGB()])
    }
    
    var imageSource: BBMetalStaticImageSource {
        BBMetalStaticImageSource(image: self)
    }
    
    func BBMetalFilter(_ filters: [BBMetalBaseFilter]) -> UIImage {
        guard filters.count > 0 else {
            return self
        }
        let source = BBMetalStaticImageSource(image: self)
        var previewFilter: BBMetalBaseFilter?
        for filter in filters {
            if previewFilter != nil {
                previewFilter!.add(consumer: filter)
            }else{
                source.add(consumer: filter)
            }
            previewFilter = filter
        }
        previewFilter?.runSynchronously = false
        source.transmitTexture()
        if let output = previewFilter?.outputTexture?.bb_image {
            return output
        }
        return self
    }
    
    func BBMetalFilter(_ filters: [BBMetalBaseFilter], completeBlock: @escaping (_ outputImage: UIImage) -> ()) {
        guard filters.count > 0 else {
            completeBlock(self)
            return
        }
        
        var previewFilter: BBMetalBaseFilter?
        for filter in filters {
            if previewFilter != nil {
                previewFilter!.add(consumer: filter)
            }else{
                imageSource.add(consumer: filter)
            }
            previewFilter = filter
        }
        previewFilter?.addCompletedHandler { output in
            switch output.result {
                case .success(let texture):
                    completeBlock(texture.bb_image ?? self)
                case .failure(_):
                    completeBlock(self)
            }
        }
        imageSource.transmitTexture()
    }
}

extension UIImage {
    
    typealias ImageFilterBlock = (UIImage) -> ()
    
    func filter(_ filters: [IWFilterType]) -> UIImage {
        self -->>> filters.map({$0.filter()})
    }
    
    func filter(_ filters: [C7FilterProtocol]) -> UIImage {
        self -->>> filters
    }
    
    func asyncFilter(_ filters: [IWFilterType], filterBlock: @escaping ImageFilterBlock) {
        let dest = HarbethIO(element: self, filters: filters.map({$0.filter()}))
        dest.transmitOutput { image in
            DispatchQueue.main.async {
                filterBlock(image)
            }
        }
    }
    
    func asyncFilter(_ filters: [C7FilterProtocol], filterBlock: @escaping ImageFilterBlock) {
        let dest = HarbethIO(element: self, filters: filters)
        dest.transmitOutput { image in
            DispatchQueue.main.async {
                filterBlock(image)
            }
        }
    }
    
}

extension CMSampleBuffer {
    func soulOutFilter(_ soul: Float = 0.5) -> UIImage? {
        filter([C7SoulOut(soul: soul)])
    }
}

extension CMSampleBuffer {
    func filter(_ filters: [IWFilterType]) -> UIImage? {
        let buffer = self -->>> filters.map({$0.filter()})
        return buffer.c7.toImage()
    }
    
    func filter(_ filters: [C7FilterProtocol]) -> UIImage? {
        let buffer = self -->>> filters
        return buffer.c7.toImage()
    }
    
    func asyncFilter(_ filters: [IWFilterType], filterBlock: @escaping UIImage.ImageFilterBlock) {
        let dest = HarbethIO(element: self, filters: filters.map({$0.filter()}))
        dest.transmitOutput { buffer in
            if let image = buffer.c7.toImage() {
                DispatchQueue.main.async {
                    filterBlock(image)
                }
            }
        }
    }
    
    func asyncFilter(_ filters: [C7FilterProtocol], filterBlock: @escaping UIImage.ImageFilterBlock) {
        let dest = HarbethIO(element: self, filters: filters)
        dest.transmitOutput { buffer in
            if let image = buffer.c7.toImage() {
                DispatchQueue.main.async {
                    filterBlock(image)
                }
            }
        }
    }
}

extension CVPixelBuffer {
  
  func clamp() {
    
    let width = CVPixelBufferGetWidth(self)
    let height = CVPixelBufferGetHeight(self)
    
      CVPixelBufferLockBaseAddress(self, .readOnly)
    let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
    
    for y in 0 ..< height {
      for x in 0 ..< width {
        let pixel = floatBuffer[y * width + x]
        floatBuffer[y * width + x] = min(1.0, max(pixel, 0.0))
      }
    }
    
      CVPixelBufferUnlockBaseAddress(self, .readOnly)
  }
}
