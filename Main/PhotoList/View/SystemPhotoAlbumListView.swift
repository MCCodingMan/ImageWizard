//
//  SystemPhotoAlbumListView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/6.
//

import SwiftUI
import Photos

struct SystemPhotoAlbumListView: View {
    @State var allAlbums: [SystemAlbumModel] = []
    
    var body: some View {
        albumsList
            .onAppear {
                WizardPhotoHandler.shared.fetchAlbumsAndPhotoCounts {
                    allAlbums = $0
                }
            }
            .customNavigationTitle("列表")
    }
    
    var albumsList: some View {
        ScrollView {
            LazyVStack {
                ForEach(Array(allAlbums.enumerated()), id: \.0) { _, assetModel in
                    HStack {
                        if let image = assetModel.coverImage {
                            Image(cgImage: image)
                                .resizable()
                                .frame(width: 35, height: 35)
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(6)
                                .clipped()
                                .padding(.leading, 6)
                        }
                        Text(assetModel.title)
                            .padding(.horizontal, 6)
                            .frame(height: 44, alignment: .leading)
                        Spacer()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red.opacity(0.3), lineWidth: 1.0)
                    )
                    .padding(.horizontal)
                    .onTapGesture {
                        AppNavManager.share.push(SystemAlbumPhotoView(imageAssets: assetModel.assets, title: assetModel.title))
                    }
                }
            }
        }
    }
}

#Preview {
    AppNavBarContainerView {
        SystemPhotoAlbumListView()
    }
}
