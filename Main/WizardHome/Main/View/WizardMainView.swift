//
//  IWMainView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/7.
//

import SwiftUI
import Photos

struct WizardMainView: View {
    enum ClickType {
        case beauti, graffiti, none
    }
    
    @State private var photoDateData: [DBManager.PhotoDateModel] = []
    @State var isShowImagePicker: Bool = false
    @State var currentClick = ClickType.none
    @State var editImage: [UIImage] = []
    var body: some View {
        ScrollView {
            VStack {
                functionOneView.padding()
                functionTwoView.padding(.horizontal)
                toolFunctionView.padding()
                imageListView.padding()
                Spacer()
            }
            .background(Color.clear)
        }
        .scrollIndicators(.hidden)
        .background(Color.clear)
        .padding(.bottom, IWAppInfo.bottomSafeHeight + 55)
        .onAppear {
            photoDateData = DBManager.selectTimeList()
        }
    }
    
    var functionOneView: some View {
        HStack(spacing: 15) {
            WizardClockView()
                .padding().frame(maxWidth: .infinity, maxHeight: .infinity)
                .background("111111".iiColor())
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                .shadow(color: .black.opacity(0.3), radius: 10)
            
            VStack(spacing: 10) {
                moreGridButton(with: "相册", image: "photo.on.rectangle.angled", action: {
                    AppNavManager.share.push(SystemPhotoAlbumListView())
                })
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: ["FFA8A8".iiColor(), "ECEF00".iiColor()], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: .black.opacity(0.5), radius: 10)
                )
                moreGridButton(with: "合成", image: "camera.macro", action: {
                    AppNavManager.share.push(WizardImageMergeSelectView())
                })
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: ["FFA8A8".iiColor(), "ECEF00".iiColor()], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: .black.opacity(0.5), radius: 10)
                )
            }
        }
    }
    
    var functionTwoView: some View {
        HStack(spacing: 15) {
            Grid {
                GridRow {
                    HStack {
                        gridButton(with: "拼图") {
                            AppNavManager.share.push(WizardJigsawView())
                        }
                        gridButton(with: "涂鸦") {
                            currentClick = .graffiti
                            isShowImagePicker.toggle()
                        }
                    }
                }
                GridRow {
                    moreGridButton(with: "美化", image: "fireworks", action: {
                        currentClick = .beauti
                        isShowImagePicker.toggle()
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: ["FAD7A1".iiColor(), "E96d71".iiColor()], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .black.opacity(0.5), radius: 10)
                    )
                }
            }
            GeometryReader { geo in
                WizardCarouselView()
                    .frame(width: geo.size.width)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 15)) // 设置圆角
                    .shadow(color: .black.opacity(0.5), radius: 10)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .sheet(isPresented: $isShowImagePicker) {
            AppImagePicker(selectedImage: $editImage, maxSelectCount: 1)
                .ignoresSafeArea(edges: .bottom)
        }
        .onValueChange(of: editImage) { value in
            if let image = value.first {
                if currentClick == .beauti {
                    AppNavManager.share.push(WizardEditImageView(originalImage: image.cgImage))
                }else{
//                    AppNavManager.share.push(WizardGraffitiView(graffitiImage: image))
                }
            }
        }
    }
    
    var toolFunctionView: some View {
        HStack(spacing: 15) {
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .randomColor()))
                    .frame(width: geo.size.width)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 15)) // 设置圆角
                    .shadow(color: .black.opacity(0.5), radius: 10)
            }
            .aspectRatio(1, contentMode: .fit)
            Grid {
                GridRow {
                    HStack {
                        gridButton(with: "识别") {
                            AppNavManager.share.push(WizardImageOCRView())
                        }
                        gridButton(with: "") {
                            currentClick = .graffiti
                            isShowImagePicker.toggle()
                        }
                    }
                }
                GridRow {
                    moreGridButton(with: "", image: "fireworks", action: {
                        currentClick = .beauti
                        isShowImagePicker.toggle()
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: ["FAD7A1".iiColor(), "E96d71".iiColor()], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .black.opacity(0.5), radius: 10)
                    )
                }
            }
        }
        .sheet(isPresented: $isShowImagePicker) {
            AppImagePicker(selectedImage: $editImage, maxSelectCount: 1)
                .ignoresSafeArea(edges: .bottom)
        }
        .onValueChange(of: editImage) { value in
            if let image = value.first {
                if currentClick == .beauti {
                    AppNavManager.share.push(WizardEditImageView(originalImage: image.cgImage))
                }else{
//                    AppNavManager.share.push(WizardGraffitiView(graffitiImage: image))
                }
            }
        }
    }
    
    @ViewBuilder
    var imageListView: some View {
        if photoDateData.count > 0 {
            GeometryReader { geometry in
                let itemWH = (geometry.size.width - 30) / 3
                Grid(horizontalSpacing: 15, verticalSpacing: 15) {
                    let columCount = photoDateData.count / 3 + 1
                    ForEach(0..<columCount) { colum in
                        GridRow {
                            let minIndex = colum * 3
                            let maxIndex = min(minIndex + 3, photoDateData.count)
                            ForEach(minIndex..<maxIndex) { row in
                                takeGrideButton(with: row)
                                    .frame(width: itemWH, height:itemWH)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(color: .black.opacity(0.3), radius: 10)
                            }
                        }
                    }
                }
            }
        }else{
            EmptyView()
        }
    }
    
    func gridButton(with title: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .foregroundStyle(.white)
                .font(.headline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: ["FAD7A1".iiColor(), "E96d71".iiColor()], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .black.opacity(0.5), radius: 10)
        )
    }
    
    func moreGridButton(with title: String, image: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: image)
                    .imageScale(.large)
            }
            .foregroundStyle(.white)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal, 25)
        }
        
    }
    
    func takeGrideButton(with index: Int) -> some View {
        Button {
            let imageList = DBManager.select(with: photoDateData[index].timeRow)
            let list = imageList.map {
                AppPhotoAssetModel(name: $0.photoName, originalImageData: $0.photoData, movData: $0.movData)
            }
            AppNavManager.share.push(WizardTakePhotoListView(photoList: list))
        } label: {
            ZStack {
                if let image = DBManager.select(with: photoDateData[index].timeRow).last?.photoData.cgImage {
                    GeometryReader { geo in
                        Image(cgImage:image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                    
                }
                Text(photoDateData[index].timeRow)
                    .font(.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding([.top, .leading], 6)
                Text("\(string(with: photoDateData[index].totalBytes)) / \(photoDateData[index].itemCount)张")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .font(.subheadline)
                    .padding([.trailing, .bottom], 6)
            }
        }
        .buttonStyle(AppNoEffectButtonStyle())
    }
}


#Preview {
    AppNavBarContainerView {
        WizardMainView()
    }
}
