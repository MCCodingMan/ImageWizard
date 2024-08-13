//
//  ButtonStyle.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/12.
//

import SwiftUI

/// 按钮点击后没有任何效果
struct AppNoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(1)
    }
}
