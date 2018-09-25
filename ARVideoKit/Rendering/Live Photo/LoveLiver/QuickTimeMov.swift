
//
//  QuickTimeMov.swift
//  LoveLiver
//
//  Created by mzp on 10/10/15.
//  Copyright © 2015 mzp. All rights reserved.
//

import Foundation
import AVFoundation

@available(iOS 11.0, *)
class QuickTimeMov {
    private let kKeyContentIdentifier =  "com.apple.quicktime.content.identifier"
    private let kKeyStillImageTime = "com.apple.quicktime.still-image-time"
    private let kKeySpaceQuickTimeMetadata = "mdta"
    private let path: String
    private let dummyTimeRange = CMTimeRange(start: CMTime(value: 0, timescale: 1000), duration: CMTime(value: 200, timescale: 3000))

    private lazy var asset: AVURLAsset = {
        let url = URL(fileURLWithPath: self.path)
        return AVURLAsset(url: url)
    }()

    init(path: String) {
        self.path = path
    }

    func readAssetIdentifier() -> String? {
        for item in metadata() {
            if item.key as? String == kKeyContentIdentifier &&
                item.keySpace!.rawValue == kKeySpaceQuickTimeMetadata {
                return item.value as? String
            }
        }
        return nil
    }

    func readStillImageTime() -> NSNumber? {
        if let track = track(AVMediaType.metadata) {
            let (reader, output) = try! self.reader(track, settings: nil)
            reader.startReading()

            while true {
                guard let buffer = output.copyNextSampleBuffer() else { return nil }
                if CMSampleBufferGetNumSamples(buffer) > 0 {
                    let group = AVTimedMetadataGroup(sampleBuffer: buffer)
                    for item in group?.items ?? [] {
                        if item.key as? String == kKeyStillImageTime &&
                            item.keySpace!.rawValue == kKeySpaceQuickTimeMetadata {
                                return item.numberValue
                        }
                    }
                }
            }
        }
        return nil
    }

    func write(_ dest: String, assetIdentifier: String) {
        
        var audioReader: AVAssetReader? = nil
        var audioWriterInput: AVAssetWriterInput? = nil
        var audioReaderOutput: AVAssetReaderOutput? = nil
        do {
            // --------------------------------------------------
            // reader for source video
            // --------------------------------------------------
            guard let track = self.track(AVMediaType.video) else {
                logAR.message("not found video track")
                return
            }
            let readerSettings: [String: AnyObject] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as AnyObject
            ]
            let (reader, output) = try self.reader(track,
                                                   settings: readerSettings)
            // --------------------------------------------------
            // writer for mov
            // --------------------------------------------------
            let writer = try AVAssetWriter(outputURL: URL(fileURLWithPath: dest), fileType: AVFileType.mov)
            writer.metadata = [metadataFor(assetIdentifier)]
            
            // video track
            let input = AVAssetWriterInput(mediaType: AVMediaType.video,
                                           outputSettings: videoSettings(track.naturalSize))
            input.expectsMediaDataInRealTime = true
            input.transform = track.preferredTransform
            writer.add(input)
            
            
            let url = URL(fileURLWithPath: self.path)
            let aAudioAsset: AVAsset = AVAsset(url: url)
            
            if aAudioAsset.tracks.count > 1 {
                logAR.message("Has Audio")
                //setup audio writer
                audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
                
                audioWriterInput?.expectsMediaDataInRealTime = false
                if writer.canAdd(audioWriterInput!){
                    writer.add(audioWriterInput!)
                }
                //setup audio reader
                let audioTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio).first!
                audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
                
                do{
                    audioReader = try AVAssetReader(asset: aAudioAsset)
                } catch {
                    fatalError("Unable to read Asset: \(error): ")
                }
                //let audioReader: AVAssetReader = AVAssetReader(asset: aAudioAsset, error: &error)
                if (audioReader?.canAdd(audioReaderOutput!))! {
                    audioReader?.add(audioReaderOutput!)
                } else {
                    logAR.message("cant add audio reader")
                }
            }
            
            // metadata track
            let adapter = metadataAdapter()
            writer.add(adapter.assetWriterInput)
            
            // --------------------------------------------------
            // creating video
            // --------------------------------------------------
            writer.startWriting()
            reader.startReading()
            writer.startSession(atSourceTime: CMTime.zero)
            
            // write metadata track
            adapter.append(AVTimedMetadataGroup(items: [metadataForStillImageTime()],
                                                timeRange: dummyTimeRange))
            
            // write video track
            input.requestMediaDataWhenReady(on: DispatchQueue(label: "assetVideoWriterQueue", attributes: [])) {
                while(input.isReadyForMoreMediaData) {
                    if reader.status == .reading {
                        if let buffer = output.copyNextSampleBuffer() {
                            if !input.append(buffer) {
                                logAR.message("cannot write: \(String(describing: writer.error))")
                                reader.cancelReading()
                            }
                        }
                    } else {
                        input.markAsFinished()
                        if reader.status == .completed && aAudioAsset.tracks.count > 1 {
                            audioReader?.startReading()
                            writer.startSession(atSourceTime: CMTime.zero)
                            let media_queue = DispatchQueue(label: "assetAudioWriterQueue", attributes: [])
                            audioWriterInput?.requestMediaDataWhenReady(on: media_queue) {
                                while (audioWriterInput?.isReadyForMoreMediaData)! {
                                    let sampleBuffer2:CMSampleBuffer? = audioReaderOutput?.copyNextSampleBuffer()
                                    if audioReader?.status == .reading && sampleBuffer2 != nil {
                                        if !(audioWriterInput?.append(sampleBuffer2!))! {
                                            audioReader?.cancelReading()
                                        }
                                    } else {
                                        audioWriterInput?.markAsFinished()
                                        logAR.message("Audio writer finish")
                                        writer.finishWriting() {
                                            if let e = writer.error {
                                                logAR.message("cannot write: \(e)")
                                            } else {
                                                logAR.message("finish writing.")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            logAR.message("Video Reader not completed")
                            writer.finishWriting() {
                                if let e = writer.error {
                                    logAR.message("cannot write: \(e)")
                                } else {
                                    logAR.message("finish writing.")
                                }
                            }
                        }
                    }
                }
            }
            while writer.status == .writing {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            }
            if let e = writer.error {
                logAR.message("cannot write: \(e)")
            }
        } catch {
            logAR.message("error")
        }
    }

    private func metadata() -> [AVMetadataItem] {
        return asset.metadata(forFormat: AVMetadataFormat.quickTimeMetadata)
    }

    private func track(_ mediaType: AVMediaType) -> AVAssetTrack? {
        return asset.tracks(withMediaType: mediaType).first
    }

    private func reader(_ track: AVAssetTrack, settings: [String: AnyObject]?) throws -> (AVAssetReader, AVAssetReaderOutput) {
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        let reader = try AVAssetReader(asset: asset)
        reader.add(output)
        return (reader, output)
    }

    private func metadataAdapter() -> AVAssetWriterInputMetadataAdaptor {
        let spec: NSDictionary = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString:
            "\(kKeySpaceQuickTimeMetadata)/\(kKeyStillImageTime)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString:
            "com.apple.metadata.datatype.int8"            ]

        var desc: CMFormatDescription? = nil
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(allocator: kCFAllocatorDefault, metadataType: kCMMetadataFormatType_Boxed, metadataSpecifications: [spec] as CFArray, formatDescriptionOut: &desc)

//        CMFormatDescription.createForMetadata(allocator: kCFAllocatorDefault, metadataType: kCMMetadataFormatType_Boxed, metadataSpecifications: [spec] as CFArray, formatDescriptionOut: &desc)
        let input = AVAssetWriterInput(mediaType: AVMediaType.metadata,
            outputSettings: nil, sourceFormatHint: desc)
        return AVAssetWriterInputMetadataAdaptor(assetWriterInput: input)
    }

    private func videoSettings(_ size: CGSize) -> [String: AnyObject] {
        return [
            AVVideoCodecKey: AVVideoCodecType.h264 as AnyObject,
            AVVideoWidthKey: size.width as AnyObject,
            AVVideoHeightKey: size.height as AnyObject
        ]
    }

    private func metadataFor(_ assetIdentifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = kKeyContentIdentifier as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: kKeySpaceQuickTimeMetadata)
        item.value = assetIdentifier as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
    }

    private func metadataForStillImageTime() -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = kKeyStillImageTime as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: kKeySpaceQuickTimeMetadata)
        item.value = 0 as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.int8"
        return item
    }
}
