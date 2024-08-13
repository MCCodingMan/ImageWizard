//
//  WizardVerticalSlider.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/18.
//

import SwiftUI

struct WizardVerticalSlider: View {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let controlWidth = 30.0
    let height: CGFloat = 250
    @State private var sliderPositiony: CGFloat = 0.0
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Spacer()
                .frame(width: 4, height: height - controlWidth)
                .background(RoundedRectangle(cornerRadius: 2).fill("eeeeee".iiColor()))
                .padding(.vertical, controlWidth / 2)
            Text(String(format: "%.1f", value))
                .frame(width: controlWidth, height: controlWidth)
                .font(.headline)
                .foregroundStyle("666666".iiColor())
                .background(Circle().fill(.white))
                .shadow(color: .black.opacity(0.3), radius: 10)
                .offset(y: sliderPositiony)
                .gesture(
                    DragGesture()
                        .onChanged { dragValue in
                            sliderPositiony = min(0.0, max(dragValue.location.y, -(height - controlWidth)))
                            let minValue = range.lowerBound
                            let maxValue = range.upperBound
                            value = minValue - sliderPositiony / (height - controlWidth) * (maxValue - minValue)
                        }
                )
        }
        .onAppear {
            sliderPositiony =  -(value - range.lowerBound) / (range.upperBound - range.lowerBound) * (height - controlWidth)
        }
        .frame(width: controlWidth)
    }
}

#Preview {
    @State var value: CGFloat = 1.0
    return HStack {
        Spacer()
        WizardVerticalSlider(value: $value, range: 1.0...5.0)
        Spacer()
    }
    .background(.black)
}
