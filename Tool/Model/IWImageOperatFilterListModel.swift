//
//  IWImageOperatFilterListModel.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/23.
//

import SwiftUI
import CoreImage
import BBMetalImage

//enum IWOperationFilter: String, Hashable, CaseIterable {
//    case exposure = "曝光"
//    case gama = "伽马"
//    case hightlight = "高光"
//    case shadow = "阴影"
//    case contrast = "对比度"
//    case brightness = "亮度"
//    case saturability = "饱和度"
//    case vibrance = "自然饱和度"
//    case colorTemperature = "色温"
//    case hue = "色调"
//    case acutance = "锐度"
//    case definition = "清晰度"
//    case noisyPoint = "噪点消除"
//    
//    enum SliderPositon {
//        case min
//        case max
//        case mid
//    }
//    
//    var imageName: String {
//        switch self {
//            case .exposure:
//                return "plusminus.circle"
//            case .gama:
//                return "sun.max.circle"
//            case .hightlight:
//                return "circle.lefthalf.striped.horizontal"
//            case .shadow:
//                return "circle.lefthalf.filled.righthalf.striped.horizontal"
//            case .contrast:
//                return "circle.lefthalf.filled"
//            case .brightness:
//                return "sun.min"
//            case .saturability:
//                return "circle.fill"
//            case .vibrance:
//                return "lightspectrum.horizontal"
//            case .colorTemperature:
//                return "thermometer.medium"
//            case .hue:
//                return "drop"
//            case .acutance:
//                return "righttriangle.fill"
//            case .definition:
//                return "righttriangle.split.diagonal"
//            case .noisyPoint:
//                return "circle.bottomrighthalf.checkered"
//        }
//    }
//    
//    var filterMapKey : (filterName: String, filterKey: String) {
//        switch self {
//            case .exposure:
//                return ("CIExposureAdjust", "inputEV") // 默认值0.5 s.rgb * pow(2.0, ev)
//            case .gama:
//                return ("CIGammaAdjust", "inputPower") // 默认值：0.75
//            case .hightlight:
//                return ("CIHighlightShadowAdjust", "inputHighlightAmount") // 默认 1.0
//            case .shadow:
//                return ("CIHighlightShadowAdjust", "inputShadowAmount")
//            case .contrast:
//                return ("CIColorControls", "inputContrast") // 默认 1.0
//            case .brightness:
//                return ("CIColorControls", "inputBrightness")
//            case .saturability:
//                return ("CIColorControls", "inputSaturation")
//            case .vibrance:
//                return ("CIVibrance", "inputAmount")
//            case .colorTemperature:
//                return ("CITemperatureAndTint", "inputTargetNeutral")
//            case .hue:
//                return ("CIHueAdjust", "inputAngle") //0.0
//            case .acutance:
//                return ("CISharpenLuminance", "inputSharpness") //0.4
//            case .definition:
//                return ("CINoiseReduction", "inputSharpness") //0.0
//            case .noisyPoint:
//                return ("CINoiseReduction", "inputNoiseLevel") //0.0
//                
//        }
//    }
//    
//    static var defaultValue: [String: Int] {
//        var defaultMap: [String: Int] = [:]
//        for subCase in allCases {
//            defaultMap[subCase.rawValue] = 0
//        }
//        return defaultMap
//    }
//    
//    var position: SliderPositon {
//        switch self {
//            case .exposure:
//                return .mid
//            case .gama:
//                return .mid
//            case .hightlight:
//                return .mid
//            case .shadow:
//                return .mid
//            case .contrast:
//                return .mid
//            case .brightness:
//                return .mid
//            case .saturability:
//                return .mid
//            case .vibrance:
//                return .mid
//            case .colorTemperature:
//                return .mid
//            case .hue:
//                return .mid
//            case .acutance:
//                return .min
//            case .definition:
//                return .min
//            case .noisyPoint:
//                return .min
//        }
//    }
//    
//    func filterParam(with value: CGFloat) -> [String : Any] {
//        let filteName = filterMapKey.filterKey
//        switch self {
//            case .exposure:
//                return [filteName : NSNumber(value: value / 40.0 + 0.5)]
//            case .gama:
//                if value < 0 {
//                    return [filteName : NSNumber(value: 1.0 - value / 200.0)]
//                }else{
//                    return [filteName : NSNumber(value: 1.0 - value / 200.0)]
//                }
//            case .hightlight:
//                return [filteName : NSNumber(value: value / 20.0 + 1.0)]
//            case .shadow:
//                return [filteName : NSNumber(value: value / 50.0)]
//            case .contrast:
//                return [filteName : NSNumber(value: value / 800.0 + 1.0)]
//            case .brightness:
//                return [filteName : NSNumber(value: value / 200.0)]
//            case .saturability:
//                return [filteName : NSNumber(value: value / 100.0 + 1.0)]
//            case .vibrance:
//                return [filteName : NSNumber(value: value / 100.0)]
//            case .colorTemperature:
//                return [filteName : CIVector(x: -value * 45 + 6500, y: 0)]
//            case .hue:
//                return [filteName : NSNumber(value: -value / 100.0)]
//            case .acutance:
//                return [filteName : NSNumber(value: value / 25.0 + 0.4)]
//            case .definition:
//                return [filteName : NSNumber(value: value / 25.0 + 0.4)]
//            case .noisyPoint:
//                return [filteName : NSNumber(value: -value / 5000.0 + 0.02)]
//        }
//    }
//    
//    func filter(with value: Int) -> CIFilter? {
//        let filterTuple = filterMapKey
//        let filter = CIFilter(name: filterTuple.filterName)
//        switch self {
//            case .exposure:
//                filter?.setValue(NSNumber(value: Double(value) / 40.0 + 0.5), forKey: filterTuple.filterKey)
//            case .gama:
//                if value < 0 {
//                    filter?.setValue(NSNumber(value: -Double(value) / 80.0 + 0.75), forKey: filterTuple.filterKey)
//                }else{
//                    filter?.setValue(NSNumber(value: -Double(value) / 400.0 + 0.75), forKey: filterTuple.filterKey)
//                }
//            case .hightlight:
//                filter?.setValue(NSNumber(value: Double(value) / 20.0 + 1.0), forKey: filterTuple.filterKey)
//            case .shadow:
//                filter?.setValue(NSNumber(value: Double(value) / 50.0), forKey: filterTuple.filterKey)
//            case .contrast:
//                filter?.setValue(NSNumber(value: Double(value) / 50.0), forKey: filterTuple.filterKey)
//            case .brightness:
//                filter?.setValue(NSNumber(value: Double(value) / 80.0), forKey: filterTuple.filterKey)
//            case .saturability:
//                filter?.setValue(NSNumber(value: Double(value) / 100.0 + 1.0), forKey: filterTuple.filterKey)
//            case .vibrance:
//                filter?.setValue(NSNumber(value: Double(value) / 100.0), forKey: filterTuple.filterKey)
//            case .colorTemperature:
//                filter?.setValue(CIVector(x: CGFloat(-value * 45) + 6500, y: 0), forKey: filterTuple.filterKey)
//            case .hue:
//                filter?.setValue(NSNumber(value: -Double(value) / 100.0), forKey: filterTuple.filterKey)
//            case .acutance:
//                filter?.setValue(NSNumber(value: Double(value) / 25.0 + 0.4), forKey: filterTuple.filterKey)
//            case .definition:
//                filter?.setValue(NSNumber(value: Double(value) / 25.0 + 0.4), forKey: filterTuple.filterKey)
//            case .noisyPoint:
//                filter?.setValue(NSNumber(value: -Double(value) / 5000.0 + 0.02), forKey: filterTuple.filterKey)
//        }
//        return filter
//    }
//}


enum BBMetalFilterType: String, Hashable, CaseIterable {
    case exposure = "曝光"
//    case gama = "伽马"
//    case hightlight = "高光"
//    case LuminanceThreshold = "亮度阀值"
    case shadow = "阴影"
    case haze = "雾霾"
    case contrast = "对比度"
    case brightness = "亮度"
    case saturability = "饱和度"
    case vibrance = "自然饱和度"
    case colorTemperature = "色温"
    case hue = "色调"
    case definition = "锐度"
//    case gaussian = "背景虚化"
    
    var imageName: String {
        switch self {
            case .exposure:
                return "plusminus.circle"
//            case .gama:
//                return "sun.max.circle"
//            case .hightlight:
//                return "circle.lefthalf.striped.horizontal"
//            case .LuminanceThreshold:
//                return "circle.lefthalf.striped.horizontal"
            case .shadow:
                return "circle.lefthalf.filled.righthalf.striped.horizontal"
            case .haze:
                return "circle.lefthalf.filled.righthalf.striped.horizontal"
            case .contrast:
                return "circle.lefthalf.filled"
            case .brightness:
                return "sun.min"
            case .saturability:
                return "circle.fill"
            case .vibrance:
                return "lightspectrum.horizontal"
            case .colorTemperature:
                return "thermometer.medium"
            case .hue:
                return "drop"
            case .definition:
                return "righttriangle.split.diagonal"
        }
    }
    
    func filter(with value: Float) -> BBMetalBaseFilter {
        switch self {
            case .exposure:
               let filter = BBMetalExposureFilter()
                // -10.0 ~ 10.0,0.0 default
                filter.exposure = value * 0.01
                return filter
//            case .gama:
//                let filter = BBMetalGammaFilter()
//                 // 0.0 ~ 3.0, 1.0 default
//                if value > 0 {
//                    filter.gamma = value * 0.01 + 1.0
//                }else{
//                    filter.gamma = value * 0.005 + 1.0
//                }
//                 return filter
//            case .hightlight:
//                let filter = BBMetalHighlightShadowFilter()
//                 // 1.0 ~ 0.0, 1.0 default
//                filter.highlights = 1.0 - (value + 100) * 0.005
//                 return filter
//            case .LuminanceThreshold:
//                let filter = BBMetalLuminanceThresholdFilter()
//                 // 0.0 ~ 1.0, 0.5 default
//                filter.threshold = (value + 100) * 0.005
//                 return filter
            case .shadow:
                let filter = BBMetalHighlightShadowFilter()
                 // 0.0 ~ 1.0, 0.0 default
                if value > 0 {
                    filter.highlights = 1.0
                    filter.shadows = value * 0.01
                }else{
                    filter.highlights = -value * 0.01
                    filter.shadows = 0.0
                }
                 return filter
            case .haze:
                let filter = BBMetalHazeFilter()
                 // -0.3 ~ 0.3, 0.0 default
                filter.distance = value * 0.003
                filter.slope = value * 0.003
                 return filter
            case .contrast:
                let filter = BBMetalContrastFilter()
                // 0.0 ~ 4.0 1.0 default
                if value > 0 {
                    filter.contrast = value * 0.03 + 1.0
                }else{
                    filter.contrast = value * 0.01 + 1.0
                }
                return filter
            case .brightness:
                let filter = BBMetalBrightnessFilter()
                // -1.0 ~ 1.0 0.0 default
                filter.brightness = value * 0.004
                return filter
            case .saturability:
                let filter = BBMetalSaturationFilter()
                // 0.0 ~ 2.0 1.0 default
                filter.saturation = value * 0.01 + 1.0
                return filter
            case .vibrance:
                let filter = BBMetalVibranceFilter()
                // -1.2 ~ 1.2 0.0 default
                filter.vibrance = value * 0.012
                return filter
            case .colorTemperature:
                let filter = BBMetalWhiteBalanceFilter()
                // 4000 ~ 7000 5000 default
                if value > 0 {
                    filter.temperature = value * 20 + 5000
                }else{
                    filter.temperature = value * 10 + 5000
                }
                return filter
            case .hue:
                let filter = BBMetalHueFilter()
                // -180 ~ 180 0.0 default
                filter.hue = value * 1.8
                return filter
            case .definition:
                let filter = BBMetalSharpenFilter()
                // -4.0 ~ 4.0 0.0 default
                filter.sharpeness = value * 0.04
                return filter
                
        }
    }
}

typealias BBMetalFilterTuple = (filterType: BBMetalFilterType, offset: Float)
