//
//  CameraCoordinator.swift
//  ImageWizard
//
//  Created by zjkj on 2024/5/25.
//

import AVFoundation
import CoreImage
import BBMetalImage
import Photos

extension CameraHandler {
    class Coordinator: NSObject {
        var previewImageBlock: (_ filterImage:CGImage?,_ originalImage:CGImage?) -> ()
        var takePhotoImageBlock: (AppPhotoAssetModel) -> ()
        var metaObjectframes: (([CGRect]) -> ())?
        var metalBufferData: ((MetalBufferDataModel) -> ())?
        var isBeauty = false
        var isAuto = false
        var cropType: ImageCropType = .image16_9
        
        var adjustFilters: [BBMetalFilterType: Float] = [:]
        
        var lookUptableName: String = ""
        
        var isLivePhoto = true
        
        var takePhotoModel: AppPhotoAssetModel?
        
        let semaphore = DispatchSemaphore(value: 1)
    
        init(previewImageBlock: @escaping (_: CGImage?, _: CGImage?) -> Void,
             takePhotoImageBlock: @escaping (AppPhotoAssetModel) -> Void,
             metaObjectframes: (([CGRect]) -> Void)? = nil,
             metalBufferData: ((MetalBufferDataModel) -> ())? = nil) {
            self.previewImageBlock = previewImageBlock
            self.takePhotoImageBlock = takePhotoImageBlock
            self.metaObjectframes = metaObjectframes
            self.metalBufferData = metalBufferData
        }
    }
}

extension CameraHandler.Coordinator {
    
    private func faceMetaMonitor(with ciImage: CIImage) {
        /// 人脸检测
        let filter = CIDetector(ofType: CIDetectorTypeFace, context: AppMetal.context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        // 从CVPixelBuffer创建CIImage
        if let features = filter?.features(in: ciImage) as? [CIFaceFeature] {
            let scale = ciImage.extent.width / IWAppInfo.screenWidth
            var rects: [CGRect] = []
            for feature in features {
                let newRect = CGRect(x: feature.bounds.origin.x / scale, y: (ciImage.extent.height - feature.bounds.origin.y - feature.bounds.size.height) / scale, width: feature.bounds.size.width / scale, height: feature.bounds.size.height / scale)
                rects.append(newRect)
            }
            DispatchQueue.main.async {
                self.metaObjectframes?(rects)
            }
        }
    }
    
    /// iPhone自动调整滤镜
    @discardableResult
    private func autoAdjust(with ciImage: CIImage) -> CIImage {
        var tempImage = ciImage
        let filters = tempImage.autoAdjustmentFilters()
        for filter in filters {
            filter.setValue(tempImage, forKey: kCIInputImageKey)
            tempImage = filter.outputImage ?? tempImage
        }
        return tempImage
    }
    
    @discardableResult
    private func customAdjust(with image: CIImage, needAdjustOrientation: Bool = true) throws -> MTLTexture {
        semaphore.wait()
        defer { semaphore.signal() }
        let texture = try image.toMTLTexture(with: cropType, needAdjustOrientation: needAdjustOrientation)
        let source = BBMetalStaticImageSource(texture: texture)
        var previewFilter: BBMetalBaseFilter?
        /// 滤镜
        if !lookUptableName.isEmpty, let texture = UIImage(named: lookUptableName)?.bb_metalTexture {
            let lookup = BBMetalLookupFilter(lookupTable: texture)
            source.add(consumer: lookup)
            previewFilter = lookup
        }
        for (key, value) in adjustFilters {
            let filter = key.filter(with: value)
            if previewFilter != nil {
                previewFilter!.add(consumer: filter)
            }else{
                source.add(consumer: filter)
            }
            previewFilter = filter
        }
        
        // 美颜效果是否开启
        if isBeauty {
            let beautyFilter = BBMetalCustomBeautyFilter(distanceNormalizationFactor: 4, stepOffset: 2, edgeStrength: 1, smoothDegree: 0.5, sharpeness: 1, brightness: 1.1, saturation: 1.2, hue: 0)
            if previewFilter != nil {
                previewFilter!.add(consumer: beautyFilter)
            }else{
                source.add(consumer: beautyFilter)
            }
            previewFilter = beautyFilter
        }
        
        previewFilter?.runSynchronously = true
        source.transmitTexture()
        if let output = previewFilter?.outputTexture {
            return output
        }else{
            return texture
        }
    }
    
    
    func processSampleBufferData(_ sampleBuffer: CMSampleBuffer) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: [.applyOrientationProperty: true, .colorSpace: CGColorSpaceCreateDeviceRGB()])
        
        faceMetaMonitor(with: ciImage)
        var autoAdjustCIImage = ciImage//.cropImage(with: cropType)
        if isAuto {
            autoAdjustCIImage = autoAdjust(with: autoAdjustCIImage)
        }
        
        let outTexture = try? customAdjust(with: autoAdjustCIImage)
        let bufferData = MetalBufferDataModel(texture: outTexture)
        DispatchQueue.main.async {
            self.metalBufferData?(bufferData)
        }
    }
}

extension CameraHandler.Coordinator: AVCaptureVideoDataOutputSampleBufferDelegate {
            
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        processSampleBufferData(sampleBuffer)
    }
}

extension CameraHandler.Coordinator: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        photoOutput(with: imageData)
    }
    /// 视频已经写入到沙盒内，可以读取视频。
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: (any Error)?) {
        if error == nil {
            if self.takePhotoModel == nil {
                self.takePhotoModel = AppPhotoAssetModel(name: "IMG\(Int(Date().timeIntervalSince1970 * 1000))")
            }

            if let movData = try? Data(contentsOf: outputFileURL) {
                self.takePhotoModel?.movData = movData
            }
            try? FileManager.default.removeItem(at: outputFileURL)
        }
    }
    /// 表示完成整段视频的记录，但此时还没写入到沙盒里；
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
    }
    
    @available(iOS 17.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCapturingDeferredPhotoProxy deferredPhotoProxy: AVCaptureDeferredPhotoProxy?, error: (any Error)?) {
        
        guard let imageData = deferredPhotoProxy?.fileDataRepresentation() else {
            return
        }
        photoOutput(with: imageData)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: (any Error)?) {
        DBManager.insert(photo: PhotoInfoTuple(name: takePhotoModel!.name, imageData: takePhotoModel!.originalImageData!, movData: takePhotoModel!.movData))
        DispatchQueue.main.async {
            self.takePhotoImageBlock(self.takePhotoModel!)
            self.takePhotoModel = nil
        }
    }
    
    func photoOutput(with imageData: Data) {
        if self.takePhotoModel == nil {
            self.takePhotoModel = AppPhotoAssetModel(name: "IMG\(Int(Date().timeIntervalSince1970 * 1000))")
        }
        
        if let ciImage = imageData.ciImage {
            var autoAdjustCIImage = ciImage
            switch UIDevice.current.orientation {
                case .portraitUpsideDown:
                    autoAdjustCIImage = autoAdjustCIImage.transformed(by: autoAdjustCIImage.orientationTransform(for: .down))
                case .landscapeLeft:
                    autoAdjustCIImage = autoAdjustCIImage.transformed(by: autoAdjustCIImage.orientationTransform(for: .left))
                case .landscapeRight:
                    autoAdjustCIImage = autoAdjustCIImage.transformed(by: autoAdjustCIImage.orientationTransform(for: .right))
                default:
                    break
            }
            
            if isAuto {
                autoAdjustCIImage = autoAdjust(with: ciImage)
            }
            let outCGImage = try? customAdjust(with: autoAdjustCIImage, needAdjustOrientation: true).bb_cgimage
            
            if let resultData = outCGImage?.imageData {
                self.takePhotoModel?.originalImageData = resultData
            }
        }
    }
}
