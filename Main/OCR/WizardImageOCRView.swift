//
//  WizardImageOCRView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/8/13.
//

import SwiftUI


fileprivate extension Button {
    func customModifier() -> some View {
        modifier(WizardImageOCRView.ButtonStyle())
    }
}

struct WizardImageOCRView: View {
    @StateObject var cameraHandler = CameraHandler()
    @StateObject var carNumberModel = CarNumberModel()
    var body: some View {
            VStack {
                HStack {
                    Button(carNumberModel.carNumberArea) {
                        
                    }
                    .customModifier()
                    
                    
                    Button(carNumberModel.carNumberCity) {
                        
                    }
                    .customModifier()
                    Button(carNumberModel.carNumberOne) {
                        
                    }
                    .customModifier()
                    
                    Button(carNumberModel.carNumberTwo) {
                        
                    }
                    .customModifier()
                    
                    Button(carNumberModel.carNumberThree) {
                        
                    }
                    .customModifier()
                    
                    Button(carNumberModel.carNumberFour) {
                        
                    }
                    .customModifier()
                    
                    Button(carNumberModel.carNumberFive) {
                        
                    }
                    .customModifier()
                    
                    Button(carNumberModel.carNumberSix) {
                        
                    }
                    .customModifier()
                }
                .padding()
                
                Spacer()
        }
            .background("f5f5f5".iiColor())
    }
}

extension WizardImageOCRView {
    class CarNumberModel: ObservableObject {
        @Published var carNumberArea: String = "川"
        @Published var carNumberCity: String = "Z"
        @Published var carNumberOne: String = "3"
        @Published var carNumberTwo: String = "9"
        @Published var carNumberThree: String = "5"
        @Published var carNumberFour: String = "9"
        @Published var carNumberFive: String = "D"
        @Published var carNumberSix: String = "1"
        
    }
    
    struct ButtonStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)
                
        }
    }
}

#Preview {
    WizardImageOCRView()
}
