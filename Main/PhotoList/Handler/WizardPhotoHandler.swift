//
//  WizardPhotoHandler.swift
//  ImageWizard
//
//  Created by zjkj on 2024/5/31.
//

import Photos

class SystemAlbumModel {
    var name: String
    var assets: [AppPhotoAssetModel]
    var title: String {
        name + "(\(assets.count))"
    }
    var coverImage: CGImage?
    
    init(name: String, assets: [AppPhotoAssetModel], coverImage: CGImage? = nil) {
        self.name = name
        self.assets = assets
        if coverImage != nil {
            self.coverImage = coverImage
        }else{
            fetchCover()
        }
    }
    
    func fetchCover() {
        assets.first!.obtainThumbanailImage {[weak self] image in
            self?.coverImage = image
        }
    }
}

class WizardPhotoHandler {
    static let shared = WizardPhotoHandler()
    
    private init() { 
        
    }
    
    func fetchAlbumsAndPhotoCounts(completion: @escaping ([SystemAlbumModel]) -> Void) {
        // 请求相册访问权限
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
                case .authorized:
                    var albums: [SystemAlbumModel] = []
                    
                    // Fetching all user albums
                    let userAlbumsOptions = PHFetchOptions()
                    let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: userAlbumsOptions)
                    
                    userAlbums.enumerateObjects { (collection, _, _) in
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                        let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                        if assets.count > 0 {
                            var assetArray: [AppPhotoAssetModel] = []
                            assets.enumerateObjects { asset, _, _ in
                                assetArray.append(AppPhotoAssetModel(asset: asset))
                            }
                            let album = SystemAlbumModel(name: collection.localizedTitle ?? "Unknown", assets: assetArray)
                            albums.append(album)
                        }
                    }
                    
                    // Fetching all smart albums (like Favorites, Recently Added, etc.)
                    let smartAlbumsOptions = PHFetchOptions()
                    let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: smartAlbumsOptions)
                    
                    smartAlbums.enumerateObjects { (collection, _, _) in
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                        let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                        if assets.count > 0 {
                            var assetArray: [AppPhotoAssetModel] = []
                            assets.enumerateObjects { asset, _, _ in
                                assetArray.append(AppPhotoAssetModel(asset: asset))
                            }
                            let album = SystemAlbumModel(name: collection.localizedTitle ?? "Unknown", assets: assetArray )
                            albums.append(album)
                        }
                    }
                    albums.sort(by: {$0.assets.count > $1.assets.count})
                    completion(albums)
                case .denied, .restricted:
                    print("没有访问权限")
                case .notDetermined:
                    print("权限未确定")
                case .limited:
                    print("限制访问")
                @unknown default:
                    fatalError("未知的权限状态")
            }
        }
    }
    
    
    func fetchSmartAlbums(completion: @escaping ([CGImage]) -> Void) {
        DispatchQueue.global().async {
            let smartAlbumsOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: smartAlbumsOptions)
            var index = 0
            var assetsArray: [PHAsset] = []
            smartAlbums.enumerateObjects { (collection, _, ablumStop) in
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                if assets.count > 0 {
                    assets.enumerateObjects { asset, _, assetStop in
                        index += 1
                        assetsArray.append(asset)
                        if index >= 10 {
                            assetStop.pointee = true
                            ablumStop.pointee = true
                        }
                    }
                }
            }
            var images: [CGImage] = []
            let dispatchGroup = DispatchGroup()
            assetsArray.forEach {
                dispatchGroup.enter()
                IWImageCachingManager.shared.obtainHomeThumbnailImage(with: $0, completeBlock: { image, _ in
                    defer { dispatchGroup.leave() }
                    if let image {
                        images.append(image)
                    }
                })
            }
            dispatchGroup.notify(queue: .main) {
                completion(images)
            }
        }
    }
}
