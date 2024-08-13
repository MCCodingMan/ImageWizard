//
//  IWAssetManager.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/7.
//

import Foundation
import Photos

class IWAssetManager {
    static let shared = IWAssetManager()
    private init() { }
    
    var photos: [PHAsset] = []
    
    func fetchAllPhoto(completeBlock: @escaping (PHAsset) -> ()) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized || status == .limited {
                self.fetchAssets(completeBlock: completeBlock)
            }
        }
    }
    
    private func fetchAssets(completeBlock: @escaping (PHAsset) -> ()) {
        let fetchOptions = PHFetchOptions()
        let assetsFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        assetsFetchResult.enumerateObjects {[self] asset, idx, stop in
            if asset.mediaType == .image {
                photos.append(asset)
                IWImageCachingManager.shared.cacheImage([asset])
                completeBlock(asset)
            }
        }
    }
}
