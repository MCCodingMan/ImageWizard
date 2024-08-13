//
//  IWMineView.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/4/7.
//

import SwiftUI

struct WizardMineView: View {
    
    @State private var photoDateData: [DBManager.PhotoDateModel] = []
    
    var body: some View {
        ScrollView {
            Spacer(minLength: 10)
            LazyVStack {
                ForEach(photoDateData, id: \.self) { info in
                    HStack {
                        Text(info.timeRow)
                            .padding(.leading, 6)
                        Spacer()
                        Text("\(string(with: info.totalBytes)) / \(info.itemCount)张")
                            .font(Font.system(size: 12))
                            .foregroundStyle(.gray)
                            .padding(.trailing, 6)
                    }
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.6))                    
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)
                    )
                    .padding(.horizontal)
                    .onTapGesture {
                        let imageList = DBManager.select(with: info.timeRow)
                        let list = imageList.map {
                            AppPhotoAssetModel(name: $0.photoName, originalImageData: $0.photoData, movData: $0.movData)
                        }
                        AppNavManager.share.push(WizardTakePhotoListView(photoList: list))
                    }
                }
            }
        }
        .background(Color.clear)
        .onAppear {
            photoDateData = DBManager.selectTimeList()
        }
    }
}

#Preview {
    WizardMineView()
}
