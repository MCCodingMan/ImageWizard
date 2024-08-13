//
//  IWImageMergeView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/18.
//

import SwiftUI

struct WizardImageMergeView: View {
    let inputBackImage: UIImage
    let inputTargetImage: UIImage
    
    @State var mergeImage: CGImage?

    @State var selectMergeType: WizardCoreMergeModel = .dissolve
    @State var selectCustomMergeType: WizardCustomType = .none
    
    var body: some View {
        VStack {
            Spacer()
            if let mergeImage {
                Image(cgImage: mergeImage)
                    .resizable()
                    .scaledToFit()
            }
            Spacer()
            WizardMergeOperatorView(selectMergeType: $selectMergeType, selectCustomMergeType: $selectCustomMergeType)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .customNavigationTitle("合成")
        .customNavigationMoreAction {
            
        }
        .customNavigationBackground(Color.black)
        .customNavigationContentColor(.white)
        .customNavigationMoreItemHidden(false)
        .customNavigationMoreSystemImage("square.and.arrow.down")
        .onAppear(perform: {
            if let result = try? selectMergeType.mergeImage(inputTargetImage, back: inputBackImage) {
                mergeImage = result
            }
        })
        .onValueChange(of: selectMergeType) { value in
            if let result = try? value.mergeImage(inputTargetImage, back: inputBackImage) {
                mergeImage = result
            }
        }
        .onValueChange(of: selectCustomMergeType) { value in
            if let result = try? value.mergeImage(inputTargetImage, back: inputBackImage) {
                mergeImage = result
            }
        }
    }
}

#Preview {
    AppNavBarContainerView {
        WizardImageMergeView(inputBackImage: UIImage(named: "1")!, inputTargetImage: UIImage(named: "2")! )
    }
}
