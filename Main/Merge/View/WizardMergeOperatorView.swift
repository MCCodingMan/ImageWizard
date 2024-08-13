//
//  WizardMergeOperatorView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/6.
//

import SwiftUI

fileprivate struct CheckModifier: ViewModifier {
    
    var width: CGFloat
    
    func body(content: Content) -> some View {
        content.frame(width: width)
    }
}

fileprivate extension AnyTransition {
    
    static func checkTransition(_ activeWidth: CGFloat, identityWidth: CGFloat) -> AnyTransition {
        AnyTransition.modifier(active: CheckModifier(width: activeWidth), identity: CheckModifier(width: identityWidth))
    }
}

struct WizardMergeOperatorView: View {
    
    @State var dataSource = ["系统", "自定义"]
    @State var index: Int = 0
    
    @Namespace var buttonCheckNamespace
    
    @Namespace var mergeFilterNamespace
    
    @Binding var selectMergeType: WizardCoreMergeModel
    @Binding var selectCustomMergeType: WizardCustomType
    
    
    var activeWidth: CGFloat {
        let idx = CGFloat(index)
       return (idx + 1) * 85.0 - 5
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(Array(dataSource.enumerated()), id: \.0) {idx, title in
                        ZStack {
                            Button {
                                withAnimation {
                                    index = idx
                                }
                            } label: {
                                Text(title)
                                    .foregroundStyle(.black)
                            }
                            
                            if idx == index {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.15))
                                    .matchedGeometryEffect(id: "buttonCheckNamespace", in: buttonCheckNamespace)
                            }
                        }
                        .frame(width: 80, height: 40)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.top, 12)
            Group {
                if index == 0 {
                    filterNameScrollView
                }else{
                    customMergeView
                }
            }
            .frame(height: 100)
            .padding(.horizontal)
            Spacer().frame(maxHeight: AppNavDefine.bottomSafeHeight)
        }
        .background("dddddd".iiColor())
        .customCornerRadius(20, rectCorner: [.topLeft, .topRight])
    }
    
    var filterNameScrollView: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(WizardCoreMergeModel.allCases, id: \.self) { mergeType in
                    VStack {
                        ZStack {
                            Image(uiImage: UIImage(named: "icon_example")!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .clipped()
                            if selectMergeType == mergeType {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3.0))
                                    .frame(width: 63, height: 63)
                                    .matchedGeometryEffect(id: "mergeFilterNamespace", in: mergeFilterNamespace)
                            }
                        }
                        .frame(width: 63, height: 63)
                        .onTapGesture {
                            withAnimation {
                                selectMergeType = mergeType
                            }
                        }
                        Text(mergeType.name)
                            .font(.headline)
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }
    
    var customMergeView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button {
                    selectCustomMergeType = .merge
                } label: {
                    VStack {
                        Image(systemName: "arrow.triangle.merge")
                            .imageScale(.large)
                            .frame(width: 60, height: 60)
                        Text("融合")
                    }
                }
            }
        }
    }
}

//#Preview {
//    VStack {
//        Spacer()
//        WizardMergeOperatorView(dataSource: ["第1个","第2个","第3个","第4个","第5个","第6个","第7个","第8个","第9个","第10个","第11个","第12个"]) { idx in
//            if idx == 0 {
//                AnyView(Color.red)
//            }else{
//                AnyView(Color.blue)
//            }
//        }
//    }
//    .padding(.horizontal, 0)
//    .background(Color.black)
//    .ignoresSafeArea()
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
//}
