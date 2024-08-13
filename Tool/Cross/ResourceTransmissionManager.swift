//
//  ResourceTransmissionManager.swift
//  ImageWizard
//
//  Created by zjkj on 2024/6/11.
//

import Foundation
import MultipeerConnectivity


class ResourceTransmissionManager: NSObject {
    
    enum ServiceType {
        case sender
        case receiver
        
        func adId() -> String {
            switch self {
                case .sender:
                    return "rsp-sender"
                case .receiver:
                    return "rsp-receiver"
            }
        }
        
        func reci() -> String {
            switch self {
                case .receiver:
                    return "rsp-sender"
                case .sender:
                    return "rsp-receiver"
            }
        }
    }
    
    lazy var myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    var nearbyPeerIDCollected: ((MCPeerID?, MCSessionState) -> ())? = nil
    
    var receivePhotoBlock: ((AppPhotoAssetModel) -> ())? = nil
    
    var session: MCSession?
    var collectionState: MCSessionState = .notConnected
//    var lastCollectionPeerID: MCPeerID?
    var collectionPeerID: MCPeerID?
    /// sender
    
    var nearbyServiceBrowser: MCNearbyServiceBrowser?
    
    var nearbyPeerIDChanged: (([MCPeerID]) -> ())? = nil
    
    var nearbyPeerIDs: [MCPeerID] = [] {
        didSet {
            DispatchQueue.main.async {
                self.nearbyPeerIDChanged?(self.nearbyPeerIDs)
            }
        }
    }
    
    /// receiver
    
    var nearbyServiceAdveriser: MCNearbyServiceAdvertiser?
    
    override init() {
        super.init()
        installSession()
        initalizeHandler()
    }
    
    private func installSession() {
        print(UIDevice.current.name)
        session = MCSession(peer: myPeerID)
        session?.delegate = self
    }
    
    func disConnect() {
        session?.disconnect()
        collectionPeerID = nil
//        lastCollectionPeerID = nil
    }
    
    private func initalizeHandler() {
        initialSenderConnectionHandle()
        initialRecieverConnectionHandle()
    }
    
    func stop() {
        nearbyServiceBrowser?.stopBrowsingForPeers()
        nearbyServiceBrowser = nil
        nearbyPeerIDs = []
        nearbyServiceAdveriser?.stopAdvertisingPeer()
        nearbyServiceAdveriser = nil
        collectionPeerID = nil
//        lastCollectionPeerID = nil
    }
}

extension ResourceTransmissionManager {
    func shareData(with photoModel: AppPhotoAssetModel) {
        print("1")
        DispatchQueue.global().async {[self] in
            guard let session, let peerID = session.connectedPeers.first else { return }
            do {
                let streamName = "IMG_ASSET_" + photoModel.name
                // 开始发送视频流
                let outputStream = try session.startStream(withName: streamName, toPeer: peerID)
                // 打开输出流
                outputStream.open()
                // 将视频文件数据写入输出流
                let bufferSize = 1024
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                let modelData = try photoModel.convertPhotoToData()
                var bytesRemaining = modelData.count
                var bytesWritten = 0
                while bytesRemaining > 0 {
                    let bytesToWrite = min(bufferSize, bytesRemaining)
                    modelData.copyBytes(to: buffer, from: bytesWritten..<bytesWritten+bytesToWrite)
                    outputStream.write(buffer, maxLength: bytesToWrite)
                    
                    bytesRemaining -= bytesToWrite
                    bytesWritten += bytesToWrite
                    print("3")
                }
                
                print("2")
                // 关闭输出流
                outputStream.close()
                
            } catch {
                print("Error starting stream or sending video: \(error.localizedDescription)")
            }
        }
    }
}

extension ResourceTransmissionManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .notConnected:
                print("未连接")
                collectionPeerID = nil
                nearbyPeerIDCollected?(nil, state)
                nearbyServiceBrowser?.stopBrowsingForPeers()
                nearbyServiceAdveriser?.stopAdvertisingPeer()
                nearbyServiceBrowser?.startBrowsingForPeers()
                nearbyServiceAdveriser?.startAdvertisingPeer()
            case .connecting:
                print("连接中")
                nearbyPeerIDCollected?(peerID, state)
                nearbyPeerIDs.removeAll(where: {$0.displayName == peerID.displayName})
            case .connected:
                print("已连接")
                collectionPeerID = peerID
                nearbyPeerIDCollected?(collectionPeerID, state)
            @unknown default:
                break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
        print("接收普通数据:" + string)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("开始传输数据")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("接受")
        // 接收到数据流
        DispatchQueue.global().async {
            // 创建临时文件路径
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath = (documentsPath as NSString).appendingPathComponent(streamName)
            
            // 创建可写入的文件流
            let fileStream = OutputStream(toFileAtPath: filePath, append: false)
            fileStream?.open()
            
            // 读取数据流并写入临时文件
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            var bytesRead = 0
            
            stream.open()
            repeat {
                bytesRead = stream.read(buffer, maxLength: bufferSize)
                if bytesRead > 0 {
                    fileStream?.write(buffer, maxLength: bytesRead)
                }
            } while bytesRead > 0
            
            stream.close()
            fileStream?.close()
            print("完成")
            if let data = try? Data(contentsOf: NSURL(fileURLWithPath: filePath) as URL) {
                if let photoModel = try? AppPhotoAssetModel.convertDataToPhoto(data) {
                    DBManager.insert(photo: PhotoInfoTuple(name: photoModel.name, imageData: photoModel.originalImageData!, movData: photoModel.movData))
                    DispatchQueue.main.async {
                        self.receivePhotoBlock?(photoModel)
                    }
                }
            }
            if FileManager.default.isDeletableFile(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: filePath)
            }
        }
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("完成1")
    }

}

extension ResourceTransmissionManager {
    
    private func initialSenderConnectionHandle() {
        installSession()
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: ServiceType.sender.reci())
        nearbyServiceBrowser?.delegate = self
        nearbyServiceBrowser?.startBrowsingForPeers()
    }
    
    func connect(with peerID: MCPeerID) {
        if let session, collectionPeerID == nil {
            nearbyServiceBrowser?.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
    }
}

extension ResourceTransmissionManager {
    
    private func initialRecieverConnectionHandle() {
        installSession()
        nearbyServiceAdveriser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: ServiceType.receiver.adId())
        nearbyServiceAdveriser?.delegate = self
        nearbyServiceAdveriser?.startAdvertisingPeer()
    }
}

extension ResourceTransmissionManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {

        print("发现节点" + peerID.displayName)
//        if collectionPeerID == nil && lastCollectionPeerID != nil {
//            if peerID.displayName == lastCollectionPeerID!.displayName {
//                connect(with: peerID)
//            }
//        }
        if collectionPeerID?.displayName != peerID.displayName && !nearbyPeerIDs.contains(where: {$0.displayName == peerID.displayName}) {
            nearbyPeerIDs.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("节点丢失")
        nearbyPeerIDs.removeAll(where: {$0.displayName == peerID.displayName})
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("未发现节点" + error.localizedDescription)
    }
}

extension ResourceTransmissionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("收到\(peerID.displayName)的连接请求")
        invitationHandler(true, self.session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("节点广播失败" + advertiser.myPeerID.displayName)
    }
}

