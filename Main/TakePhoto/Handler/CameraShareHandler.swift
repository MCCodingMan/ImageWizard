//
//  CameraShareHandler.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/12.
//

import UIKit
import MultipeerConnectivity

class CameraShareHandler: ObservableObject {
    
    @Published var peerIDs: [MCPeerID] = []
    
    @Published var collectedPeerID: MCPeerID?
    
    @Published var colletedState: MCSessionState = .notConnected
    
    @Published var recievePhotoModel: AppPhotoAssetModel?
    
    private var crossShare: ResourceTransmissionManager?
    
    func startSearch() {
        initalizeCross()
    }
    
    func stopSearch() {
        dissCollection()
        crossShare?.stop()
        crossShare = nil
    }
    
    
    func dissCollection() {
        crossShare?.disConnect()
    }
    
    private func initalizeCross() {
        if crossShare == nil {
            crossShare = ResourceTransmissionManager()
            crossShare?.nearbyPeerIDChanged = {[weak self] ids in
                self?.peerIDs = ids
            }
            crossShare?.nearbyPeerIDCollected = {[weak self] id, state in
                DispatchQueue.main.async {
                    self?.collectedPeerID = id
                    self?.colletedState = state
                }
            }
            
            crossShare?.receivePhotoBlock = {[weak self] model in
                self?.recievePhotoModel = model
            }
        }
    }
    
    func colletion(with peerID: MCPeerID) {
        crossShare?.connect(with: peerID)
    }
    
    func sharePhoto(with model: AppPhotoAssetModel) {
        if collectedPeerID != nil {
            crossShare?.shareData(with: model)
        }
    }
}
