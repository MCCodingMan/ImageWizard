//
//  WizardCarouselView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/18.
//

import SwiftUI
import Photos

struct WizardCarouselView: View {
    @State private var currentIndex = 0
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var assetPhotos: [CGImage] = []
    private let defaultColor: [Color] = [.pink, .purple, .red, .blue, .green, .yellow, .cyan, .orange, .brown, .indigo]
    
    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                if assetPhotos.count > 0 {
                    ForEach(Array(assetPhotos.enumerated()), id: \.0, content: { index, image in
                        Image(cgImage: image)
                            .resizable()
                            .scaledToFill()
                            .tag(index)
                    })
                }else{
                    ForEach(Array(defaultColor.enumerated()), id: \.0, content: { index, color in
                        color.tag(index)
                    })
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .onReceive(timer) { _ in
                withAnimation {
                    if assetPhotos.count > 0 {
                        if currentIndex < assetPhotos.count - 1 {
                            currentIndex += 1
                        } else {
                            currentIndex = 0
                        }
                    }else{
                        if currentIndex < defaultColor.count - 1 {
                            currentIndex += 1
                        } else {
                            currentIndex = 0
                        }
                    }
                }
            }
        }
        .onAppear {
            WizardPhotoHandler.shared.fetchSmartAlbums { photos in
                assetPhotos = photos
                timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}
#Preview {
    WizardCarouselView()
}
