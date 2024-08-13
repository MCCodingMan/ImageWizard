//
//  SystemAlbumPhotoView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/6.
//

import SwiftUI
import Photos

struct SystemAlbumPhotoView: View {
    @State var imageAssets: [AppPhotoAssetModel]
    @State var title: String
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, content: {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0, maximum: .infinity)), count: 3), spacing: 10, content: {
                    ForEach(Array(imageAssets.enumerated()), id: \.0) { idx, imageModel in
                        AppImageView(model: imageModel) {
                            AppNavManager.share.push(WizardImageDetailView(asset: imageModel))
                        }
                        .frame(width: (IWAppInfo.screenWidth - 24.0 - 20.0) / 3.0, height: (IWAppInfo.screenWidth - 24.0 - 20.0) / 3.0)
                        .cornerRadius(10)
                        .clipped()
                        .shadow(radius: 5)
                    }
                })
                .padding(.all, 12.0)
                Spacer(minLength: IWAppInfo.bottomSafeHeight + 49)
            })
        }
        .customNavigationTitle(title)
    }
}

#Preview {
    SystemAlbumPhotoView(imageAssets: [], title: "")
}
