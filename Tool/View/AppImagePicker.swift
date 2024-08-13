//
//  AppImagePicker.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/20.
//

import SwiftUI
import UIKit
import Photos
import PhotosUI

struct AppImagePicker: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            var selectedImages: [UIImage] = []
            let dispatchGroup = DispatchGroup()
            results.forEach {
                dispatchGroup.enter()
                if $0.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    $0.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let image = image as? UIImage {
                            selectedImages.append(image)
                        }
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.parent.selectedImage += selectedImages
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        
        let parent: AppImagePicker
        
        init(parent: AppImagePicker) {
            self.parent = parent
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: [UIImage]
    var maxSelectCount: Int = 20
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = maxSelectCount
        config.preferredAssetRepresentationMode = .automatic
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
