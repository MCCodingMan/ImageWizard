//
//  IWImageMergeView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/18.
//

import SwiftUI

struct WizardImageMergeSelectView: View {
    @State private var isShowingBackImagePicker = false
    @State private var isShowingTargetImagePicker = false
    @State private var backImages: [UIImage] = []
    @State private var targetImages: [UIImage] = []
    var body: some View {
        VStack(spacing: 100) {
            HStack(spacing: 50) {
                VStack(spacing: 20) {
                    Button(action: {
                        isShowingBackImagePicker.toggle()
                    }, label: {
                        if let backImage = backImages.first {
                            Image(uiImage: backImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                        }else{
                            Image(systemName: "plus")
                                .frame(width: 100, height: 100)
                                .font(.body.bold())
                                .imageScale(.large)
                        }
                    })
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 0.0)
                    Text("背景")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
                
                VStack(spacing: 20) {
                    Button(action: {
                        isShowingTargetImagePicker.toggle()
                    }, label: {
                        if let targetImage = targetImages.first {
                            Image(uiImage: targetImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                        }else{
                            Image(systemName: "plus")
                                .frame(width: 100, height: 100)
                                .font(.body.bold())
                                .imageScale(.large)
                        }
                    })
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 0.0)
                    Text("照片")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
            }
            
            Button(action: {
                if let backImage = backImages.first, let targetImage = targetImages.first {
                    AppNavManager.share.push(WizardImageMergeView(inputBackImage: backImage, inputTargetImage: targetImage))
                }
            }, label: {
                Text("合成")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0.0, y: 10)
            })
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(80)
        }
        .customNavigationTitle("选择合成的图片")
        .sheet(isPresented: $isShowingBackImagePicker) {
            AppImagePicker(selectedImage: $backImages, maxSelectCount: 1)
                .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $isShowingTargetImagePicker) {
            AppImagePicker(selectedImage: $targetImages, maxSelectCount: 1)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}


#Preview {
    AppNavBarContainerView {
        WizardImageMergeSelectView()
    }
}
