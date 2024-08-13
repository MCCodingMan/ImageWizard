//
//  AppNavBarView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/8.
//

import SwiftUI

struct AppNavBarView<Content: View>: View {
    var title: String
    var background: Content?
    var color: SwiftUI.Color
    
    var hiddenBackItem: Bool
    var leftImage: String?
    var leftSystemImage: String?
    var leftAction: (() -> Bool)?
    
    var hiddenMoreItem: Bool
    var rightImage: String?
    var rightSystemImage: String?
    var rightAction: (() -> ())?
    
    var body: some View {
        HStack {
            leftButton
                .frame(maxWidth: 44, alignment: .leading)
                .opacity(hiddenBackItem ? 0 : 1.0)
            Spacer()
            titleBar.frame(maxWidth: .infinity, alignment: .center)
            Spacer()
            rightButton
                .frame(maxWidth: 44, alignment: .trailing)
                .opacity(hiddenMoreItem ? 0 : 1.0)
            
        }
        .frame(height: 44)
        .padding(.horizontal)
        .foregroundStyle(color)
        .accentColor(color)
        .background(background?.ignoresSafeArea(edges: .top))
    }
}
 
extension AppNavBarView {
    private var leftButton: some View {
        Button(action: {
            if let leftAction {
                if leftAction() {
                    AppNavManager.share.pop()
                }
            }else{
                AppNavManager.share.pop()
            }
        }, label: {
            if let leftImage {
                Image(leftImage)
                    .font(.body.bold())
                    .imageScale(.large)
            }else if let leftSystemImage {
                Image(systemName: leftSystemImage)
                    .font(.body.bold())
                    .imageScale(.large)
            }
        })
    }
    
    private var titleBar: some View {
        Text(title)
            .font(Font.system(size: 18, weight: .medium))
    }
    
    private var rightButton: some View {
        Button(action: {
            rightAction?()
        }, label: {
            if let rightImage {
                Image(rightImage)
                    .font(.body.bold())
                    .imageScale(.large)
            }else if let rightSystemImage {
                Image(systemName: rightSystemImage)
                    .font(.body.bold())
                    .imageScale(.large)
            }
        })
    }
}

#Preview {
    VStack(content: {
        AppNavBarView(title: "Title",
                      background: AnyView(Color.red),
                      color: SwiftUI.Color.black,
                      hiddenBackItem: false,
                      leftImage: nil,
                      leftSystemImage: "chevron.left",
                      leftAction: nil,
                      hiddenMoreItem: false,
                      rightImage: nil,
                      rightSystemImage: "list.dash",
                      rightAction: nil)
        Spacer()
    })
}
