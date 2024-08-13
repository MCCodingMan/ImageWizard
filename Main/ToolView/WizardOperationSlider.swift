//
//  IWOperationSlider.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/10.
//

import SwiftUI

struct WizardOperationSlider: View {
    
    class OffsetPublisher: ObservableObject {
        
        var isDefaultChange = false
        
        @Published var defaultOffset: Int = 0
    }
    
    @ObservedObject var offsetModel: OffsetPublisher
    var offsetChange: ((CGFloat) -> ())?
    
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                contentScrollView
                Divider()
                    .frame(width: 1, height: 22, alignment: .center)
                    .background(Color.white)
            }
            .clipped()
            .onReceive(offsetModel.$defaultOffset, perform: { value in
                offsetModel.isDefaultChange = true
                proxy.scrollTo("scrollViewCenter\(value)", anchor: .center)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    offsetModel.isDefaultChange = false
                }
            })
        }
    }
    
    var contentScrollView: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    scrollOffsetSpacer(geometry)
                    lineStack
                    Spacer().frame(width: geometry.size.width / 2 - 16)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    var lineStack: some View {
        LazyHStack(alignment: .bottom, spacing: 2) {
            ForEach(0...200, id: \.self) { count in
                if count % 5 == 0 {
                    Divider()
                        .frame(width: 1, height: {
                            if count == 100 {
                                return 18
                            }else if count % 50 == 0 {
                                return 14
                            }else{
                                return 10
                            }
                        }())
                        .background(count % 50 == 0 ? Color.white : Color.gray)
                        .id("scrollViewCenter\(count - 100)")
                }else{
                    Divider()
                        .frame(width: 1, height: 1)
                        .background(Color.clear)
                        .id("scrollViewCenter\(count - 100)")
                }
            }
        }
    }
    
    func scrollOffsetSpacer(_ geo: GeometryProxy) -> some View {
        Spacer().frame(width: geo.size.width / 2 - 16)
            .onScrollViewOffsetXChanged { offset in
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    if !offsetModel.isDefaultChange {
                        let offsetValue = (-301 - offset + 16 + (IWAppInfo.screenWidth - geo.size.width) / 2) / 301 * 100
                        let scrollViewOffset = min(max(-100, offsetValue), 100)
                        offsetChange?(scrollViewOffset)
                    }
                }
            }
    }
}

#Preview {
    WizardOperationSlider(offsetModel: WizardOperationSlider.OffsetPublisher()) { _ in
        
    }
}
