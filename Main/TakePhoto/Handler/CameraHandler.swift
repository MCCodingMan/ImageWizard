
//
//  IWCameraHandler.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/10.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

class CameraHandler: ObservableObject {
    
    @Published var metalData = MetalBufferDataModel()
    @Published var realTimeImage: CGImage?
    @Published var originalImage: CGImage?
    @Published var takeImageModel: AppPhotoAssetModel?
    @Published var metaFrames: [CGRect] = []
    @Published var sizeSelectedSegment = 0 {
        didSet {
            if let cropType = ImageCropType(rawValue: sizeSelectedSegment) {
                coordinator.cropType = cropType
                camera.updateLayerFrame(with: cropType)
            }
        }
    }
    
    @Published var isBeauty = false {
        didSet {
            coordinator.isBeauty = isBeauty
            if isBeauty {
                isAuto = false
            }
        }
    }
    
    @Published var isAuto = false {
        didSet {
            coordinator.isAuto = isAuto
            if isAuto {
                isBeauty = false
            }
        }
    }
    
    @Published var zoomFactor: CGFloat = 1.0 {
        didSet {
            camera.deviceZoom(with: zoomFactor)
        }
    }
    
    @Published var isLivePhoto: Bool = true {
        didSet {
            coordinator.isLivePhoto = isLivePhoto
            camera.livePhoto = isLivePhoto
        }
    }
    
    var lookUptableName: String = "" {
        didSet {
            coordinator.lookUptableName = lookUptableName
        }
    }
    
    var adjustFilters: [BBMetalFilterType: Float] = [:] {
        didSet {
            coordinator.adjustFilters = adjustFilters
        }
    }
    
    var cameraPositionIsBack = true {
        didSet {
            stopRunning()
            camera.switchCameraPosition()
            startRunning()
        }
    }
    
    var isPortraitCamera = false {
        didSet {
            if isPortraitCamera {
                camera.addPortraitPhotoOutput()
                sizeSelectedSegment = 1
            }else{
                camera.addPhotoOutput()
                sizeSelectedSegment = 0
            }
        }
    }
    
    init() {
        startRunning()
    }
            
    lazy var coordinator = Coordinator(previewImageBlock: {[weak self] image,originalImage  in
        self?.realTimeImage = image
        self?.originalImage = originalImage
    }, takePhotoImageBlock: { [weak self] photoModel in
        self?.takeImageModel = photoModel
    }, metaObjectframes: {[weak self] frames in
        self?.metaFrames = frames
    }, metalBufferData: {[weak self] bufferData in
        self?.metalData = bufferData
    })
    
    lazy var camera = CameraSession(isBack: true, delegate: coordinator)
    
    
    private func dealMetaObjects(_ metaObjects: [AVMetadataObject]) {
        var tempMetaFrames: [CGRect] = []
        for metaObject in metaObjects {
            if let targetFrame = camera.previewPlayer.transformedMetadataObject(for: metaObject)?.bounds {
                tempMetaFrames.append(targetFrame)
            }

        }
        metaFrames = tempMetaFrames
    }
    
    func startRunning() {
        camera.startRunning()
    }
    
    func stopRunning() {
        camera.stopRunning()
    }
    
    func takePhoto() {
        camera.takePhoto()
    }
    
    func focus(at point: CGPoint) {
        camera.focus(at: point)
    }
    
    func adjustFilter(with filterTuple: BBMetalFilterTuple) {
        if filterTuple.offset == 0 {
            adjustFilters.removeValue(forKey: filterTuple.filterType)
        }else{
            adjustFilters[filterTuple.filterType] = filterTuple.offset
        }
    }
    
    func whiteBalance(_ value: (temperature: Float, tint: Float)) {
        camera.whiteBalance(value)
    }
}

