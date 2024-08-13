//
//  LivePhotoSignHandler.swift
//  ImageWizard
//
//  Created by zjkj on 2024/5/31.
//

import UIKit
import Photos
import AVFoundation
import MobileCoreServices
import SVProgressHUD

func asyncThrowsTask(task: @escaping () async throws -> ()) {
    Task {
        do {
            try await task()
        } catch { }
    }
}

class LivePhotoSignHandler {
    
    typealias SignURLTuple = (signImageUrl: URL, signVideoUrl: URL)
    
}

extension LivePhotoSignHandler {
    
    static func assemble(imageData: Data, videoData: Data, progress: ((Float) -> Void)? = nil, finish: @escaping (SignURLTuple) -> ()) {
        asyncThrowsTask {
            let tempDirectory = try convertDirectory()
            let identifier = UUID().uuidString.components(separatedBy: "-").last!
            let imageCacheFile = tempDirectory.appendingPathComponent(identifier).appendingPathExtension("heif")
            let videoCacheFile = tempDirectory.appendingPathComponent(identifier).appendingPathExtension("mov")
            try imageData.write(to: imageCacheFile)
            try videoData.write(to: videoCacheFile)
            let resultSign = try await assemble(photoURL: imageCacheFile, videoURL: videoCacheFile, progress: progress)
            finish(resultSign)
            try FileManager.default.removeItem(at: imageCacheFile)
            try FileManager.default.removeItem(at: videoCacheFile)
        }
    }
    
    static func assemble(photoURL: URL, videoURL: URL, progress: ((Float) -> Void)? = nil) async throws -> SignURLTuple {
        let cacheDirectory = try cachesDirectory()
        let identifier = UUID().uuidString
        let pairedPhotoURL = try addIdentifier(
            identifier,
            fromPhotoURL: photoURL,
            to: cacheDirectory.appendingPathComponent(identifier).appendingPathExtension("heif"))
        let pairedVideoURL = try await addIdentifier(
            identifier,
            fromVideoURL: videoURL,
            to: cacheDirectory.appendingPathComponent(identifier).appendingPathExtension("mov"),
            progress: progress)
        
        return SignURLTuple(signImageUrl: pairedPhotoURL, signVideoUrl: pairedVideoURL)
    }
    
    static private func cachesDirectory() throws -> URL {
        if let cachesDirectoryURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let cachesDirectory = cachesDirectoryURL.appendingPathComponent("livePhotos", isDirectory: true)
            if !FileManager.default.fileExists(atPath: cachesDirectory.absoluteString) {
                try? FileManager.default.createDirectory(at: cachesDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            return cachesDirectory
        }
        throw HandlerError.noCachesDirectory
    }
    
    static private func convertDirectory() throws -> URL {
        if let convertDirectoryURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let convertDirectory = convertDirectoryURL.appendingPathComponent("ConvertTempFloder", isDirectory: true)
            if !FileManager.default.fileExists(atPath: convertDirectory.absoluteString) {
                try? FileManager.default.createDirectory(at: convertDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            return convertDirectory
        }
        throw HandlerError.noCachesDirectory
    }
    
    static func liveVideoCacheDirectory() throws -> URL {
        if let liveVideoCacheDirectoryURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let liveVideoCacheDirectory = liveVideoCacheDirectoryURL.appendingPathComponent("LiveVideoCache", isDirectory: true)
            if !FileManager.default.fileExists(atPath: liveVideoCacheDirectory.absoluteString) {
                try? FileManager.default.createDirectory(at: liveVideoCacheDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            return liveVideoCacheDirectory
        }
        throw HandlerError.noCachesDirectory
    }
}

extension LivePhotoSignHandler {
    /// 照片添加签名
    static private func addIdentifier(_ identifier: String, fromPhotoURL photoURL: URL, to destinationURL: URL) throws -> URL {
        guard let imageSource = CGImageSourceCreateWithURL(photoURL as CFURL, nil),
              let imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, nil),
              var imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [AnyHashable : Any] else {
            throw AssembleError.addPhotoIdentifierFailed
        }
        let identifierInfo = ["17" : identifier]
        imageProperties[kCGImagePropertyMakerAppleDictionary] = identifierInfo
        guard let imageDestination = CGImageDestinationCreateWithURL(destinationURL as CFURL, UTType.heic.identifier as CFString, 1, nil) else {
            throw AssembleError.createDestinationImageFailed
        }
        CGImageDestinationAddImage(imageDestination, imageRef, imageProperties as CFDictionary)
        if CGImageDestinationFinalize(imageDestination) {
            return destinationURL
        } else {
            throw AssembleError.createDestinationImageFailed
        }
    }
}

extension LivePhotoSignHandler {
    static private func addIdentifier(_ identifier: String, fromVideoURL videoURL: URL, to destinationURL: URL, progress: ((Float) -> Void)? = nil) async throws -> URL {
        
        let asset = AVURLAsset(url: videoURL)
        // --- Reader ---
        
        // Create the video reader
        let videoReader = try AVAssetReader(asset: asset)
        
        // Create the video reader output
        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else { throw AssembleError.loadTracksFailed }
        let videoReaderOutputSettings : [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderOutputSettings)
        
        // Add the video reader output to video reader
        videoReader.add(videoReaderOutput)
        
        // Create the audio reader
        let audioReader = try AVAssetReader(asset: asset)
        
        // Create the audio reader output
        let audioTrack = try await asset.loadTracks(withMediaType: .audio).first
        let audioReaderOutput: AVAssetReaderTrackOutput? = audioTrack != nil ? AVAssetReaderTrackOutput(track: audioTrack!, outputSettings: nil) : nil
        
        // Add the audio reader output to audioReader
        if let audioReaderOutput {
            audioReader.add(audioReaderOutput)
        }
        
        // --- Writer ---
        
        // Create the asset writer
        let assetWriter = try AVAssetWriter(outputURL: destinationURL, fileType: .mov)
        
        // Create the video writer input
        let videoWriterInputOutputSettings : [String : Any] = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoWidthKey : try await videoTrack.load(.naturalSize).width,
            AVVideoHeightKey : try await videoTrack.load(.naturalSize).height]
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoWriterInputOutputSettings)
        videoWriterInput.transform = try await videoTrack.load(.preferredTransform)
        videoWriterInput.expectsMediaDataInRealTime = true
        
        // Add the video writer input to asset writer
        assetWriter.add(videoWriterInput)
        
        // Create the audio writer input
        let audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
        audioWriterInput.expectsMediaDataInRealTime = false
        
        // Add the audio writer input to asset writer
        assetWriter.add(audioWriterInput)
        
        // Create the identifier metadata
        let identifierMetadata = metadataItem(for: identifier)
        // Create still image time metadata track
        let stillImageTimeMetadataAdaptor = stillImageTimeMetadataAdaptor()
        assetWriter.metadata = [identifierMetadata]
        assetWriter.add(stillImageTimeMetadataAdaptor.assetWriterInput)
        
        // Start the asset writer
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: .zero)
        
        // Add still image metadata
        let frameCount = try await asset.frameCount()
        let stillImagePercent: Float = 0.5
        await stillImageTimeMetadataAdaptor.append(
            AVTimedMetadataGroup(
                items: [stillImageTimeMetadataItem()],
                timeRange: try asset.makeStillImageTimeRange(percent: stillImagePercent, inFrameCount: frameCount)))
        
        async let writingVideoFinished: Bool = withCheckedThrowingContinuation { continuation in
            Task {
                videoReader.startReading()
                videoWriterInput.requestMediaDataWhenReady(on: DispatchQueue(label: "videoWriterInputQueue")) {
                    var currentFrameCount = 0
                    while videoWriterInput.isReadyForMoreMediaData {
                        if let sampleBuffer = videoReaderOutput.copyNextSampleBuffer()  {
                            currentFrameCount += 1
                            if let progress {
                                let progressValue = min(Float(currentFrameCount)/Float(frameCount), 1.0)
                                Task { @MainActor in
                                    progress(progressValue)
                                }
                            }
                            if !videoWriterInput.append(sampleBuffer) {
                                videoReader.cancelReading()
                                continuation.resume(throwing: AssembleError.writingVideoFailed)
                                return
                            }
                        } else {
                            videoWriterInput.markAsFinished()
                            continuation.resume(returning: true)
                            return
                        }
                    }
                }
            }
        }
        
        async let writingAudioFinished: Bool = withCheckedThrowingContinuation { continuation in
            Task {
                audioReader.startReading()
                audioWriterInput.requestMediaDataWhenReady(on: DispatchQueue(label: "audioWriterInputQueue")) {
                    while audioWriterInput.isReadyForMoreMediaData {
                        if let sampleBuffer = audioReaderOutput?.copyNextSampleBuffer() {
                            if !audioWriterInput.append(sampleBuffer) {
                                audioReader.cancelReading()
                                continuation.resume(throwing: AssembleError.writingAudioFailed)
                                return
                            }
                        } else {
                            audioWriterInput.markAsFinished()
                            continuation.resume(returning: true)
                            return
                        }
                    }
                }
            }
        }
        
        await (_, _) = try (writingVideoFinished, writingAudioFinished)
        await assetWriter.finishWriting()
        return destinationURL
    }
    
    static private func metadataItem(for identifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.keySpace = AVMetadataKeySpace.quickTimeMetadata // "mdta"
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        item.key = AVMetadataKey.quickTimeMetadataKeyContentIdentifier as any NSCopying & NSObjectProtocol // "com.apple.quicktime.content.identifier"
        item.value = identifier as any NSCopying & NSObjectProtocol
        return item
    }
    
    static private func stillImageTimeMetadataAdaptor() -> AVAssetWriterInputMetadataAdaptor {
        let quickTimeMetadataKeySpace = AVMetadataKeySpace.quickTimeMetadata.rawValue // "mdta"
        let stillImageTimeKey = "com.apple.quicktime.still-image-time"
        let spec: [NSString : Any] = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString : "\(quickTimeMetadataKeySpace)/\(stillImageTimeKey)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString : kCMMetadataBaseDataType_SInt8]
        var desc : CMFormatDescription? = nil
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(
            allocator: kCFAllocatorDefault,
            metadataType: kCMMetadataFormatType_Boxed,
            metadataSpecifications: [spec] as CFArray,
            formatDescriptionOut: &desc)
        let input = AVAssetWriterInput(
            mediaType: .metadata,
            outputSettings: nil,
            sourceFormatHint: desc)
        return AVAssetWriterInputMetadataAdaptor(assetWriterInput: input)
    }
    
    static private func stillImageTimeMetadataItem() -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = "com.apple.quicktime.still-image-time" as any NSCopying & NSObjectProtocol
        item.keySpace = AVMetadataKeySpace.quickTimeMetadata // "mdta"
        item.value = 0 as any NSCopying & NSObjectProtocol
        item.dataType = kCMMetadataBaseDataType_SInt8 as String // "com.apple.metadata.datatype.int8"
        return item
    }
}

extension LivePhotoSignHandler {
    enum HandlerError: Error {
        case noCachesDirectory
    }

    enum AssembleError: Error {
        case addPhotoIdentifierFailed
        case createDestinationImageFailed
        case writingVideoFailed
        case writingAudioFailed
        case requestFailed
        case loadTracksFailed
    }
}

extension LivePhotoSignHandler {
    
    static func savePhoto(_ data: Data) {
        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            creationRequest.addResource(with: .photo, data: data, options: options)
        } completionHandler: { _, _ in
            DispatchQueue.main.async {
                SVProgressHUD.showSuccess(withStatus: nil)
            }
        }
    }
    
    static func savePhoto(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    static func saveLivePhoto(image: Data, live: URL, completeHandler: @escaping (Bool) -> () = {_ in }) {
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: image, options: nil)
            let videoOptions = PHAssetResourceCreationOptions()
            videoOptions.shouldMoveFile = false
            request.addResource(with: .pairedVideo, fileURL: live, options: videoOptions)
        } completionHandler: {success,error in
            completeHandler(success)
            print(error as Any)
        }
    }
    
    static func saveLivePhoto(image: URL, live: URL, completeHandler: @escaping (Bool) -> () = {_ in }) {
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, fileURL: image, options: nil)
            let videoOptions = PHAssetResourceCreationOptions()
            videoOptions.shouldMoveFile = false
            request.addResource(with: .pairedVideo, fileURL: live, options: videoOptions)
        } completionHandler: {success,error in
            completeHandler(success)
        }
    }
    
    static func saveLivePhoto(image: Data, live: Data, completeHandler: @escaping (Bool) -> () = {_ in }) {
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: image, options: nil)
            let videoOptions = PHAssetResourceCreationOptions()
            videoOptions.shouldMoveFile = false
            request.addResource(with: .pairedVideo, data: live, options: videoOptions)
        } completionHandler: {success,error in
            completeHandler(success)
            print(error as Any)
        }
    }
    
    static func saveLivePhoto(image: URL, live: Data, completeHandler: @escaping (Bool) -> () = {_ in }) {
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, fileURL: image, options: nil)
            let videoOptions = PHAssetResourceCreationOptions()
            videoOptions.shouldMoveFile = false
            request.addResource(with: .pairedVideo, data: live, options: videoOptions)
        } completionHandler: {success,error in
            completeHandler(success)
            print(error as Any)
        }
    }
}

extension AVAsset {
    func frameCount(exact: Bool = false) async throws -> Int {
        let videoReader = try AVAssetReader(asset: self)
        guard let videoTrack = try await self.loadTracks(withMediaType: .video).first else { return 0 }
        if !exact {
            async let duration = CMTimeGetSeconds(self.load(.duration))
            async let nominalFrameRate = Float64(videoTrack.load(.nominalFrameRate))
            return try await Int(duration * nominalFrameRate)
        }
        let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
        videoReader.add(videoReaderOutput)
        videoReader.startReading()
        var frameCount = 0
        while let _ = videoReaderOutput.copyNextSampleBuffer() {
            frameCount += 1
        }
        videoReader.cancelReading()
        return frameCount
    }
    
    func makeStillImageTimeRange(percent: Float, inFrameCount: Int = 0) async throws -> CMTimeRange {
        var time = try await self.load(.duration)
        var frameCount = inFrameCount
        if frameCount == 0 {
            frameCount = try await self.frameCount(exact: true)
        }
        let duration = Int64(Float(time.value) / Float(frameCount))
        time.value = Int64(Float(time.value) * percent)
        return CMTimeRangeMake(start: time, duration: CMTimeMake(value: duration, timescale: time.timescale))
    }
}
