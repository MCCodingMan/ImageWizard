//
//  IWEditImageViewModel.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/26.
//

import Foundation
import UIKit
import BBMetalImage

class WizardEditImageViewModel: ObservableObject {
    
    typealias bbMetalFilterTuple = (type: BBMetalFilterType, offsetValue: Float)
    
    var adjustBBFilterTupleList: [bbMetalFilterTuple] = []
    /// 上一次调整的原图
//    var lastAdjustImage: CGImage?
    /// 上一次调整的滤镜
//    var lastFilter: bbMetalFilterTuple?
        
    @Published var outputImage: CGImage?
    
    var originalTexture: MTLTexture?
    
    var originalImage: CGImage? {
        didSet {
            originalTexture = originalImage?.bb_metalTexture
            outputImage = originalImage
//            lastAdjustImage = originalImage
        }
    }
    
    
    func addBBMetalFilterType(with filterType: BBMetalFilterType, offset: Float) {
        var isContainsFilter = false
        for (idx, tuple) in adjustBBFilterTupleList.enumerated() {
            if tuple.type == filterType {
                if round(offset) != 0 {
                    adjustBBFilterTupleList[idx] = (type: filterType, offsetValue: offset)
                    isContainsFilter = true
                }else{
                    adjustBBFilterTupleList.remove(at: idx)
                    isContainsFilter = false
                }
                break
            }
        }
        if !isContainsFilter && round(offset) != 0 {
            adjustBBFilterTupleList.append((type: filterType, offsetValue: offset))
        }
        guard adjustBBFilterTupleList.count > 0 else {
            outputImage = nil
            return
        }
        let filters = adjustBBFilterTupleList.map({$0.type.filter(with: $0.offsetValue)})
        if let originalTexture {
            let source = BBMetalStaticImageSource(texture: originalTexture)
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
            outputImage = previewFilter?.outputTexture?.bb_cgimage
        }
    }
    
//    func addFilter(with filterType: BBMetalFilterType, offset: Float) {
//        if filterType == lastFilter?.type {
//            /// 如果当前调整的滤镜和上一次调整的滤镜相同，那就从上一次调整过后的图片基础上再调整
//            if round(offset) != 0 {
//                let filter = filterType.filter(with: offset)
//                outputImage = lastAdjustImage?.BBMetalFilter([filter])
//            }else{
//                outputImage = lastAdjustImage
//            }
//        }else{
//            /// 如果不相同
//            /// 判断滤镜中是否包含当前的滤镜
//            /// 如果当前滤镜中不包含要调整的滤镜，那就先更新滤镜数组，把上一个调整的滤镜添加进来，并更新上一次图片为当前图片
//            if !adjustBBFilterTupleList.contains(where: {$0.type == filterType}) {
//                /// 如果不包含当前调整的滤镜，那就先添加上一次调整的滤镜并且更新上一次调整的滤镜图片，
//                if let lastFilter, round(lastFilter.offsetValue) != 0 {
//                    adjustBBFilterTupleList.append(lastFilter)
//                    lastAdjustImage = outputImage
//                }
//            }else{
//                /// 这里说明这个 滤镜已经调整过，所以这个时候需要把上一次调整的图片重新添加一次滤镜
//                adjustBBFilterTupleList.removeAll(where: {$0.type == filterType})
//                let filters = adjustBBFilterTupleList.map({$0.type.filter(with: $0.offsetValue)})
//                lastAdjustImage = originalImage?.BBMetalFilter(filters)
//            }
//        }
//        lastFilter = bbMetalFilterTuple(type: filterType, offsetValue: offset)
//    }
}
