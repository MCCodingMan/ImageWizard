//
//  ImageWizardApp.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/7.
//

import SwiftUI

@main
struct ImageWizardApp: App {
    
    var body: some Scene {
        WindowGroup {
            AppContentView()
        }
    }
}

fileprivate struct AppContentView: View {
    @State private var selectTab: AppTabBarItem = .home

    var body: some View {
        AppNavView {
            AppTabBarView(selection: $selectTab) {
                AppNavManager.share.push(WizardMetalCameraView())
            } content: {
                WizardMainView().tabBarItem(with: .home, selection: $selectTab)
                    .padding(.top, AppNavDefine.navigationHeight)
                Color.red.tabBarItem(with: .push, selection: $selectTab)
                WizardMineView().tabBarItem(with: .person, selection: $selectTab)
                    .padding(.top, AppNavDefine.navigationHeight)
            }
            .customNavigationTitle(selectTab == .home ? "首页" : "我的")
            .customNavigationContentIsLeadingTop(true, isClearBackground: true)
            .customNavigationBackItemHidden(true)
            .background(LinearGradient(colors: ["72EDF2".iiColor(), "5151E5".iiColor()], startPoint: .top, endPoint: .bottom))
        }
    }
}

struct app_previews: PreviewProvider {
    @State static var selectTab: AppTabBarItem = .home
    static var previews: some View {
        AppContentView()
    }
}
