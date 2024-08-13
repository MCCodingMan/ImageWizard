//
//  IWAdjustCategoryView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/10.
//

import SwiftUI

struct WizardAdjustCategoryView: View {
    
    let categoryList: [String]
    
    @State private var currentCategoryId: Int = 0
    
    @Namespace private var categorySegmentNamespace
    
    let content: [AnyView]
    
    init(categoryList: [String], 
        content: () -> [AnyView]) {
        self.categoryList = categoryList
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content[currentCategoryId]
            HStack {
                ForEach(Array(categoryList.enumerated()), id: \.1) { value in
                    Button {
                        withAnimation(.spring()) {
                            currentCategoryId = value.offset
                        }
                    } label: {
                        ZStack {
                            if currentCategoryId == value.offset {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.5))
                                    .matchedGeometryEffect(id: "categorySegmentNamespaceID", in: categorySegmentNamespace)
                            }
                            Text(value.element)
                                .font(Font.system(size: 14))
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 30)
                        }
                    }
                    .frame(width: 50, height: 30)
                }
            }
        }
    }
}

#Preview {
    WizardAdjustCategoryView(categoryList: ["11", "22"]) {
        [AnyView( Color.red.tag(0)),
         AnyView( Color.blue.tag(0))]
    }
}
