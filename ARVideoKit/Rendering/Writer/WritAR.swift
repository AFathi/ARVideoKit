//
//  WritAR.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/19/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

@available(iOS 11.0, *)
class WritAR: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    private var assetWriter: AVAssetWriter!
    private var videoInput: AVAssetWriterInput!
    private var audioInput: AVAssetWriterInput!
    private var session: AVCaptureSession!
    
    private var pixelBufferInput: AVAssetWriterInputPixelBufferAdaptor!
    private var videoOutputSettings: Dictionary<String, AnyObject>!
    private var audioSettings: [String: Any]?

    let audioBufferQueue = DispatchQueue(label: "com.ahmedbekhit.AudioBufferQueue")

    private var isRecording: Bool = false
    
    var delegate: RecordARDelegate?
    var videoInputOrientation: ARVideoOrientation = .auto

    init(output: URL, width: Int, height: Int, adjustForSharing: Bool, audioEnabled: Bool, orientaions:[ARInputViewOrientation], queue: DispatchQueue, allowMix: Bool) {
        super.init()
        do {
            assetWriter = try AVAssetWriter(outputURL: output, fileType: AVFileType.mp4)
        } catch {
            // FIXME: handle when failed to allocate AVAssetWriter.
            return
        }
        if audioEnabled {
            if allowMix {
                let audioOptions: AVAudioSession.CategoryOptions = [.mixWithOthers , .allowBluetooth, .defaultToSpeaker, .interruptSpokenAudioAndMixWithOthers]
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.spokenAudio, options: audioOptions)
                try? AVAudioSession.sharedInstance().setActive(true)
            }
            AVAudioSession.sharedInstance().requestRecordPermission({ permitted in
                if permitted {
                    self.prepareAudioDevice(with: queue)
                }
            })
        }
        
        //HEVC file format only supports A10 Fusion Chip or higher.
        //to support HEVC, make sure to check if the device is iPhone 7 or higher
        videoOutputSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264 as AnyObject,
            AVVideoWidthKey: width as AnyObject,
            AVVideoHeightKey: height as AnyObject
        ]
        
        let attributes: [String: Bool] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSettings)

        videoInput.expectsMediaDataInRealTime = true
        pixelBufferInput = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: nil)
        
        var angleEnabled: Bool {
            for v in orientaions {
                if UIDevice.current.orientation.rawValue == v.rawValue {
                    return true
                }
            }
            return false
        }
        
        var recentAngle: CGFloat = 0
        var rotationAngle: CGFloat = 0
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            rotationAngle = -90
            recentAngle = -90
        case .landscapeRight:
            rotationAngle = 90
            recentAngle = 90
        case .faceUp, .faceDown, .portraitUpsideDown:
            rotationAngle = recentAngle
        default:
            rotationAngle = 0
            recentAngle = 0
        }
        
        if !angleEnabled {
            rotationAngle = 0
        }
        
        var t = CGAffineTransform.identity

        switch videoInputOrientation {
        case .auto:
            t = t.rotated(by: ((rotationAngle*CGFloat.pi) / 180))
        case .alwaysPortrait:
            t = t.rotated(by: 0)
        case .alwaysLandscape:
            if rotationAngle == 90 || rotationAngle == -90 {
                t = t.rotated(by: ((rotationAngle * CGFloat.pi) / 180))
            } else {
                t = t.rotated(by: ((-90 * CGFloat.pi) / 180))
            }
        }
        
        videoInput.transform = t
        
        if assetWriter.canAdd(videoInput) {
            assetWriter.add(videoInput)
        } else {
            delegate?.recorder(didFailRecording: assetWriter.error, and: "An error occurred while adding video input.")
            isWritingWithoutError = false
        }
        assetWriter.shouldOptimizeForNetworkUse = adjustForSharing
    }
    
    func prepareAudioDevice(with queue: DispatchQueue) {
        let device: AVCaptureDevice = AVCaptureDevice.default(for: .audio)!
        var audioDeviceInput: AVCaptureDeviceInput?
        do {
            audioDeviceInput = try AVCaptureDeviceInput(device: device)
        } catch {
            audioDeviceInput = nil
        }
        
        let audioDataOutput = AVCaptureAudioDataOutput()
        audioDataOutput.setSampleBufferDelegate(self, queue: queue)

        session = AVCaptureSession()
        session.sessionPreset = .medium
        session.usesApplicationAudioSession = true
        session.automaticallyConfiguresApplicationAudioSession = false
        
        if session.canAddInput(audioDeviceInput!) {
            session.addInput(audioDeviceInput!)
        }
        if session.canAddOutput(audioDataOutput) {
            session.addOutput(audioDataOutput)
        }
        

        audioSettings = audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .m4v) as? [String: Any]
        
        audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        audioInput.expectsMediaDataInRealTime = true
        
        audioBufferQueue.async {
            self.session.startRunning()
        }
        
        if assetWriter.canAdd(audioInput) {
            assetWriter.add(audioInput)
        }
    }
    
    var startingVideoTime: CMTime?
    var isWritingWithoutError: Bool?
    var currentDuration: TimeInterval = 0 // Seconds
    
    func insert(pixel buffer: CVPixelBuffer, with intervals: CFTimeInterval) {
        let time: CMTime = CMTime(seconds: intervals, preferredTimescale: 1000000)
        insert(pixel: buffer, with: time)
    }
    
    func insert(pixel buffer: CVPixelBuffer, with time: CMTime) {
        if assetWriter.status == .unknown {
            guard startingVideoTime == nil else {
                isWritingWithoutError = false
                return
            }
            startingVideoTime = time
            if assetWriter.startWriting() {
                assetWriter.startSession(atSourceTime: startingVideoTime!)
                currentDuration = 0
                isRecording = true
                isWritingWithoutError = true
            } else {
                delegate?.recorder(didFailRecording: assetWriter.error, and: "An error occurred while starting the video session.")
                currentDuration = 0
                isRecording = false
                isWritingWithoutError = false
            }
        } else if assetWriter.status == .failed {
            delegate?.recorder(didFailRecording: assetWriter.error, and: "Video session failed while recording.")
            logAR.message("An error occurred while recording the video, status: \(assetWriter.status.rawValue), error: \(assetWriter.error!.localizedDescription)")
            currentDuration = 0
            isRecording = false
            isWritingWithoutError = false
            return
        }
        
        if videoInput.isReadyForMoreMediaData {
            append(pixel: buffer, with: time)
            currentDuration = time.seconds - startingVideoTime!.seconds
            isRecording = true
            isWritingWithoutError = true
            delegate?.recorder?(didUpdateRecording: currentDuration)
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let input = audioInput {
            audioBufferQueue.async { [weak self] in
                if input.isReadyForMoreMediaData && (self?.isRecording)! {
                    input.append(sampleBuffer)
                }
            }
        }
    }
    
    func pause() {
        isRecording = false
    }
    
    func end(writing finished: @escaping () -> Void){
        if let session = session {
            if session.isRunning {
                session.stopRunning()
            }
        }
        
        if assetWriter.status == .writing {
            assetWriter.finishWriting(completionHandler: finished)
        }
    }
}

@available(iOS 11.0, *)
private extension WritAR {
    func append(pixel buffer: CVPixelBuffer, with time: CMTime) {
        pixelBufferInput.append(buffer, withPresentationTime: time)
    }
}

//Simple Logging to show logs only while debugging.
class logAR {
    class func message(_ message: String) {
        #if DEBUG
            print("ARVideoKit @ \(Date().timeIntervalSince1970):- \(message)")
        #endif
    }
    
    class func remove(from path: URL?) {
        if let file = path?.path {
            let manager = FileManager.default
            if manager.fileExists(atPath: file) {
                do{
                    try manager.removeItem(atPath: file)
                    self.message("Successfuly deleted media file from cached after exporting to Camera Roll.")
                } catch let error {
                    self.message("An error occurred while deleting cached media: \(error)")
                }
            }
        }
    }
}
