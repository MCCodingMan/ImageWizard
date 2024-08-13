//
//  IWAppInfo.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/8.
//

import UIKit

struct IWAppInfo {
    
    // 屏幕宽高
    public static let screenWidth = UIScreen.main.bounds.width
    public static let screenHeight = UIScreen.main.bounds.height
    
    public static let screenScale = UIScreen.main.scale
    
    public static var isIslandPhone: Bool {
        if UIDevice.current.userInterfaceIdiom != .phone {
            return false
        }
        return topSafeHeight >= 59
    }
    
    public static var navigationHeight : CGFloat {
        return topSafeHeight + 44
    }
    
    public static var topSafeHeight : CGFloat {
            let sets = UIApplication.shared.connectedScenes
            let windowScene = sets.first as! UIWindowScene
            return (windowScene.statusBarManager?.statusBarFrame.height)!
    }
    
    public static var bottomSafeHeight : CGFloat {
        let sets = UIApplication.shared.connectedScenes
        guard let windowScene = sets.first as? UIWindowScene else {return 0}
        guard let window = windowScene.windows.first else {return 0}
        return window.safeAreaInsets.bottom
    }
}
