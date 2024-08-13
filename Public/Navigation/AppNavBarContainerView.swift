//
//  AppNavBarContainerView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/16.
//

import SwiftUI

public struct AppNavBarContainerView<Content: View>: View {
    @State private var background: AnyView?
    @State private var hiddenNavigationBar: Bool = false
    @State private var title: String = ""
    @State private var naviContentColor: SwiftUI.Color = .black
    
    @State private var hiddenBackItem: Bool = false
    @State private var leftImage: String?
    @State private var leftSystemImage: String? = "chevron.left"
    @State private var backAction: (() -> Bool)?
    
    @State private var hiddenMoreItem: Bool = true
    @State private var rightImage: String?
    @State private var rightSystemImage: String?
    @State private var rightAction: (() -> ())?
    
    @State private var isLeadingTop: Bool = false
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        vBarView
    }
}

extension AppNavBarContainerView {
    private var barView: some View {
        AppNavBarView(title: title,
                      background: background,
                      color: naviContentColor,
                      hiddenBackItem: hiddenBackItem,
                      leftImage: leftImage,
                      leftSystemImage: leftSystemImage,
                      leftAction: {
            return backAction?() ?? true
        },
                      hiddenMoreItem: hiddenMoreItem,
                      rightImage: rightImage,
                      rightSystemImage: rightSystemImage,
                      rightAction: {
            rightAction?()
        })
        
    }
    
    private var vBarView: some View {
        VStack(spacing: 0) {
            if !hiddenNavigationBar {
                barView.zIndex(1)
            }
            contentView
                .padding(.top, !isLeadingTop || hiddenNavigationBar  ? 0 : -AppNavDefine.navigationHeight)
        }
    }
    
    var contentView: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onPreferenceChange(AppNavPreferenceKeys.AppNavHiddenPreferenceKey.self, perform: { value in
                hiddenNavigationBar = value
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavTitlePreferenceKey.self, perform: { value in
                title = value
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavContentColorPreferenceKey.self, perform: { value in
                naviContentColor = value
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavBackItemHiddenPreferenceKey.self, perform: { value in
                hiddenBackItem = value
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavLeftImagePreferenceKey.self, perform: { value in
                leftImage = value
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavLeftSystemImagePreferenceKey.self, perform: { value in
                leftSystemImage = value
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavBackActionPreferenceKey.self, perform: { value in
                if let value {
                    switch value {
                        case .backBlock(let block):
                            backAction = block
                        default: break;
                    }
                }
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavMoreItemHiddenPreferenceKey.self, perform: { value in
                hiddenMoreItem = value
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavRightImagePreferenceKey.self, perform: { value in
                rightImage = value
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavRightSystemImagePreferenceKey.self, perform: { value in
                rightSystemImage = value
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavMoreActionPreferenceKey.self, perform: { value in
                if let value {
                    switch value {
                        case .moreBlock(let block):
                            rightAction = block
                        default: break;
                    }
                }
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavBackgroundPreferenceKey.self, perform: { value in
                if let value {
                    switch value {
                        case .view(let view):
                            background = view
                        default: break;
                    }
                }
            })
            .onPreferenceChange(AppNavPreferenceKeys.AppNavContentLeadingTopPreferenceKey.self, perform: { value in
                isLeadingTop = value
            })
    }
}

#Preview {
    AppNavBarContainerView {
        Color.green.ignoresSafeArea()
            .customNavigationTitle("title")
            .customNavigationContentIsLeadingTop(true, isClearBackground: true)
    }
}
