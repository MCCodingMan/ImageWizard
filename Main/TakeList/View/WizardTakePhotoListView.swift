//
//  IWTakePhotoListView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/28.
//

import SwiftUI
import Photos
import SVProgressHUD

struct WizardTakePhotoListView: View {
    @State var photoList: [AppPhotoAssetModel]
    @State private var selectIndexs: [Int] = [] {
        didSet {
            isAllSelect = selectIndexs.count == photoList.count
        }
    }
    @State private var editAnimate: Bool = false
    @State private var selectState = false
    @State private var isAllSelect = false
    @State private var isPresent = false
    @State private var isSavePresent = false
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0, maximum: .infinity)), count: 3), spacing: 10, content: {
                    ForEach(Array(photoList.enumerated()), id: \.0) { idx, imageModel in
                        ZStack(alignment: .bottomTrailing, content: {
                            AppImageView(model: imageModel) {
                                AppNavManager.share.push(WizardImageDetailView(asset: imageModel))
                            }
                            .frame(width: (IWAppInfo.screenWidth - 24.0 - 20.0) / 3.0,
                                   height: (IWAppInfo.screenWidth - 24.0 - 20.0) / 3.0)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            if selectState {
                                Image(systemName: selectIndexs.contains(idx) ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .foregroundStyle(.blue)
                                    .frame(width: 20, height: 20)
                                    .padding(6)
                                    .onTapGesture {
                                        if selectIndexs.contains(idx) {
                                            selectIndexs.removeAll(where: {$0 == idx})
                                        }else{
                                            selectIndexs.append(idx)
                                        }
                                    }
                            }
                        })
                        .contextMenu {
                            Button("选择") {
                                selectState.toggle()
                                if selectIndexs.contains(idx) {
                                    selectIndexs.removeAll(where: {$0 == idx})
                                }else{
                                    selectIndexs.append(idx)
                                }
                            }
                            
                            Button("删除") {
                                DBManager.delete(photoList[idx].name)
                                photoList.remove(at: idx)
                                selectIndexs.removeAll(where: {$0 == idx})
                            }
                            
                        }
                    }
                })
                .padding(.all, 12.0)
            }
            if selectState {
                bottomOperationView
                    .transition(.move(edge: .bottom))
                    .frame(height: 34 + IWAppInfo.bottomSafeHeight)
                    .background(Color.gray.opacity(0.1).ignoresSafeArea())
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .customAlertContent(isShow: $isPresent, titleContent: {
            Text("删除")
        }, messageContent: {
            Text("是否删除选中的照片")
        }, cancelContent: {
            Text("取消").foregroundStyle(.blue)
        }, sureContent: {
            Text("确认").foregroundStyle(.red)
        }, sureAction: {
            var deleteArray: [String] = []
            for index in selectIndexs {
                deleteArray.append(photoList[index].name)
            }
            photoList = photoList.enumerated().filter({!selectIndexs.contains($0.offset)}).map({$0.1})
            selectIndexs.removeAll()
            DispatchQueue(label: "removeQueue").async {
                DBManager.delete(deleteArray)
            }
        })
        .customAlertContent(isShow: $isSavePresent, titleContent: {
            Text("保存")
        }, messageContent: {
            Text("是否保存选中的照片")
        }, cancelContent: {
            Text("取消").foregroundStyle(.blue)
        }, sureContent: {
            Text("确认").foregroundStyle(.red)
        }, sureAction: {
            var saveArray: [AppPhotoAssetModel] = []
            for index in selectIndexs {
                saveArray.append(photoList[index])
            }
            for imageModel in saveArray {
                if let originalImageData = imageModel.originalImageData {
                    if let movData = imageModel.movData {
                        LivePhotoSignHandler.assemble(imageData: originalImageData, videoData: movData) { progress in
                            
                        } finish: { (imageFile, videoFile) in
                            LivePhotoSignHandler.saveLivePhoto(image: imageFile, live: videoFile) { success in
                                print(success)
                                DispatchQueue.main.async {
                                    SVProgressHUD.showSuccess(withStatus: nil)
                                }
                            }
                        }
                    }else{
                        LivePhotoSignHandler.savePhoto(originalImageData)
                    }
                }
            }
        })
        .customNavigationTitle("图集")
        .customNavigationMoreItemHidden(false)
        .customNavigationMoreSystemImage("r.square.on.square")
        .customNavigationMoreAction {
            withAnimation(.easeInOut) {
                selectState.toggle()
            }
        }
    }
    var bottomOperationView: some View {
        VStack {
            HStack {
                HStack(spacing: 0) {
                    Image(systemName: isAllSelect ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .padding(6)
                    Text("全选")
                }
                .foregroundStyle(.blue)
                .padding(6)
                .onTapGesture {
                    if isAllSelect {
                        selectIndexs.removeAll()
                    }else{
                        selectIndexs.removeAll()
                        selectIndexs.append(contentsOf: photoList.indices)
                    }
                }
                
                Spacer()
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.blue)
                    .padding(6)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isSavePresent.toggle()
                        }
                    }
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.red)
                    .padding(6)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isPresent.toggle()
                        }
                    }
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

