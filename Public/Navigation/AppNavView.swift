//
//  AppNavView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/16.
//

import SwiftUI

public struct AppNavView<Content: View>: View {
    
    @StateObject private var appNavManager = AppNavManager.share

    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        NavigationStack(path: $appNavManager.navigationPath, root: {
            AppNavBarContainerView {
                content.customNavigationBackItemHidden(true)
            }
            .toolbar(.hidden)
            .navigationDestination(for: String.self) { feature in
                AppNavBarContainerView {
                    if let view = appNavManager.navigationPathMap[feature] {
                        view
                    }else {
                        Text("路由出错了")
                    }
                }
                .toolbar(.hidden)
            }
        })
    }
}

extension UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}

#Preview {
    AppNavView {
        Color.orange.ignoresSafeArea()
    }
}
