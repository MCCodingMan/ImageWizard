//
//  IWEditImageView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/8.
//

import SwiftUI
import Photos
import BBMetalImage

struct WizardEditImageView: View {
    @State var originalImage: CGImage?
    @StateObject private var viewModel = WizardEditImageViewModel()
    @State private var inputImage: CGImage?
    @State private var selectLookupFilter: BBFilterLookUpTable = .none
    @State private var selectFilterIndex = 0
    @Namespace var editImageViewLookUpNamespace
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: selectFilterIndex == 0 ? -40 : 4, content: {
                ZStack {
                    Color.black.ignoresSafeArea()
                    if inputImage != nil || originalImage != nil {
                        Image(cgImage: inputImage ?? originalImage!)
                            .resizable()
                            .scaledToFit()
                    }
                }
                if selectFilterIndex == 0 {
                    WizardImageOperationView { filterType, value  in
                        viewModel.addBBMetalFilterType(with: filterType, offset: value)
                    }
                }else if selectFilterIndex == 1 {
                    lookupScrollView.frame(height: 100)
                }
            })
            HStack(spacing: 40) {
                VStack(spacing: 10) {
                    Image(systemName: "allergens")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("调整")
                        .font(Font.system(size: 14))
                }
                .foregroundStyle(selectFilterIndex == 0 ? .white : .gray)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectFilterIndex = 0
                    }
                }
                
                VStack(spacing: 10) {
                    Image(systemName: "camera.filters")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("滤镜")
                        .font(Font.system(size: 14))
                }
                .foregroundStyle(selectFilterIndex == 1 ? .white : .gray)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectFilterIndex = 1
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color.black)
        .customNavigationBackground(Color.black)
        .customNavigationContentColor(.white)
        .customNavigationTitle("编辑")
        .customNavigationMoreSystemImage("square.and.arrow.down")
        .customNavigationMoreItemHidden(false)
        .customNavigationMoreAction {
           
        }
        .onReceive(viewModel.$outputImage, perform: { value in
            inputImage = value
        })
        .onAppear {
            viewModel.originalImage = originalImage
        }
    }
    
    var lookupScrollView: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer().frame(width: geometry.size.width / 2 - 60 / 2)
                        LazyHStack(spacing: 6) {
                            ForEach(BBFilterLookUpTable.allCases, id: \.self) { type in
                                VStack {
                                    ZStack(alignment: .top) {
                                        if let originalImage {
                                            Image(cgImage: originalImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .id(type.name)
                                                .clipped()
                                        }
                                        if selectLookupFilter == type {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3.0))
                                                .frame(width: 60, height: 60)
                                                .matchedGeometryEffect(id: "editImageViewLookUpNamespace", in: editImageViewLookUpNamespace)
                                        }
                                    }
                                    Text(type.name)
                                        .font(Font.system(size: 14))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                        .frame(height: 20)
                                }
                                .onTapGesture {
                                    selectLookupFilter = type
                                    if type != .none {
                                        if let texture = UIImage(named: selectLookupFilter.sourceName)!.bb_metalTexture {
                                            let lookupFilter = BBMetalLookupFilter(lookupTable: texture)
                                            inputImage = viewModel.outputImage?.BBMetalFilter([lookupFilter])
                                        }
                                    }else{
                                        inputImage = viewModel.outputImage
                                    }
                                }
                            }
                        }
                        Spacer().frame(width: geometry.size.width / 2  - 60 / 2)
                    }
                }
                .onValueChange(of: selectLookupFilter, perform: { value in
                    withAnimation {
                        proxy.scrollTo(value.name, anchor: .center)
                    }
                })
            }
        }
    }
}

#Preview {
    AppNavBarContainerView {
        WizardEditImageView(originalImage: UIImage(named: "icon_example")!.cgImage)
    }
}
