//
//  AppTabBarView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/17.
//

import SwiftUI

struct AppTabBarView<Content: View> : View {
    let content: Content
    var action: (() -> ())? = nil
    @Binding var selection: AppTabBarItem
    @State private var tabs: [AppTabBarItem] = []
    
    init(selection: Binding<AppTabBarItem>, action: (() -> ())? = nil, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom, content: {
            content.ignoresSafeArea()
            AppTabBarContainerView(centerAction: action, tabItems: tabs, selectTab: $selection, localSelection: selection)
        })
        .onPreferenceChange(AppTabBarPreferenceKeys.self, perform: { value in
            self.tabs = value
        })
    }
}

struct Previews: PreviewProvider {
    @State static var selection: AppTabBarItem = .home
    static var previews: some View {
        AppTabBarView(selection: $selection, action: {
            
        }) {
            Color.red.tabBarItem(with: .home, selection: $selection)
            Color.blue.tabBarItem(with: .push, selection: $selection)
            Color.green.tabBarItem(with: .person, selection: $selection)
        }
    }
}
