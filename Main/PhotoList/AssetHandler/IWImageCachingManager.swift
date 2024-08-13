//
//  IWImageCachingManager.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/7.
//

import Photos
import UIKit

class IWImageCachingManager {
    
    typealias ImageBlock = (CGImage?, PHAsset) -> ()
    
    static let shared = IWImageCachingManager()
    private init() { }
    
    private let imageCache = PHCachingImageManager()
    
    lazy var imageOptions = {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isNetworkAccessAllowed = true
        imageRequestOptions.version = .current
        imageRequestOptions.resizeMode = .fast
        imageRequestOptions.deliveryMode = .highQualityFormat
        imageRequestOptions.isSynchronous = false
        return imageRequestOptions
    }()
    
    lazy var imageOriginalOptions = {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isNetworkAccessAllowed = true
        imageRequestOptions.version = .current
        return imageRequestOptions
    }()
    
    
    func cacheImage(_ assets: [PHAsset]) {
        imageCache.startCachingImages(for: assets, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: imageOptions)
    }
    
    func requestLowImage(with asset: PHAsset, completeBlock: @escaping ImageBlock) {
        imageCache.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: imageOptions) { image, _ in
            autoreleasepool {
                let cgImage = image?.cgImage
                completeBlock(cgImage, asset)
            }
        }
        
    }
    
    func requestOriginalImage(with asset: PHAsset, completeBlock: @escaping ImageBlock) {
        imageCache.requestImageDataAndOrientation(for: asset, options: imageOriginalOptions) { imageData, _, _, _ in
            autoreleasepool {
                completeBlock(imageData?.cgImage, asset)
            }
        }
    }
    
    func obtainThumbnailImage(with asset: PHAsset, completeBlock: @escaping (UIImage?, [AnyHashable : Any]?) -> ()) {
        imageCache.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: imageOptions) { uiImage, info in
            autoreleasepool {
                completeBlock(uiImage, info)
            }
        }
    }
    
    func obtainHomeThumbnailImage(with asset: PHAsset, completeBlock: @escaping ImageBlock) {
        imageCache.requestImage(for: asset, targetSize: CGSize(width: 400, height: 400), contentMode: .aspectFill, options: imageOptions) { uiImage, info in
            autoreleasepool {
                let cgImage = uiImage?.cgImage
                completeBlock(cgImage, asset)
            }
        }
    }
    
    func obtainOriginalImage(with asset: PHAsset, completeBlock: @escaping (Data?, String?, CGImagePropertyOrientation, [AnyHashable : Any]?) -> Void) {
        imageCache.requestImageDataAndOrientation(for: asset, options: imageOriginalOptions) { data, str, orientation, info in
            autoreleasepool {
                completeBlock(data, str, orientation, info)
            }
        }
    }
}
