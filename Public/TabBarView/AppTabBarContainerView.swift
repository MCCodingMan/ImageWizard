//
//  AppTabBarContainerView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/17.
//

import SwiftUI

struct AppTabBarContainerView: View {
    var centerAction: (() -> ())? = nil
    var tabItems: [AppTabBarItem]
    @Binding var selectTab: AppTabBarItem
    @State var localSelection: AppTabBarItem
    
    var body: some View {
        ZStack(alignment: .bottom) {
            backShape
            HStack(content: {
                ForEach(tabItems, id: \.self) { item in
                    if item != .push {
                        tabItem(with: item)
                            .onTapGesture {
                                selectionTab(with: item)
                            }
                    }else{
                        Image(systemName: "camera")
                            .imageScale(.large)
                            .font(.body.bold())
                            .frame(width: 49, height: 49)
                            .foregroundStyle(.white)
                            .background(
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color("3B2667".color()), Color("BC78EC".color())]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .shadow(color: .accentColor.opacity(0.3), radius: 10, x: 8, y: 16)
                            )
                            .onTapGesture {
                                centerAction?()
                            }
                    }
                }
            })
        }
        .padding(.horizontal)
        .frame(maxHeight: 49)
        .onChange(of: selectTab) { newValue in
            withAnimation(.easeInOut) {
                localSelection = newValue
            }
        }
    }
}

extension AppTabBarContainerView {
        
    var backShape: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 30) {
                AppTabBarBackgroundLeftShape()
                    .fill(LinearGradient(colors: ["EE91E5".iiColor(), "5961F9".iiColor()], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0.0, y: 1)
                AppTabBarBackgroundRightShape()
                    .fill(LinearGradient(colors: ["5961F9".iiColor(), "EE91E5".iiColor()], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0.0, y: 1)
                
            }
            Circle()
                .fill(Color("F5F5F5".color()))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0.0, y: 1)
        }
    }
}

extension AppTabBarContainerView {
    private func tabItem(with item: AppTabBarItem) -> some View {
        VStack(spacing: 4, content: {
            Image(systemName: item.iconName)
                .font(.subheadline)
                .fontWeight(.medium)
                .imageScale(.large)
            Text(item.title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
        })
        .foregroundStyle(localSelection == item ? item.selectColor : item.normalColor)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
    
    private func selectionTab(with item: AppTabBarItem) {
        selectTab = item
    }
}

#Preview {
    ZStack(alignment: .bottom, content: {
        Color.red.ignoresSafeArea()
        AppTabBarContainerView(tabItems: [.home, .push, .person], selectTab: .constant(.home), localSelection: .home)
    })
}
