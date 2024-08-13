//
//  WizardJigsawView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/19.
//

import SwiftUI
import UIKit

struct WizardJigsawView: View {
    
    @State private var currentRule: WizardJigsawRuleView.JigsawRule = .longImage
    @State private var isSelectImage = false
    @State private var images: [UIImage] = []
    @State private var currentMaxCount: Int = WizardJigsawRuleView.JigsawRule.longImage.maxCount
    @State private var saveAction: Bool = false
    var body: some View {
        VStack {
            VStack {
                Spacer()
                VStack {
                    Spacer()
                    currentRule.ruleView(with: $images, sheet: $isSelectImage, save: $saveAction)
                    Spacer()
                    WizardJigsawImageCollectionView(images: $images, maxCount: $currentMaxCount) {
                        isSelectImage.toggle()
                    }
                    .customModifier()
                }
                Spacer()
                WizardJigsawRuleView(currentRule: $currentRule)
                    .onValueChange(of: currentRule) { value in
                        currentMaxCount = value.maxCount
                    }
            }
            .padding(.top, IWAppInfo.navigationHeight)
        }
        .background(LinearGradient(colors: ["f2d50f".iiColor(), "da0641".iiColor()], startPoint: .top, endPoint: .bottom))
        .sheet(isPresented: $isSelectImage) {
            AppImagePicker(selectedImage: $images, maxSelectCount: currentMaxCount - images.count)
                .ignoresSafeArea(edges: .bottom)
        }
        .customNavigationTitle("拼图")
        .customNavigationContentIsLeadingTop(true)
        .customNavigationMoreSystemImage("square.and.arrow.down.on.square")
        .customNavigationMoreAction {
//            saveAction.toggle()
            let view = currentRule.ruleView(with: $images, sheet: $isSelectImage, save: $saveAction)
            let render = ImageRenderer(content: view)
            render.scale = IWAppInfo.screenScale
            if let image = render.uiImage {
                images.append(image)
            }
            
        }
        .ignoresSafeArea()
    }
}


fileprivate struct CollectionModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(height: 70)
            .background(LinearGradient(colors: ["f36265".iiColor(), "961276".iiColor()], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1.0)
                    .fill(Color.gray)
            }
            .shadow(color: .black.opacity(0.2), radius: 10)
            .padding([.leading, .trailing, .bottom], 5)
    }
}

fileprivate extension View {
    
    func customModifier() -> some View {
        modifier(CollectionModifier())
    }
}

#Preview {
    AppNavBarContainerView {
        WizardJigsawView()
    }
}
