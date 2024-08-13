//
//  CameraSession.swift
//  ImageWizard
//
//  Created by zjkj on 2024/5/25.
//

import AVFoundation
import UIKit

typealias AVCaptureDelegateGroup = AVCapturePhotoCaptureDelegate & AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraHandler {
    class CameraSession {
        
        private let videoOutputQueue = DispatchQueue(label: "VideoQueue")
                
        var isBack: Bool
        
        var livePhoto = true {
            didSet {
                if livePhoto {
                    videoSession.sessionPreset = .photo
                }else{
                    videoSession.sessionPreset = .high
                }
                photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported && livePhoto
            }
        }
        
        weak var delegate: AVCaptureDelegateGroup?
        
        private let videoDataOutput = AVCaptureVideoDataOutput()
        
        private let photoOutput = AVCapturePhotoOutput()
        
        private let portraitPhotoOutput = AVCapturePhotoOutput()
        
        private let depthOutput = AVCaptureDepthDataOutput()
        
        var synOutput: AVCaptureDataOutputSynchronizer?
        
        var currentDevice: AVCaptureDevice!
        
        var outputs: AVCaptureDataOutputSynchronizer?
        
        var videoSession: AVCaptureSession!
        
        lazy var previewPlayer: AVCaptureVideoPreviewLayer = {
            let layer = AVCaptureVideoPreviewLayer(session: videoSession)
            layer.videoGravity = .resizeAspectFill
            return layer
        }()
    
        init(isBack: Bool,
             delegate: AVCaptureDelegateGroup? = nil) {
            self.isBack = isBack
            self.delegate = delegate
            createDevice()
            addVideoOutput()
            addPhotoOutput()
        }
        
        func createDevice() {
            var device: AVCaptureDevice?
            /// builtInTrueDepthCamera前摄像头景深 builtInDualWideCamera后置
            if isBack {
                device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                try? device?.lockForConfiguration()
                /// 自动白平衡
                if device?.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) ?? false {
                    device?.whiteBalanceMode = .continuousAutoWhiteBalance
                }
            }else{
                device = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
                try? device?.lockForConfiguration()
            }
            /// 自动对焦
            if device?.isFocusModeSupported(.continuousAutoFocus) ?? false {
                device?.focusMode = .continuousAutoFocus
            }
            /// 自动曝光
            if device?.isExposureModeSupported(.continuousAutoExposure) ?? false {
                device?.exposureMode = .continuousAutoExposure
            }
            device?.unlockForConfiguration()
            currentDevice = device
            createSession()
        }
        
        func createSession() {
            let captureSession = AVCaptureSession()
            /// 实况照片，只能在Photo模式下工作
            if livePhoto {
                captureSession.sessionPreset = .photo
            }else{
                captureSession.sessionPreset = .high
            }
            if let currentDevice, let input = try? AVCaptureDeviceInput(device: currentDevice) {
                captureSession.addInput(input)
            }
            
            videoSession = captureSession
        }
        
        func switchCameraPosition() {
            isBack.toggle()
            createDevice()
            addVideoOutput()
            addPhotoOutput()
        }
        
        func addVideoOutput() {
            videoSession.beginConfiguration()
            defer {
                videoSession.commitConfiguration()
            }
            if videoSession.canAddOutput(videoDataOutput) {
                videoSession.addOutput(videoDataOutput)
                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                videoDataOutput.setSampleBufferDelegate(delegate, queue: videoOutputQueue)
                defaultRotation(videoDataOutput)
                mirrorDisable(videoDataOutput)
            }
            
        }
        
        
        func addPortraitPhotoOutput() {
            guard let currentDevice else { return }
            videoSession.beginConfiguration()
            defer {
                videoSession.commitConfiguration()
            }
            /// 移除普通拍照输出
            if videoSession.outputs.contains(photoOutput) {
                videoSession.removeOutput(photoOutput)
            }
            
            if videoSession.canAddOutput(portraitPhotoOutput) {
                videoSession.addOutput(portraitPhotoOutput)
                defaultRotation(portraitPhotoOutput)
                mirrorDisable(portraitPhotoOutput)
                portraitPhotoOutput.isDepthDataDeliveryEnabled = portraitPhotoOutput.isDepthDataDeliverySupported
                portraitPhotoOutput.isPortraitEffectsMatteDeliveryEnabled = portraitPhotoOutput.isPortraitEffectsMatteDeliverySupported
                portraitPhotoOutput.enabledSemanticSegmentationMatteTypes = portraitPhotoOutput.availableSemanticSegmentationMatteTypes
            }
            
            if let max = currentDevice.activeFormat.supportedMaxPhotoDimensions.last {
                portraitPhotoOutput.maxPhotoDimensions = max
            }
        }
        
        func addPhotoOutput() {
            guard let currentDevice else { return }
            videoSession.beginConfiguration()
            defer {
                videoSession.commitConfiguration()
            }
            /// 移除人像拍照输出
            if videoSession.outputs.contains(portraitPhotoOutput) {
                videoSession.removeOutput(portraitPhotoOutput)
            }
            
            if videoSession.canAddOutput(photoOutput) {
                videoSession.addOutput(photoOutput)
                defaultRotation(photoOutput)
                mirrorDisable(photoOutput)
                /// 实况
                photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported && livePhoto
                photoOutput.maxPhotoQualityPrioritization = .quality
                if let max = currentDevice.activeFormat.supportedMaxPhotoDimensions.last {
                    photoOutput.maxPhotoDimensions = max
                }
                photoOutput.enabledSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes
                
                if #available(iOS 17.0, *) {
                    photoOutput.isResponsiveCaptureEnabled = photoOutput.isResponsiveCaptureSupported
                    photoOutput.isFastCapturePrioritizationEnabled = photoOutput.isFastCapturePrioritizationSupported
                    photoOutput.isAutoDeferredPhotoDeliveryEnabled = photoOutput.isAutoDeferredPhotoDeliverySupported
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        
        private func defaultRotation(_ output: AVCaptureOutput) {
            if let connection = output.connection(with: .video) {
                if connection.isCameraIntrinsicMatrixDeliverySupported {
                    connection.isCameraIntrinsicMatrixDeliveryEnabled = true
                }
                if #available(iOS 17.0, *) {
                    if connection.isVideoRotationAngleSupported(90) {
                        connection.videoRotationAngle = 90
                    }
                } else {
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                }
            }
        }
        
        private func mirrorDisable(_ output: AVCaptureOutput) {
            guard let currentDevice else { return }
            let currentPosition = currentDevice.position
            if let connection = output.connection(with: .video) {
                if connection.isVideoMirroringSupported {
                    if currentPosition == .unspecified || currentPosition == .front {
                        connection.isVideoMirrored = true
                    }else{
                        connection.isVideoMirrored = false
                    }
                }
            }
        }
        
        func takePhoto() {
            guard let currentDevice else { return }
            DispatchQueue(label: "takePhoto").async {
                let setting = {
                    // Capture HEIF photos when supported.
                    if self.photoOutput.availablePhotoCodecTypes.contains(AVVideoCodecType.hevc) {
                        return AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
                    } else {
                        return AVCapturePhotoSettings()
                    }
                }()
                if currentDevice.isFlashAvailable {
                    setting.flashMode = .auto
                }
                setting.maxPhotoDimensions = self.photoOutput.maxPhotoDimensions
                if !setting.availablePreviewPhotoPixelFormatTypes.isEmpty {
                    setting.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: setting.__availablePreviewPhotoPixelFormatTypes.first!]
                }
                setting.photoQualityPrioritization = self.photoOutput.maxPhotoQualityPrioritization
                if self.livePhoto && self.photoOutput.isLivePhotoCaptureSupported {
                    let livePhotoMovieFileName = UUID().uuidString.components(separatedBy: "-").last!
                    if let livePhotoMovieFilePath = try? LivePhotoSignHandler.liveVideoCacheDirectory().appendingPathComponent(livePhotoMovieFileName).appendingPathExtension("mov") {
                        setting.livePhotoMovieFileURL = livePhotoMovieFilePath
                    }
                }
                setting.embedsDepthDataInPhoto = true
                setting.enabledSemanticSegmentationMatteTypes = self.photoOutput.enabledSemanticSegmentationMatteTypes
                
                self.photoOutput.capturePhoto(with: setting, delegate: self.delegate!)
            }
        }
        
        func portraitTakePhoto() {
            DispatchQueue(label: "takePhoto").async {
                let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
                setting.isDepthDataDeliveryEnabled = self.portraitPhotoOutput.isDepthDataDeliverySupported

                setting.flashMode = .auto
                setting.photoQualityPrioritization = self.portraitPhotoOutput.maxPhotoQualityPrioritization
                setting.embedsDepthDataInPhoto = true
                setting.maxPhotoDimensions = self.portraitPhotoOutput.maxPhotoDimensions
                self.photoOutput.capturePhoto(with: setting, delegate: self.delegate!)
            }
        }
        
        func startRunning() {
            if !videoSession.isRunning {
                DispatchQueue.global().async {
                    self.videoSession.startRunning()
                }
            }
        }
        
        func stopRunning() {
            if videoSession.isRunning {
                videoSession.stopRunning()
            }
        }
        
        func focus(at point: CGPoint) {
            guard let currentDevice else { return }
            do {
                try currentDevice.lockForConfiguration()
                if currentDevice.isFocusPointOfInterestSupported && currentDevice.isFocusModeSupported(.autoFocus) {
                    currentDevice.focusPointOfInterest = point
                    currentDevice.focusMode = .autoFocus
                }
                
                if currentDevice.isExposurePointOfInterestSupported && currentDevice.isExposureModeSupported(.autoExpose) {
                    currentDevice.exposurePointOfInterest = point
                    currentDevice.exposureMode = .autoExpose
                }
                
                currentDevice.isSubjectAreaChangeMonitoringEnabled = true
                currentDevice.unlockForConfiguration()
            } catch { }
        }
        
        func deviceZoom(with factor: CGFloat) {
            guard let currentDevice else { return }
            do {
                try currentDevice.lockForConfiguration()
                currentDevice.videoZoomFactor = max(1, min(factor, currentDevice.activeFormat.videoMaxZoomFactor))
                currentDevice.unlockForConfiguration()
            } catch { }
        }
        
        func whiteBalance(_ value: (temperature: Float, tint: Float)) {
            guard let currentDevice else { return }
            do {
                if value.temperature == -1 {
                    try currentDevice.lockForConfiguration()
                    if currentDevice.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                        currentDevice.whiteBalanceMode = .continuousAutoWhiteBalance
                    }
                    currentDevice.unlockForConfiguration()
                }else {
                    /// 通过色温获取到白平衡值
                    let temperatureAndTintValues = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: value.temperature, tint: value.tint)
                    var whiteBalanceGains = currentDevice.deviceWhiteBalanceGains(for: temperatureAndTintValues)
                    /// 判断获取到的白平衡值是否在1到最大的区间内
                    let maxWhiteBalanceGains = currentDevice.maxWhiteBalanceGain
                    if whiteBalanceGains.blueGain < 1.0 || whiteBalanceGains.blueGain > maxWhiteBalanceGains {
                        if whiteBalanceGains.blueGain < 1.0 {
                            whiteBalanceGains.blueGain = 1.0
                        }else{
                            whiteBalanceGains.blueGain = maxWhiteBalanceGains
                        }
                    }
                    if whiteBalanceGains.redGain < 1.0 || whiteBalanceGains.redGain > maxWhiteBalanceGains {
                        if whiteBalanceGains.redGain < 1.0 {
                            whiteBalanceGains.redGain = 1.0
                        }else{
                            whiteBalanceGains.redGain = maxWhiteBalanceGains
                        }
                    }
                    if whiteBalanceGains.greenGain < 1.0 || whiteBalanceGains.redGain > maxWhiteBalanceGains {
                        if whiteBalanceGains.redGain < 1.0 {
                            whiteBalanceGains.redGain = 1.0
                        }else{
                            whiteBalanceGains.redGain = maxWhiteBalanceGains
                        }
                    }
                    try currentDevice.lockForConfiguration()
                    currentDevice.setWhiteBalanceModeLocked(with: whiteBalanceGains)
                    currentDevice.unlockForConfiguration()
                }
            } catch { }
        }
        
        func updateLayerFrame(with cropType: ImageCropType) {
            let width = IWAppInfo.screenWidth
            let height = IWAppInfo.screenWidth * cropType.horizontalRatio
            let residueHeight = IWAppInfo.screenHeight - IWAppInfo.navigationHeight - IWAppInfo.bottomSafeHeight
            let positiony = (residueHeight - height) / 2
            let size = CGSize(width: width, height: height)
            previewPlayer.frame = CGRect(origin: CGPoint(x: 0, y: positiony), size: size)
        }
        
    }
}
