//
//  BalanceAdjustType.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/18.
//

import Foundation
import CoreGraphics
import BBMetalImage
enum BalanceAdjustType: CaseIterable, Hashable {
    case auto, candlelight, sunrise, fluorescence, sunny, overcast, moonlight, sunsea, oversea
    
    var name: String {
        switch self {
            case .auto:
                return "自动"
            case .candlelight:
                return "烛光"
            case .sunrise:
                return "日光"
            case .fluorescence:
                return "荧光"
            case .sunny:
                return "晴天"
            case .overcast:
                return "阴天"
            case .moonlight:
                return "月光"
            case .sunsea:
                return "天蓝"
            case .oversea:
                return "海蓝"
        }
    }
    
    var temperature: (temperature: Float, tint: Float) {
        switch self {
            case .auto:
                return (temperature: -1, tint: -1)
            case .candlelight:
                return (temperature: 12000, tint: 0)
            case .sunrise:
                return (temperature: 4000, tint: 0)
            case .fluorescence:
                return (temperature: 5000, tint: 0)
            case .sunny:
                return (temperature: 3800, tint: 0)
            case .overcast:
                return (temperature: 3900, tint: -2)
            case .moonlight:
                return (temperature: 4500, tint: -15)
            case .sunsea:
                return (temperature: 3300, tint: 6)
            case .oversea:
                return (temperature: 2700, tint: 20)
        }
    }
}

enum BBFilterLookUpTable: Hashable, CaseIterable {
    case none, freshy, beauty, sweety, sepia, blue, nostalgia, sakura, sakura_night, ruddy_night, sunshine_night, ruddy, sushine, nature, amatorka, elegance, pink, whitening, ruddy_dim
    
    var name: String {
        switch self {
            case .none:
                return "关"
            case .freshy:
                return "小清新"
            case .beauty:
                return "靓丽"
            case .sweety:
                return "甜美"
            case .sepia:
                return "怀旧"
            case .blue:
                return "蓝调"
            case .nostalgia:
                return "老照片"
            case .sakura:
                return "樱花"
            case .sakura_night:
                return "樱花(暗)"
            case .ruddy_night:
                return "红润(暗)"
            case .sunshine_night:
                return "阳光(暗)"
            case .ruddy:
                return "红润"
            case .sushine:
                return "阳光"
            case .nature:
                return "自然"
            case .amatorka:
                return "恋人"
            case .elegance:
                return "高雅"
            case .pink:
                return "粉嫩"
            case .whitening:
                return "美白"
            case .ruddy_dim:
                return "朦胧"
        }
    }
    
    var sourceName: String {
        var name = ""
        switch self {
            case .none:
                name = ""
            case .freshy:
                name = "1_xiaoqingxin"
            case .beauty:
                name = "2_liangli"
            case .sweety:
                name = "3_tianmeikeren"
            case .sepia:
                name = "4_huaijiu"
            case .blue:
                name = "5_landiao"
            case .nostalgia:
                name = "6_laozhaop"
            case .sakura:
                name = "7_yinghua"
            case .sakura_night:
                name = "8_yinghua_night"
            case .ruddy_night:
                name = "9_hongrun_night"
            case .sunshine_night:
                name = "10_yangguang_night"
            case .ruddy:
                name = "11_hongrun"
            case .sushine:
                name = "12_yangguang"
            case .nature:
                name = "13_ziran"
            case .amatorka:
                name = "14_amatorka"
            case .elegance:
                name = "15_elegance"
            case .pink:
                name = "0_pink"
            case .whitening:
                name = "0_meibai"
            case .ruddy_dim:
                name = "0_hongrun2"
        }
        return name
    }
    
    func filter(with image: CGImage) -> CGImage {
        if self == .none {
            return image
        }else{
            let lookupFilter = BBMetalLookupFilter(lookupTable: UIImage(named: sourceName)!.bb_metalTexture!)
            return image.BBMetalFilter([lookupFilter])
        }
    }
}

enum ImageCropType: Int {
    case image16_9 = 0
    case image4_3
    case image1_1
    
    var ratio: Double {
        switch self {
            case .image16_9:
                return 9.0 / 16.0
            case .image4_3:
                return 3.0 / 4.0
            case .image1_1:
                return 1
        }
    }
    
    var horizontalRatio: Double {
        switch self {
            case .image16_9:
                return 16.0 / 9.0
            case .image4_3:
                return 4.0 / 3.0
            case .image1_1:
                return 1
        }
    }
}
