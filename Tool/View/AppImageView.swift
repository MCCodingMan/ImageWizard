//
//  AppImageView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/11.
//

import SwiftUI

struct AppImageView: View {
    
    enum ShowType {
        case all
        case none
        case large
    }
    
    @State var model: AppPhotoAssetModel
    var size = (IWAppInfo.screenWidth - 24.0 - 20.0) / 3.0
    var showType: ShowType = .all
    var tapAction: (() -> ())? = nil
    @State private var isCaching = false
    @State private var showImage: CGImage?
    
    @State private var magnification: CGFloat = 1.0
    @State private var lastMagnificationValue: CGFloat = 1.0
    
    @State private var currentOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero
    var body: some View {
        Button {
            tapAction?()
        } label: {
            ZStack(alignment: .center) {
                if let showImage {
                    Image(cgImage: showImage)
                        .resizable()
                        .aspectRatio(contentMode: showType != .large ? .fill : .fit)
                        .frame(width: showType != .large ? size : nil, height: showType != .large ? size : nil)
                        .scaleEffect(magnification)
                        .offset(x: currentOffset.width, y: currentOffset.height)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        magnification = lastMagnificationValue * value
                                    }
                                    .onEnded { value in
                                        lastMagnificationValue = magnification
                                        if lastMagnificationValue <= 1.0 {
                                            withAnimation {
                                                currentOffset = .zero
                                                finalOffset = .zero
                                            }
                                        }
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        if lastMagnificationValue > 1.0 { // 仅在放大时允许拖动
                                            currentOffset = CGSize(width: finalOffset.width + value.translation.width, height: finalOffset.height + value.translation.height)
                                        }
                                    }
                                    .onEnded { value in
                                        if lastMagnificationValue > 1.0 {
                                            finalOffset = currentOffset
                                        }
                                    }
                            )
                        )
                }else{
                    Color.red
                }
                if showType == .all {
                    if model.isLivePhoto {
                        VStack {
                            Spacer()
                            Image(systemName: "livephoto")
                                .imageScale(.large)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(6)
                    }
                }
                if isCaching {
                    ProgressView("正在加载")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                        .frame(width: 80, height: 80)
                        .tint(.white)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.8)))
                }
            }
        }
        .buttonStyle(AppNoEffectButtonStyle())
        .onAppear {
            showImage = model.showCGImage
            if showType != .large {
                if showImage == nil {
                    model.obtainThumbanailImage { image in
                        showImage = image
                    }
                }
            }else{
                if !model.isOriginal {
                    isCaching = true
                    model.obtainOriginalImage { image in
                        isCaching = false
                        showImage = image
                    }
                }
            }
        }
    }
}
