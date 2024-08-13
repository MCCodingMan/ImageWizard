//
//  AppTabBarPreferenceKeys.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/17.
//

import SwiftUI

struct AppTabBarPreferenceKeys: PreferenceKey {
    static var defaultValue: [AppTabBarItem] = []
    
    static func reduce(value: inout [AppTabBarItem], nextValue: () -> [AppTabBarItem]) {
        value += nextValue()
    }
}


struct AppTabBarViewModifier: ViewModifier {
    
    let tabItem: AppTabBarItem
    
    @Binding var selectItem: AppTabBarItem
    
    func body(content: Content) -> some View {
        content
            .opacity(selectItem == tabItem ? 1.0 : 0.0)
            .preference(key: AppTabBarPreferenceKeys.self, value: [tabItem])
            .animation(.easeInOut, value: 0.3)
    }
    
}

extension View {
    func tabBarItem(with tab: AppTabBarItem, selection: Binding<AppTabBarItem>) -> some View {
        modifier(AppTabBarViewModifier(tabItem: tab, selectItem: selection))
    }
}
