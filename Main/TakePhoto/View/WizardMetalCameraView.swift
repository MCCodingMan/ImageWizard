//
//  IWMetalCameraView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/17.
//

import SwiftUI

struct WizardMetalCameraView: View {
    
    @StateObject private var cameraHandler = CameraHandler()
    @StateObject private var viewModel = ViewModel()
    @StateObject private var adjustViewModel = AdjustViewModel()
    @StateObject private var adjustOffsetModel = WizardOperationSlider.OffsetPublisher()
    @StateObject private var shareHandler = CameraShareHandler()
    
    @State private var tapFocusPoint: CGPoint = .zero
    @State private var showFocus = false
    @State private var focusOpacityLow = false
    @State private var rotateAngle = 0.0
    
    @State private var isShowGrid = true
    
    @State private var isShowSet = false {
        didSet {
            if isShowSet {
                isShowShare = false
            }
        }
    }
    
    @State private var selectedSegment = 0
    
    @State private var isShowShare = false{
        didSet {
            if isShowShare {
                isShowSet = false
            }
        }
    }
    @State private var currentOrientation = UIDevice.current.orientation
    
    @State private var showPhoto: AppPhotoAssetModel?
    
    @State private var isShowZoom = false
    @State private var zoomTapPosition: CGPoint = .zero
    @State private var currentZoom = 1.0
    @State private var tapPositionY = 0.0
    
    @Namespace var whiteBalanceNamespace
    @Namespace var lookUpNamespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            VStack {
                Spacer().frame(height: IWAppInfo.topSafeHeight)
                topOperationView.frame(height: 44)
                ZStack(alignment: .top) {
                    VStack {
                        Spacer()
                        showImageView
                        Spacer()
                    }
                   
                    if isShowSet {
                        adjustOperationView.frame(height:  200)
                    }
                    ShareHandlerView(shareHandler: shareHandler)
                            .frame(height:  300)
                            .opacity(isShowShare ? 1.0 : 0.0)
                }
                .frame(width: IWAppInfo.screenWidth, height: IWAppInfo.screenWidth / ImageCropType.image16_9.ratio)
                Spacer()
            }
            VStack {
                Spacer()
                if Int(rotateAngle) % 360 != 0 {
                    WizardAdjustCategoryView(categoryList: adjustViewModel.adjustmentList) {
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
        .onReceive(cameraHandler.$takeImageModel, perform: { imageModel in
            if let imageModel {
                viewModel.takePhotos.append(imageModel)
                shareHandler.sharePhoto(with: imageModel)
                withAnimation {
                    showPhoto = imageModel
                }
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
        .onReceive(shareHandler.$recievePhotoModel, perform: { value in
            if let value {
                viewModel.takePhotos.append(value)
                withAnimation {
                    showPhoto = value
                }
            }
        })
        .onValueChange(of: UIDevice.current.orientation) { value in
            switch value {
                case .portrait, .faceUp, .faceDown, .unknown:
                    currentOrientation = .portrait
                case .landscapeLeft:
                    currentOrientation = .landscapeLeft
                case .landscapeRight:
                    currentOrientation = .landscapeRight
                case .portraitUpsideDown:
                    currentOrientation = .portraitUpsideDown
                @unknown default:
                    break
            }
        }
    }
    
    func captureCurrentPhoto() {
        cameraHandler.takePhoto()
    }
}

extension WizardMetalCameraView {
    
    var exposureView: some View {
        WizardImageOperationView(filterDefaultValue: cameraHandler.adjustFilters) { filterTuple  in
            cameraHandler.adjustFilter(with: filterTuple)
        }
    }
    
    var showImageView: some View {
        MetalViewSwiftUIView(bufferData: cameraHandler.metalData)
            .onTapGesture { tapLocation in
                focusOpacityLow.toggle()
                showFocus = true
                let focusPoint = CGPoint(x: tapLocation.x / IWAppInfo.screenWidth, y: tapLocation.y / IWAppInfo.screenWidth / ImageCropType(rawValue: cameraHandler.sizeSelectedSegment)!.ratio) // 转换为摄像头坐标系
                
                withAnimation(nil) {
                    tapFocusPoint = tapLocation
                }
                
                cameraHandler.focus(at: focusPoint)
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                    focusOpacityLow.toggle()
                    timer.invalidate()
                }
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                    showFocus = false
                    timer.invalidate()
                }
            }
            .gesture(
                DragGesture()
                    .onEnded({ _ in
                        isShowZoom.toggle()
                    })
                    .onChanged({ value in
                        zoomTapPosition = value.location
                        if !isShowZoom {
                            currentZoom = cameraHandler.zoomFactor
                            tapPositionY = value.location.y
                            isShowZoom.toggle()
                        }
                        let sliderPositiony = value.location.y - tapPositionY
                        cameraHandler.zoomFactor = min(10.0, max(1.0, currentZoom - sliderPositiony / 50))
                    })
            )
            .overlay {
                ZStack {
                    if isShowGrid { gridLine }
                    if showFocus {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3.0, dash: [10]))
                            .frame(width: 80, height: 80)
                            .opacity(focusOpacityLow ? 1 : 0.3)
                            .scaleEffect(!focusOpacityLow ? 1.2 : 1)
                            .position(tapFocusPoint)
                            .animation(.easeInOut(duration: 0.5).repeatCount(1, autoreverses: true), value: focusOpacityLow)
                    }
                    GeometryReader { geo in
                        ForEach(Array(cameraHandler.metaFrames.enumerated()), id: \.0) { frameRectTuple in
                            RectangleTopLeadingShape()
                                .stroke(Color.yellow, lineWidth: 2)
                                .frame(width: frameRectTuple.element.width, height: frameRectTuple.element.height )
                                .position(CGPoint(x: frameRectTuple.element.origin.x + frameRectTuple.element.width / 2.0, y: frameRectTuple.element.origin.y + frameRectTuple.element.height / 2.0))
                        }
                    }
                    if isShowZoom {
                        Text(String(format: "%.1fx", cameraHandler.zoomFactor))
                            .frame(width: 40, height: 40)
                            .font(.headline)
                            .foregroundStyle("666666".iiColor())
                            .background(Circle().fill(.white))
                            .shadow(color: .black.opacity(0.3), radius: 10)
                            .viewOrientationRotation(currentOrientation)
                            .position(obtainZoomPosition())
                    }
                }
            }
            .frame(width: IWAppInfo.screenWidth, height: IWAppInfo.screenWidth / ImageCropType(rawValue: cameraHandler.sizeSelectedSegment)!.ratio)
            .animation(.linear(duration: 0.1), value: cameraHandler.sizeSelectedSegment)
    }
    func obtainZoomPosition() -> CGPoint {
        if currentOrientation == .portraitUpsideDown {
            return CGPoint(x: zoomTapPosition.x + 80, y: zoomTapPosition.y)
        }
        if currentOrientation == .landscapeLeft {
            return CGPoint(x: zoomTapPosition.x, y: zoomTapPosition.y - 80)
        }
        
        if currentOrientation == .landscapeRight {
           return CGPoint(x: zoomTapPosition.x, y: zoomTapPosition.y + 80)
        }
        return CGPoint(x: zoomTapPosition.x - 80, y: zoomTapPosition.y)
    }
    
    var topOperationView: some View {
        ZStack {
            HStack {
                Button {
                    withAnimation {
                        cameraHandler.isLivePhoto.toggle()
                    }
                } label: {
                    Image(systemName: cameraHandler.isLivePhoto ? "livephoto" : "livephoto.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.gray.opacity(0.6))
                        .padding(.vertical, 14)
                        .viewOrientationRotation(currentOrientation)
                }
                .buttonStyle(AppNoEffectButtonStyle())
                
                Spacer()
                
                Button {
                    withAnimation {
                        isShowShare.toggle()
                    }
                } label: {
                    Image(systemName: shareHandler.colletedState == .connected ? "shared.with.you" : "shared.with.you.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.gray.opacity(0.6))
                        .padding(.vertical, 14)
                        .viewOrientationRotation(currentOrientation)
                }
                .buttonStyle(AppNoEffectButtonStyle())
                .padding(.trailing, 5)
                
                Button {
                    withAnimation(.easeInOut) {
                        isShowSet.toggle()
                    }
                } label: {
                    Image(systemName: "gear")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.gray.opacity(0.6))
                        .padding(.vertical, 14)
                        .viewOrientationRotation(currentOrientation)
                }
                .buttonStyle(AppNoEffectButtonStyle())
            }
            
            Button {
                withAnimation {
                    rotateAngle += 180
                }
            } label: {
                Image(systemName: "chevron.up.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(rotateAngle))
                    .foregroundStyle(.gray.opacity(0.6))
                    .padding(.vertical, 14)
            }
            .buttonStyle(AppNoEffectButtonStyle())
        }
        .padding(.horizontal)
    }
    
    var adjustOperationView: some View {
        List(0...3, id: \.self) { index in
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
        .background(.linearGradient(colors: ["000000".iiColor(), "666666".iiColor()], startPoint: .top, endPoint: .bottom))
        .customCornerRadius(25, rectCorner: [.bottomLeft, .bottomRight])
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
                                        
                                        if adjustViewModel.selectBalance == type {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3.0))
                                                .frame(width: 60, height: 60)
                                                .matchedGeometryEffect(id: "whiteBalance_border", in: whiteBalanceNamespace)
                                        }
                                        Image(uiImage: UIImage(named: "icon_example")!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .id(type.name)
                                            .clipped()
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
            if let image = showPhoto?.showCGImage {
                Button {
                    AppNavManager.share.push(WizardTakePhotoListView(photoList: viewModel.takePhotos))
                } label: {
                    Image(cgImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .viewOrientationRotation(currentOrientation)
                }
                .buttonStyle(AppNoEffectButtonStyle())
                
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
                    .viewOrientationRotation(currentOrientation)
            })
            .padding(.trailing, 30)
        }
    }
}

extension WizardMetalCameraView {
    
    struct ShareHandlerView: View {
        
        @ObservedObject var shareHandler: CameraShareHandler
        @State var buttonCount = 8
        @State private var isCanShare = false
        
        var body: some View {
            List{
                Section {
                    HStack {
                        Toggle(isOn: $isCanShare, label: {
                            HStack {
                                Text("共享")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                            }
                        })
                        .onValueChange(of: isCanShare) { value in
                            if value {
                                shareHandler.startSearch()
                            }else{
                                shareHandler.stopSearch()
                            }
                        }
                    }
                    if let peerID = shareHandler.collectedPeerID {
                        HStack {
                            Image(systemName: "person.line.dotted.person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                            Text(peerID.displayName)
                                .padding(.leading, 2)
                            Spacer()
                            Button {
                                shareHandler.dissCollection()
                            } label: {
                                if shareHandler.colletedState == .notConnected {
                                    Text("连接")
                                }else if shareHandler.colletedState == .connecting {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                                }else{
                                    Text("断开")
                                }
                            }
                            .font(.callout)
                            .foregroundStyle(.white)
                            .frame(width: 70, height: 28)
                            .background(shareHandler.colletedState == .connected ? RoundedRectangle(cornerRadius: 14).fill(Color.red) : nil)
                            .buttonStyle(AppNoEffectButtonStyle())
                            .padding(.vertical, 4)
                        }
                    }
                } footer: {
                    Text("开启共享之后，拍摄的照片可以共享")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                Section {
                    if isCanShare {
                        ForEach(shareHandler.peerIDs, id: \.self) { peerID in
                            Button {
                                shareHandler.colletion(with: peerID)
                            } label: {
                                HStack {
                                    Image(systemName: "person.icloud.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 20)
                                    Text(peerID.displayName)
                                        .padding(.leading, 2)
                                    Spacer()
                                    Image(systemName: "arrowshape.turn.up.right.fill")
                                }
                            }
                            .buttonStyle(AppNoEffectButtonStyle())
                        }
                    }
                } header: {
                    Text("附近设备")
                        .font(.headline)
                        .foregroundStyle(.gray)
                }
            }
            .scrollContentBackground(.hidden)
            .background(.linearGradient(colors: ["000000".iiColor(), "666666".iiColor()], startPoint: .top, endPoint: .bottom))
            .customCornerRadius(25, rectCorner: [.bottomLeft, .bottomRight])
        }
    }
    
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
        
        @Published var takePhotos: [AppPhotoAssetModel] = []
    }
    
    class AdjustViewModel: ObservableObject {
        
        let adjustmentList = ["调整", "白平衡", "滤镜"]
        
        var defaultAdjustSegment = 0
        
        @Published var selectBalance = BalanceAdjustType.auto
        
        @Published var selectLookup = BBFilterLookUpTable.none
        
    }
    
    
}

#Preview {
    AppNavBarContainerView {
        WizardMetalCameraView()
    }
}
