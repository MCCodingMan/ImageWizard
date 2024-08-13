//
//  WizardJigsawRuleView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/20.
//

import SwiftUI
import SVProgressHUD

struct WizardJigsawRuleView: View {
    @Binding var currentRule: JigsawRule
    var body: some View {
        VStack {
            Spacer()
            Divider()
                .frame(width: 50, height: 5)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 2.5))
            ScrollView {
                LazyHStack(spacing: 20) {
                    ForEach(JigsawRule.allCases, id: \.self) { rule in
                        Button {
                            withAnimation {
                                currentRule = rule
                            }
                        } label: {
                            Image(rule.image)
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(AppNoEffectButtonStyle())
                        
                    }
                }
            }
            .padding(.top, 10)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: ["f36265".iiColor(), "a1051d".iiColor()], startPoint: .topLeading, endPoint: .bottomTrailing))
        .customCornerRadius(15, rectCorner: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.3), radius: 10)
    }
    
    enum JigsawRule: CaseIterable {
        case longImage
        case leftOneRightTwo
        case leftTwoRightOne
        case fourGrid
        case fourGrid3_2
        case oneBackOtherFront
        case nineGrid
        
        var image: String {
            switch self {
                case .longImage:
                    return "icon_jigsaw_0"
                case .leftOneRightTwo:
                    return "icon_jigsaw_1"
                case .leftTwoRightOne:
                    return "icon_jigsaw_2"
                case .fourGrid:
                    return "icon_jigsaw_3"
                case .fourGrid3_2:
                    return "icon_jigsaw_4"
                case .oneBackOtherFront:
                    return "icon_jigsaw_5"
                case .nineGrid:
                    return "icon_jigsaw_6"
            }
        }
        
        var maxCount: Int {
            switch self {
                case .longImage:
                    return 100
                case .leftOneRightTwo:
                    return 3
                case .leftTwoRightOne:
                    return 3
                case .fourGrid:
                    return 4
                case .fourGrid3_2:
                    return 4
                case .oneBackOtherFront:
                    return 6
                case .nineGrid:
                    return 9
            }
        }
        
        @ViewBuilder
        func ruleView(with images: Binding<[UIImage]>, sheet: Binding<Bool>, save: Binding<Bool>) -> some View {
            switch self {
                case .longImage:
                    WizardJigsawView.LongImageView(images: images, isSelectImage: sheet, isSave: save)
                case .leftOneRightTwo:
                    WizardJigsawView.LeftOneView(images: images, isSelectImage: sheet, isSave: save)
                        .overlay { Rectangle().stroke(lineWidth: 1).fill(.blue) }
                        .padding(.horizontal, 5)
                case .leftTwoRightOne:
                    WizardJigsawView.RightOneView(images: images, isSelectImage: sheet, isSave: save)
                        .overlay { Rectangle().stroke(lineWidth: 1).fill(.blue) }
                        .padding(.horizontal, 5)
                case .fourGrid:
                    WizardJigsawView.FourGridView(images: images, isSelectImage: sheet, isSave: save)
                        .overlay { Rectangle().stroke(lineWidth: 1).fill(.blue) }
                        .padding(.horizontal, 5)
                case .fourGrid3_2:
                    WizardJigsawView.FourGrid3_2View(images: images, isSelectImage: sheet, isSave: save)
                        .overlay { Rectangle().stroke(lineWidth: 1).fill(.blue) }
                        .padding(.horizontal, 5)
                case .oneBackOtherFront:
                    WizardJigsawView.SixGridView(images: images, isSelectImage: sheet, isSave: save)
                        .overlay { Rectangle().stroke(lineWidth: 1).fill(.blue) }
                        .padding(.horizontal, 5)
                case .nineGrid:
                    WizardJigsawView.NineGridView(images: images, isSelectImage: sheet, isSave: save)
                        .overlay { Rectangle().stroke(lineWidth: 1).fill(.blue) }
                        .padding(.horizontal, 5)
            }
        }
    }
}

fileprivate protocol JigsawSaveImageProtocol: View { }

fileprivate extension JigsawSaveImageProtocol {
    @MainActor 
    @discardableResult
    func saveJigsawImage(_ imageAvailable: () -> Bool) -> UIImage? {
        if imageAvailable() {
            SVProgressHUD.showError(withStatus: "还没有添加照片哦！")
            return nil
        }
        return ImageRenderer(content: self.body).uiImage
    }
}

extension WizardJigsawView {
    
    struct LongImageView: JigsawSaveImageProtocol {
        
        @Binding var images: [UIImage]
        
        @Binding var isSelectImage: Bool
        
        @Binding var isSave: Bool
            
        var body: some View {
            Group {
                if images.count > 0 {
                    content
                }else{
                    Button {
                        isSelectImage.toggle()
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: "plus")
                                .imageScale(.large)
                            Text("添加照片")
                        }
                        .frame(width: 200, height: 200)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        }
                    }
                }
            }
            .onValueChange(of: isSave) { value in
//               if let image = saveJigsawImage({
//                    return images.count == 0
//               }) {
//                   images.append(image)
//               }
                if let image = ImageRenderer(content: content).uiImage {
                    images.append(image)
                }
            }
        }
        
        var content: some View {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal)
        }
    }
    
    struct ImageRenderView: View {
        @Binding var image: UIImage?
        var addImageAction: () -> ()
        
        var body: some View {
            if let image {
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            }else{
                Button {
                    addImageAction()
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        }
                }
                .padding(5)
            }
        }
    }
    
    struct LeftOneView: JigsawSaveImageProtocol {
        
        @Binding var images: [UIImage]
        
        @Binding var isSelectImage: Bool
        
        @Binding var isSave: Bool
        func imageAt(_ index: Int) -> Binding<UIImage?> {
            return Binding {
                if index >= images.count {
                    return nil
                }
                return images[index]
            } set: { _ in }
        }
        
        var body: some View {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ImageRenderView(image: imageAt(0)) {
                        if images.count == 3 {return}
                        isSelectImage.toggle()
                    }
                    .frame(width: geo.size.width / 2)
                    VStack(spacing: 0) {
                        ImageRenderView(image: imageAt(1)) {
                            if images.count == 3 {return}
                            isSelectImage.toggle()
                        }
                        ImageRenderView(image: imageAt(2)) {
                            if images.count == 3 {return}
                            isSelectImage.toggle()
                        }
                    }
                    .frame(width: geo.size.width / 2)
                }
            }
            .onValueChange(of: isSave) { value in
                if let image = saveJigsawImage({
                    return images.count == 0
                }) {
                    images.append(image)
                }
            }
        }
    }
    
    struct RightOneView: JigsawSaveImageProtocol {
        
        @Binding var images: [UIImage]
        
        @Binding var isSelectImage: Bool
        
        @Binding var isSave: Bool
        func imageAt(_ index: Int) -> Binding<UIImage?> {
            return Binding {
                if index >= images.count {
                    return nil
                }
                return images[index]
            } set: { _ in }
        }
        
        var body: some View {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ImageRenderView(image: imageAt(0)) {
                            if images.count == 3 {return}
                            isSelectImage.toggle()
                        }
                        ImageRenderView(image: imageAt(2)) {
                            if images.count == 3 {return}
                            isSelectImage.toggle()
                        }
                    }
                    .frame(width: geo.size.width / 2)
                    ImageRenderView(image: imageAt(1)) {
                        if images.count == 3 {return}
                        isSelectImage.toggle()
                    }
                    .frame(width: geo.size.width / 2)
                }
            }
            .onValueChange(of: isSave) { value in
                if let image = saveJigsawImage({
                     return images.count == 0
                }) {
                    images.append(image)
                }
            }
        }
    }
    
    struct FourGridView: JigsawSaveImageProtocol {
        
        @Binding var images: [UIImage]
        
        @Binding var isSelectImage: Bool
        
        @Binding var isSave: Bool
        func imageAt(_ index: Int) -> Binding<UIImage?> {
            return Binding {
                if index >= images.count {
                    return nil
                }
                return images[index]
            } set: { _ in }
        }
        
        var body: some View {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ImageRenderView(image: imageAt(0)) {
                            if images.count == 4 {return}
                            isSelectImage.toggle()
                        }
                        ImageRenderView(image: imageAt(2)) {
                            if images.count == 4 {return}
                            isSelectImage.toggle()
                        }
                    }
                    .frame(width: geo.size.width / 2)
                    VStack(spacing: 0) {
                        ImageRenderView(image: imageAt(1)) {
                            if images.count == 4 {return}
                            isSelectImage.toggle()
                        }
                        ImageRenderView(image: imageAt(3)) {
                            if images.count == 4 {return}
                            isSelectImage.toggle()
                        }
                    }
                    .frame(width: geo.size.width / 2)
                }
            }
            .onValueChange(of: isSave) { value in
                if let image = saveJigsawImage({
                     return images.count == 0
                }) {
                    images.append(image)
                }
            }
        }
    }
    
    struct FourGrid3_2View: JigsawSaveImageProtocol {
        
        @Binding var images: [UIImage]
        
        @Binding var isSelectImage: Bool
        
        @Binding var isSave: Bool
        func imageAt(_ index: Int) -> Binding<UIImage?> {
            return Binding {
                if index >= images.count {
                    return nil
                }
                return images[index]
            } set: { _ in }
        }
        
        var body: some View {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ImageRenderView(image: imageAt(0)) {
                            if images.count == 4 {return}
                            isSelectImage.toggle()
                        }
                        ImageRenderView(image: imageAt(2)) {
                            if images.count == 4 {return}
                            isSelectImage.toggle()
                        }
                        .frame(height: geo.size.height / 2.5)
                    }
                    .frame(width: geo.size.width / 2)
                    VStack(spacing: 0) {
                        ImageRenderView(image: imageAt(1)) {
                            if images.count == 4 {return}
                            isSelectImage.toggle()
                        }
                        .frame(height: geo.size.height / 2.5)
                        ImageRenderView(image: imageAt(3)) {
                            if images.count == 4 {return}
                            isSelectImage.toggle()
                        }
                    }
                    .frame(width: geo.size.width / 2)
                }
            }
            .onValueChange(of: isSave) { value in
                if let image = saveJigsawImage({
                     return images.count == 0
                }) {
                    images.append(image)
                }
            }
        }
    }
    
    struct SixGridView: JigsawSaveImageProtocol {
        
        @Binding var images: [UIImage]
        
        @Binding var isSelectImage: Bool
        
        @Binding var isSave: Bool
        func imageAt(_ index: Int) -> Binding<UIImage?> {
            return Binding {
                if index >= images.count {
                    return nil
                }
                return images[index]
            } set: { _ in }
        }
        
        var body: some View {
            GeometryReader { geo in
                let spacing: Double = 10.0
                let smallSize = (geo.size.width - spacing * 2) / 3
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        ImageRenderView(image: imageAt(0)) {
                            if images.count == 6 {return}
                            isSelectImage.toggle()
                        }
                        VStack(spacing: spacing) {
                            ImageRenderView(image: imageAt(1)) {
                                if images.count == 6 {return}
                                isSelectImage.toggle()
                            }
                            .frame(width: smallSize, height: smallSize)
                            ImageRenderView(image: imageAt(2)) {
                                if images.count == 6 {return}
                                isSelectImage.toggle()
                            }
                            .frame(width: smallSize, height: smallSize)
                        }
                    }
                    HStack(spacing: spacing) {
                        ImageRenderView(image: imageAt(3)) {
                            if images.count == 6 {return}
                            isSelectImage.toggle()
                        }
                        .frame(width: smallSize, height: smallSize)
                        ImageRenderView(image: imageAt(4)) {
                            if images.count == 6 {return}
                            isSelectImage.toggle()
                        }
                        .frame(width: smallSize, height: smallSize)
                        ImageRenderView(image: imageAt(5)) {
                            if images.count == 6 {return}
                            isSelectImage.toggle()
                        }
                        .frame(width: smallSize, height: smallSize)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.width)
            }
            .onValueChange(of: isSave) { value in
                if let image = saveJigsawImage({
                     return images.count == 0
                }) {
                    images.append(image)
                }
            }
        }
    }
    
    struct NineGridView: JigsawSaveImageProtocol {
        
        @Binding var images: [UIImage]
        
        @Binding var isSelectImage: Bool
        
        @Binding var isSave: Bool
        func imageAt(_ index: Int) -> Binding<UIImage?> {
            return Binding {
                if index >= images.count {
                    return nil
                }
                return images[index]
            } set: { _ in }
        }
        
        var body: some View {
            GeometryReader { geo in
                let gridWidth = (geo.size.width - 10) / 3
                Grid(horizontalSpacing: 5, verticalSpacing: 5) {
                    ForEach(0..<3) { section in
                        GridRow {
                            ForEach(0..<3) { row in
                                ImageRenderView(image: imageAt(section * 3 + row)) {
                                    if images.count == 9 {return}
                                    isSelectImage.toggle()
                                }
                                .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
                .background(images.count == 9 ? Color.white : nil)
                .frame(width: geo.size.width)
                .aspectRatio(1, contentMode: .fill)
            }
            .onValueChange(of: isSave) { value in
                if let image = saveJigsawImage({
                     return images.count == 0
                }) {
                    images.append(image)
                    LivePhotoSignHandler.savePhoto(image)
                }
            }
        }
    }
}
