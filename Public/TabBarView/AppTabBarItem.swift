//
//  AppTabBarItem.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/17.
//

import Foundation
import SwiftUI

enum AppTabBarItem: Int, Hashable {
    case home, push, person
    
    var iconName: String {
        switch self {
            case .home:
                return "house"
            case .push:
                return "plus"
            case .person:
                return "person"
        }
    }
    
    var title: String {
        switch self {
            case .home:
                return "首页"
            case .push:
                return ""
            case .person:
                return "我的"
        }
    }
    
    var normalColor: SwiftUI.Color {
        return .white
    }
    
    var selectColor: SwiftUI.Color {
        return "D939CD".iiColor()
    }
    
    var selectBackgroundColor: SwiftUI.Color {
        return .red.opacity(0.3)
    }
}
