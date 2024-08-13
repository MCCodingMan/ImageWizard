//
//  IWImageDetailView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/29.
//

import SwiftUI
import Photos

struct WizardImageDetailView: View {
    var asset: AppPhotoAssetModel
    
    init(asset: AppPhotoAssetModel) {
        self.asset = asset
    }
    
    @State private var isBlackBack = false
    @State private var isFirstLoad = true
    var body: some View {
        ZStack {
            if isBlackBack {
                Color.black.ignoresSafeArea()
            }
            AppImageView(model: asset, showType: .large) {
                isBlackBack.toggle()
            }
        }
        .customNavigationTitle(asset.name)
        .customNavigationMoreItemHidden(false)
        .customNavigationMoreSystemImage("aqi.medium")
        .customNavigationContentColor(isBlackBack ? .white : .black)
        .customNavigationBackground(isBlackBack ? Color.black : Color.white)
        .customNavigationMoreAction {
            AppNavManager.share.push(WizardEditImageView(originalImage: asset.showCGImage))
        }
    }
}

#Preview {
    WizardImageDetailView(asset: AppPhotoAssetModel())
}
