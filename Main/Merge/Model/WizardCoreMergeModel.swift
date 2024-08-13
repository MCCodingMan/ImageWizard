//
//  WizardCoreMergeModel.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/7.
//

import Foundation
import CoreImage
import UIKit

enum MergeError: Error {
    case CoreError
}

enum WizardCustomType {
    case none
    case merge
    
    func mergeImage(_ input: UIImage, back: UIImage) throws -> CGImage {
        switch self {
            case .none:
                break
            case .merge:
                if let result = WizardMergeHandler.combineImages(backgroundImage: back, overlayImage: input, backgroundAlpha: 0.5, overlayAlpha: 0.5)?.cgImage {
                    return result
                }
        }
        
        throw MergeError.CoreError
    }
}

enum WizardCoreMergeModel: CaseIterable {
    case dissolve // 溶解 CIDissolveTransition inputImage inputTargetImage inputTime
    case softLight // 柔光混合 CISoftLightBlendMode inputImage inputBackgroundImage
    case screen // 屏幕混合 CIScreenBlendMode inputImage inputBackgroundImage
    case overlay // 叠加 CIOverlayBlendMode inputImage inputBackgroundImage
    case multiply // 乘积 CIMultiplyCompositing inputImage inputBackgroundImage
    case minimum // 低限度 CIMinimumCompositing inputImage inputBackgroundImage
    case hardLight // 强光 CIHardLightBlendMode inputImage inputBackgroundImage
    
    
    var name: String {
        switch self {
            case .dissolve:
                return "溶解"
            case .softLight:
                return "柔光"
            case .screen:
                return "屏幕"
            case .overlay:
                return "叠加"
            case .multiply:
                return "乘积"
            case .minimum:
                return "低限度"
            case .hardLight:
                return "强光"
        }
    }
    
    var filterName: String {
        switch self {
            case .dissolve:
                return "CIDissolveTransition"
            case .softLight:
                return "CISoftLightBlendMode"
            case .screen:
                return "CIScreenBlendMode"
            case .overlay:
                return "CIOverlayBlendMode"
            case .multiply:
                return "CIMultiplyCompositing"
            case .minimum:
                return "CIMinimumCompositing"
            case .hardLight:
                return "CIHardLightBlendMode"
        }
    }
    
    func coreParam(_ input: CIImage, back: CIImage, time: CGFloat = 0.25) -> [String: Any] {
        switch self {
            case .dissolve:
                return [kCIInputImageKey: input, kCIInputTargetImageKey: back, kCIInputTimeKey: NSNumber(value: time)]
            default:
                return [kCIInputImageKey: input, kCIInputBackgroundImageKey: back]
        }
    }
    
    func mergeImage(_ input: UIImage, back: UIImage) throws -> CGImage {
        if let inputCIImage = input.customCIImage, let backCIImage = back.customCIImage {
            let param = coreParam(inputCIImage, back: backCIImage)
            let fileter = CIFilter(name: filterName, parameters: param)
            if let output = fileter?.outputImage?.costomCGImage {
                return output
            }
        }
        throw MergeError.CoreError
    }
}
