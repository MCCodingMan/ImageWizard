//
//  WizardMergeHandler.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/7.
//

import Foundation
import UIKit
import CoreImage

class WizardMergeHandler {
    static func combineImages(backgroundImage: UIImage, 
                       overlayImage: UIImage,
                       backgroundAlpha: CGFloat,
                       overlayAlpha: CGFloat,
                       backgroundImageOrigin: CGPoint = .zero,
                       overlayImageOrigin: CGPoint = .zero,
                       backgroundImageSize: CGSize? = nil,
                       overlayImageSize: CGSize? = nil) -> UIImage? {
        let backSize = backgroundImageSize == nil ? backgroundImage.size : backgroundImageSize!
        let overlaySize = overlayImageSize == nil ? overlayImage.size : overlayImageSize!
        
        let maxWidth = max(backSize.width, overlaySize.width)
        let maxHeight = max(backSize.height, overlaySize.height)
        let contextSize = CGSize(width: maxWidth, height: maxHeight)
        

        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // 绘制背景图片并设置透明度
        backgroundImage.draw(in: CGRect(origin: backgroundImageOrigin, size: backSize), blendMode: .normal, alpha: backgroundAlpha)
        
        // 绘制前景图片并设置透明度
        context?.setAlpha(overlayAlpha)
        overlayImage.draw(in: CGRect(origin: overlayImageOrigin, size: overlaySize), blendMode: .normal, alpha: overlayAlpha)
        
        // 获取合成的图片
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
}
