//
//  MetalViewSwiftUIView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/5/25.
//

import Foundation
import SwiftUI
import MetalKit

struct MetalViewSwiftUIView: UIViewRepresentable {
    
    var bufferData: MetalBufferDataModel
    
    private let mtkView = CustomMTKView(frame: .zero, device: AppMetal.defaultDevice)
    
    func makeUIView(context: Context) -> CustomMTKView {
        return mtkView
    }
    
    func updateUIView(_ uiView: CustomMTKView, context: Context) {
        uiView.bufferData = bufferData
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
}

extension MetalViewSwiftUIView {
    class Coordinator { }
}
