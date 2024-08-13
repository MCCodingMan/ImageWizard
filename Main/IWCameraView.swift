//
//  IWCameraView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/9.
//

import SwiftUI
import AVFoundation
import UIKit

struct IWCameraView: View {
    @StateObject private var cameraHandler = IWCameraHandler()
    @StateObject private var viewModel = ViewModel()
    @StateObject private var adjustViewModel = AdjustViewModel()
    @StateObject private var adjustOffsetModel = IWOperationSlider.OffsetPublisher()
    
    @State private var tapFocusPoint: CGPoint = .zero
    @State private var showFocus = false
    @State private var focusOpacityLow = false
    @State private var rotateAngle = 0.0
    
    @State private var isShowGrid = true
    
    @State private var flashlightSwitch = false
    @State private var isShowSet = false
    
    @State private var selectedSegment = 0
    
    @Namespace var whiteBalanceNamespace
    @Namespace var lookUpNamespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            VStack(content: {
                Spacer().frame(height: IWAppInfo.topSafeHeight)
                topOperationView
                showImageView.clipped()
                Spacer()
            })
            VStack {
                Spacer()
                if Int(rotateAngle) % 360 != 0 {
                    IWAdjustCategoryView(categoryList: adjustViewModel.adjustmentList) {
                        [AnyView(exposureView.frame(height: 150)),
                         AnyView(whiteBalanceScrollView.frame(height: 100)),
                         AnyView(lookupScrollView.frame(height: 100))]
                    }
                }
                bottomOperator.padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationContentIsLeadingTop(true)
        .customNavigationBackItemHidden(true)
        .onDisappear {
            cameraHandler.stopRunning()
        }
        .onAppear {
            cameraHandler.startRunning()
        }
        .onReceive(cameraHandler.$takeImage, perform: { image in
            if let image {
                viewModel.takePhotos.append((name: cameraHandler.takeImageName!, image: image))
            }
        })
        .onValueChange(of: selectedSegment) { value in
            if value == 1 {
                cameraHandler.isPortraitCamera = true
                cameraHandler.sizeSelectedSegment = 1
            }else{
                cameraHandler.isPortraitCamera = false
            }
        }
    }
    
    func captureCurrentPhoto() {
        cameraHandler.takePhoto()
    }
}

extension IWCameraView {
    
    var exposureView: some View {
        IWImageOperationView(filterDefaultValue: cameraHandler.adjustFilters) { filterTuple  in
            cameraHandler.adjustFilter(with: filterTuple)
        }
    }
    
    var showImageView: some View {
        ZStack(alignment: .top) {
            if let image = cameraHandler.realTimeImage {
                Image(cgImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: IWAppInfo.screenWidth, height: IWAppInfo.screenWidth / 9.0 * 16.0)
                    .onTapGesture { tapLocation in
                        focusOpacityLow.toggle()
                        showFocus = true
                        let focusPoint = CGPoint(x: tapLocation.x / IWAppInfo.screenWidth, y: tapLocation.y / IWAppInfo.screenWidth / 9.0 * 16.0) // 转换为摄像头坐标系
                        
                        withAnimation(nil) {
                            tapFocusPoint = tapLocation
                        }
                        
                        cameraHandler.focus(at: focusPoint)
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                            focusOpacityLow.toggle()
                            timer.invalidate()
                        }
                    }
            }else{
                Spacer().frame(width: IWAppInfo.screenWidth, height: IWAppInfo.screenWidth / 9.0 * 16.0)
            }
            GeometryReader { geo in
                ForEach(Array(cameraHandler.metaFrames.enumerated()), id: \.0) { frameRectTuple in
                    RectangleTopLeadingShape()
                        .stroke(Color.yellow, lineWidth: 2)
                        .frame(width: frameRectTuple.element.width, height: frameRectTuple.element.height )
                        .position(CGPoint(x: frameRectTuple.element.origin.x + frameRectTuple.element.width / 2.0, y: frameRectTuple.element.origin.y + frameRectTuple.element.height / 2.0))
                }
            }
            if isShowGrid {
                VStack(spacing: 0) {
                    gridLine.frame(width: IWAppInfo.screenWidth, height: IWAppInfo.screenWidth * (cameraHandler.sizeSelectedSegment == 0 ? (16.0 / 9.0) : (cameraHandler.sizeSelectedSegment == 1 ? (4.0 / 3.0) : (1.0 / 1.0))))
                        .animation(.easeInOut, value: cameraHandler.sizeSelectedSegment)
                    Color.black.opacity(0.7)
                        .animation(.easeInOut, value: cameraHandler.sizeSelectedSegment)
                }
            }
            if showFocus {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3.0, dash: [10]))
                    .frame(width: 80, height: 80)
                    .opacity(focusOpacityLow ? 1 : 0.3)
                    .scaleEffect(!focusOpacityLow ? 1.2 : 1)
                    .position(tapFocusPoint)
                    .animation(.easeInOut(duration: 0.5).repeatCount(1, autoreverses: true), value: focusOpacityLow)
            }
            if isShowSet {
                adjustOperationView
                    .frame(height:  200)
            }
        }
    }
    
    var topOperationView: some View {
        HStack {
            Image(systemName: "gear")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(rotateAngle))
                .foregroundStyle(.gray.opacity(0.6))
                .padding(.vertical, 14)
                .onTapGesture {
                    
                }
            Spacer()
            Image(systemName: "chevron.up.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(rotateAngle))
                .foregroundStyle(.gray.opacity(0.6))
                .padding(.vertical, 14)
                .onTapGesture {
                    withAnimation {
                        rotateAngle += 180
                    }
                }
            Spacer()
            Image(systemName: "gear")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(rotateAngle))
                .foregroundStyle(.gray.opacity(0.6))
                .padding(.vertical, 14)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        isShowSet.toggle()
                    }
                }
        }
    }
    
    var adjustOperationView: some View {
        List(0...4, id: \.self) { index in
            if index == 0 {
                Toggle(isOn: $cameraHandler.isBeauty) {
                    Text("美颜")
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.clear)
                .listRowSpacing(5)
            }else if index == 1 {
                Toggle(isOn: $cameraHandler.isAuto) {
                    Text("自动调整")
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.clear)
                .listRowSpacing(5)
            }else if index == 2 {
                Toggle(isOn: $isShowGrid) {
                    Text("网格开关")
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.clear)
                .listRowSpacing(5)
            }else if index == 3 {
                HStack(content: {
                    Text("模式")
                        .foregroundStyle(.white)
                    Spacer()
                    Picker(selection: $selectedSegment, label: Text("模式")) {
                        Text("照片").tag(0)
                        Text("人像").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .tint(.white)
                    .frame(width: 100)
                })
                .listRowBackground(Color.clear)
                .listRowSpacing(5)
            }else if index == 4 {
                HStack(content: {
                    Text("大小")
                        .foregroundStyle(.white)
                    Spacer()
                    Picker(selection: $cameraHandler.sizeSelectedSegment, label: Text("模式")) {
                        Text("16:9").tag(0)
                        Text("4:3").tag(1)
                        Text("1:1").tag(2)
                        
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .tint(.white)
                    .frame(width: 150)
                })
                .listRowBackground(Color.clear)
                .listRowSpacing(5)
            }
        }
        .listStyle(.plain)
        .background(Color.black.opacity(0.8)) // 设置列表背景颜色
        .listRowSpacing(5)
    }
    
    var gridLine: some View {
        let dividLength = 25.0
        let dividWidth = 0.5
        return ZStack(content: {
            HStack(content: {
                Spacer()
                Divider().frame(width: dividWidth).background(.gray)
                Spacer()
                Divider().frame(width: dividWidth).background(.gray)
                Spacer()
            })
            VStack(content: {
                Spacer()
                Divider().frame(height: dividWidth).background(.gray)
                Spacer()
                Divider().frame(height: dividWidth).background(.gray)
                Spacer()
            })
            GeometryReader(content: { geometry in
                Divider().frame(width: dividWidth, height: dividLength).background(.gray)
                    .position(x: dividWidth / 2, y: dividLength / 2)
                Divider().frame(width: dividLength, height: dividWidth).background(.gray)
                    .position(x: dividLength / 2, y: dividWidth / 2)
                
                Divider().frame(width: dividWidth, height: dividLength).background(.gray)
                    .position(x: geometry.size.width - dividWidth / 2, y: dividLength / 2)
                Divider().frame(width: dividLength, height: dividWidth).background(.gray)
                    .position(x: geometry.size.width - dividLength / 2, y: dividWidth / 2)
                
                
                Divider().frame(width: dividWidth, height: dividLength).background(.gray)
                    .position(x: dividWidth / 2, y: geometry.size.height - dividLength / 2)
                Divider().frame(width: dividLength, height: dividWidth).background(.gray)
                    .position(x: dividLength / 2, y: geometry.size.height - dividWidth / 2)
                
                
                Divider().frame(width: dividWidth, height: dividLength).background(.gray)
                    .position(x: geometry.size.width - dividWidth / 2, y: geometry.size.height - dividLength / 2)
                Divider().frame(width: dividLength, height: dividWidth).background(.gray)
                    .position(x: geometry.size.width - dividLength / 2, y: geometry.size.height - dividWidth / 2)
            })
            
        })
    }
    
    var whiteBalanceScrollView: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer().frame(width: geometry.size.width / 2 - 60 / 2)
                        LazyHStack(spacing: 6) {
                            ForEach(BalanceAdjustType.allCases, id: \.self) { type in
                                VStack {
                                    ZStack(alignment: .top) {
                                        Image(uiImage: UIImage(named: "icon_example")!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .id(type.name)
                                            .clipped()
                                        if adjustViewModel.selectBalance == type {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3.0))
                                                .frame(width: 60, height: 60)
                                                .matchedGeometryEffect(id: "whiteBalance_border", in: whiteBalanceNamespace)
                                        }
                                    }
                                    Text(type.name)
                                        .font(Font.system(size: 14))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                        .frame(height: 20)
                                }
                                .onTapGesture {
                                    cameraHandler.whiteBalance(type.temperature)
                                    withAnimation {
                                        adjustViewModel.selectBalance = type
                                    }
                                }
                            }
                        }
                        Spacer().frame(width: geometry.size.width / 2  - 60 / 2)
                    }
                }
                .onReceive(adjustViewModel.$selectBalance, perform: { value in
                    withAnimation {
                        proxy.scrollTo(value.name, anchor: .center)
                    }
                })
            }
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
                                        Image(uiImage: UIImage(named: "icon_example")!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .id(type.name)
                                            .clipped()
                                        if adjustViewModel.selectLookup == type {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3.0))
                                                .frame(width: 60, height: 60)
                                                .matchedGeometryEffect(id: "lookUpNamespace", in: lookUpNamespace)
                                        }
                                    }
                                    Text(type.name)
                                        .font(Font.system(size: 14))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                        .frame(height: 20)
                                }
                                .onTapGesture {
                                    cameraHandler.lookUptableName = type.sourceName
                                    withAnimation {
                                        adjustViewModel.selectLookup = type
                                    }
                                }
                            }
                        }
                        Spacer().frame(width: geometry.size.width / 2  - 60 / 2)
                    }
                }
                .onReceive(adjustViewModel.$selectLookup, perform: { value in
                    withAnimation {
                        proxy.scrollTo(value.name, anchor: .center)
                    }
                })
            }
        }
    }

    var bottomOperator: some View {
        HStack {
            if let cgImage = viewModel.takePhotos.last?.image {
                Image(cgImage: cgImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .clipped()
                    .onTapGesture {
                        AppNavManager.share.push(IWTakePhotoListView(photoList: viewModel.takePhotos.map({$0.image}), photoListName: viewModel.takePhotos.map({$0.name})))
                    }
            }else{
                Spacer().frame(width: 60, height: 60)
            }
            Spacer()
            Button(action: {
                captureCurrentPhoto()
            }, label: {
                Image("icon_shoot")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .scaledToFit()
            })
            
            Spacer()
            Button(action: {
                cameraHandler.cameraPositionIsBack.toggle()
            }, label: {
                Image(systemName: "gobackward")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.white)
                    .clipped()
            })
            .padding(.trailing, 30)
        }
    }
}

extension IWCameraView {
    
    struct RectangleTopLeadingShape: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                let maxWH = min(min(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 3.0, 15.0)
                path.move(to: CGPoint(x: rect.minX, y: maxWH))
                path.addLine(to: CGPoint(x: rect.minX, y: 5))
                path.addArc(center: CGPoint(x: 5, y: 5), radius: 5, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
                path.addLine(to: CGPoint(x: maxWH, y: rect.minY))
                
                path.move(to: CGPoint(x: rect.maxX - maxWH, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX - 5, y: rect.minY))
                path.addArc(center: CGPoint(x: rect.maxX - 5, y: 5), radius: 5, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: maxWH))
                
                path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - maxWH))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 5))
                path.addArc(center: CGPoint(x: rect.maxX - 5, y: rect.maxY - 5), radius: 5, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX - maxWH, y: rect.maxY))
                
                
                path.move(to: CGPoint(x: maxWH, y: rect.maxY))
                path.addLine(to: CGPoint(x: 5, y: rect.maxY))
                path.addArc(center: CGPoint(x: 5, y: rect.maxY - 5), radius: 5, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - maxWH))
            }
        }
    }
    
    class ViewModel: ObservableObject {
        
        struct FilterImageModel: Hashable {
            var image = UIImage(named: "icon_example")!
            var title = ""
            var idx = -1
        }
        let exampleImage = UIImage(named: "icon_example")!
        
        @Published var takePhotos: [(name: String, image: CGImage)] = []
    }
    
    class AdjustViewModel: ObservableObject {
        
        let adjustmentList = ["调整", "白平衡", "滤镜"]
        
        var defaultAdjustSegment = 0
        
        @Published var selectBalance = BalanceAdjustType.auto
        
        @Published var selectLookup = BBFilterLookUpTable.none
        
    }
}

struct CameraPreviews: PreviewProvider {
    static var previews: some View {
        AppNavBarContainerView {
            IWCameraView()
        }
    }
}
