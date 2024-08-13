//
//  AppPhotoCompatibleModel.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/11.
//

import UIKit
import Photos
import SwiftUI

class AppPhotoAssetModel {
    
    var asset: PHAsset?
    
    init(asset: PHAsset? = nil,
         name: String? = nil,
         originalUIImage: UIImage? = nil,
         originalCGImage: CGImage? = nil,
         originalCIImage: CIImage? = nil,
         originalImageData: Data? = nil,
         movData:Data? = nil) {
        self.asset = asset
        self._name = name
        
        self.originalUIImage = originalUIImage
        self.originalCIImage = originalCIImage
        self.originalImageData = originalImageData
        if let originalCGImage {
            self.originalCGImage = originalCGImage
        }else if let originalImageData {
            self.originalCGImage = originalImageData.cgImage
        }else if let originalCIImage {
            self.originalCGImage = originalCIImage.cgImage
        }else if let originalUIImage {
            self.originalCGImage = originalUIImage.cgImage
        }
        self.movData = movData
    }
    
    /// 缩略图
    var thumbnailUIImage: UIImage?
    var thumbnailCGImage: CGImage?
    var thumbnailCIImage: CIImage?
    var thumbnailImageData: Data?
    
    /// 原图
    var originalUIImage: UIImage? {
        didSet {
            if originalCGImage == nil {
                originalCGImage = originalUIImage?.cgImage
            }
        }
    }
    var originalCGImage: CGImage?
    var originalCIImage: CIImage? {
        didSet {
            if originalCGImage == nil {
                originalCGImage = originalCIImage?.cgImage
            }
        }
    }
    var originalImageData: Data? {
        didSet {
            if originalCGImage == nil {
                originalCGImage = originalImageData?.cgImage
            }
        }
    }
    
    var _name: String?
    
    /// 基本信息
    var name: String {
        get {
            if _name != nil {
                return _name!
            }else{
                if let asset {
                    if let resource = PHAssetResource.assetResources(for: asset).first {
                        return resource.originalFilename
                    }
                }
                return ""
            }
        }
        set {
            _name = newValue
        }
    }
    
    var movData: Data?
    
    var isLivePhoto: Bool {
        if movData != nil {
            return true
        }
        return asset?.mediaSubtypes.contains(.photoLive) ?? false
    }
    var isCache: Bool {
        thumbnailUIImage != nil || thumbnailCGImage != nil || thumbnailCIImage != nil || thumbnailImageData != nil || originalUIImage != nil || originalCGImage != nil || originalCIImage != nil || originalImageData != nil
    }
    
    var isOriginal: Bool {
        originalUIImage != nil || originalCGImage != nil || originalCIImage != nil || originalImageData != nil
    }
    
    var showUIImage: UIImage? {
        originalUIImage ?? thumbnailUIImage
    }
    
    var showCGImage: CGImage? {
        originalCGImage ?? thumbnailCGImage
    }
    
    var showCIImage: CIImage? {
        originalCIImage ?? thumbnailCIImage
    }
    
    var showImageData: Data? {
        originalImageData ?? thumbnailImageData
    }
    
    func obtainThumbanailImage(_ completeBlock: ((CGImage?) -> ())? = nil) {
        if let asset {
            IWImageCachingManager.shared.obtainThumbnailImage(with: asset) {[self] image, info in
                thumbnailUIImage = image
                thumbnailCGImage = image?.cgImage
                completeBlock?(showCGImage)
            }
            
        }else{
            completeBlock?(showCGImage)
        }
    }
    
    func obtainOriginalImage(_ completeBlock: ((CGImage?) -> ())? = nil) {
        if let asset {
            IWImageCachingManager.shared.obtainOriginalImage(with: asset) {[self] imageData, _, orientation, info in
                originalImageData = imageData
                originalCGImage = imageData?.cgImage
                completeBlock?(showCGImage)
            }
        }else{
            completeBlock?(showCGImage)
        }
    }
    
    func convertPhotoToData() throws -> Data {
        var dataDic: [String: Any] = [:]
        dataDic["photo"] = originalImageData
        dataDic["video"] = movData
        dataDic["name"] = name
        let data = try PropertyListSerialization.data(fromPropertyList: dataDic, format: .binary, options: 0)
        return data
    }
    
    static func convertDataToPhoto(_ data: Data) throws -> AppPhotoAssetModel {
        if let dataDic = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
            let model = AppPhotoAssetModel(name: dataDic["name"] as? String, originalImageData: dataDic["photo"] as? Data, movData: dataDic["video"] as? Data)
            return model
        }
        throw ConvertError.error
    }
}

extension AppPhotoAssetModel {
    enum ConvertError: Error {
        case error
    }
}
