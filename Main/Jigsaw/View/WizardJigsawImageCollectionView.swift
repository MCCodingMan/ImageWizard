//
//  WizardJigsawImageCollectionView.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/20.
//

import UIKit
import SwiftUI

struct WizardJigsawImageCollectionView: UIViewControllerRepresentable {
    
    
    struct DraggableCellImage: View {
        
        var image: UIImage
        var removeAction: () -> ()
        var body: some View {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .clipped()
                Button {
                   withAnimation {
                        removeAction()
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .resizable()
                }
                .buttonStyle(AppNoEffectButtonStyle())
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.red)
                .font(.body.bold())
            }
        }
    }

    struct DraggableCellImageAdd: View {
        var addImageAction: () -> ()
        var body: some View {
            Button  {
                addImageAction()
            } label: {
                Image(systemName: "plus")
                    .frame(width: 50, height: 50)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    }
            }
        }
    }
    
    class DraggableFlowLayout: UICollectionViewFlowLayout {
        override init() {
            super.init()
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        private func setup() {
            minimumInteritemSpacing = 5
            scrollDirection = .horizontal
            sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
    }

    class DraggableContainerView: UICollectionView {
        override func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            super.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    @Binding var images: [UIImage]
    @Binding var maxCount: Int
    var addImageAction: () -> ()
    
    var isMax: Bool {
        images.count >= maxCount
    }
    
    func makeUIViewController(context: Context) -> UICollectionViewController {
        let layout = DraggableFlowLayout()
        let collectionView = DraggableContainerView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        let viewController = UICollectionViewController(collectionViewLayout: layout)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPressGesture(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        viewController.collectionView = collectionView
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
        uiViewController.collectionView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        let parent: WizardJigsawImageCollectionView
        
        init(parent: WizardJigsawImageCollectionView) {
            self.parent = parent
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if !parent.isMax {
                return parent.images.count + 1
            }else{
                return parent.maxCount
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1 && !parent.isMax {
                let view = DraggableCellImageAdd {[weak self] in
                    self?.parent.addImageAction()
                }
                let imageView = UIHostingController(rootView: view)
                imageView.view.backgroundColor = .clear
                cell.backgroundView = imageView.view
            }else{
                let view = DraggableCellImage(image: parent.images[indexPath.item]) {[weak self] in
                    self?.parent.images.remove(at: indexPath.item)
                }
                let imageView = UIHostingController(rootView: view)
                imageView.view.backgroundColor = .clear
                cell.backgroundView = imageView.view
            }
            return cell
        }
        
        @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
            guard let collectionView = gesture.view as? UICollectionView else { return }
            switch gesture.state {
            case .began:
                guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            case .changed:
                collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            case .ended:
                collectionView.endInteractiveMovement()
            default:
                collectionView.cancelInteractiveMovement()
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            if !parent.isMax && (destinationIndexPath.item == collectionView.numberOfItems(inSection: 0) - 1 || sourceIndexPath.item == collectionView.numberOfItems(inSection: 0) - 1) {
                return
            }
            let movedImage = parent.images.remove(at: sourceIndexPath.item)
            parent.images.insert(movedImage, at: destinationIndexPath.item)
        }
        
        func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
            if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1 && !parent.isMax {
                return false
            }
            return true
        }
        
        func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
            if !parent.isMax && (proposedIndexPath.item == collectionView.numberOfItems(inSection: 0) - 1 || originalIndexPath.item == collectionView.numberOfItems(inSection: 0) - 1) {
                return originalIndexPath
            }
            return proposedIndexPath
        }
    }
}
