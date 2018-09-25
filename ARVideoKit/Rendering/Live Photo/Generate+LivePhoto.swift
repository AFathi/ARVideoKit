//
//  Generate+LivePhoto.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/28/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import AVFoundation
import Photos

@available(iOS 11.0, *)
class LivePhotoGenerator {
    private var keyPhotoPath: URL?

    private var finalKeyPhotoPath: URL?
    private var finalPairedVideoPath: URL?
    
    let livePhotoQueue = DispatchQueue(label:"com.ahmedbekhit.livePhotoQueue", attributes: .concurrent)
    
    func generate(livePhoto video: URL?, _ finished: ((_ status: Bool, _ photo: PHLivePhotoPlus?, _ pairedVideoPath: URL?, _ keyFramePath: URL?) -> Void)? = nil) {
        livePhotoQueue.async {
            guard let liveFrames = video else { finished?(false, nil, nil, nil); return }
            let asset = AVURLAsset(url: video!)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            //retrieves the key photo frame from the middle of the video asset
            let time = NSValue(time: CMTimeMultiplyByFloat64(asset.duration, multiplier: 0.5))

            //generates the key photo CGImage asynchronously
            generator.generateCGImagesAsynchronously(forTimes: [time], completionHandler: { _, image, _, _, _ in
                if let cgImg = image, let imgData = UIImage(cgImage: cgImg).pngData() {
                    do {
                        self.keyPhotoPath = self.newPath(for: true, and: false)
                        try imgData.write(to: self.keyPhotoPath!, options: [.atomic])
                    } catch let error {
                        self.keyPhotoPath = nil
                        logAR.message("An error occurred while capturing a live photo: \(error)")
                        finished?(false, nil, nil, nil)
                        return
                    }
                    self.finalKeyPhotoPath = self.newPath(for: true, and: true)
                    self.finalPairedVideoPath = self.newPath(for: false, and: true)
                    
                    guard let keyFrame = self.keyPhotoPath else { finished?(false, nil, nil, nil); return }
                    guard let keyLiveFrame = self.finalKeyPhotoPath else { finished?(false, nil, nil, nil); return }
                    guard let keyLiveFrames = self.finalPairedVideoPath else { finished?(false, nil, nil, nil); return }

                    let assetIdentifier = UUID().uuidString
           
                    JPEG(path: keyFrame.path).write(keyLiveFrame.path, assetIdentifier: assetIdentifier)
                    QuickTimeMov(path: liveFrames.path).write(keyLiveFrames.path, assetIdentifier: assetIdentifier)
                    

                    PHLivePhoto.request(withResourceFileURLs: [keyLiveFrames, keyLiveFrame], placeholderImage: UIImage(cgImage: cgImg), targetSize: .zero, contentMode: .aspectFit) { photo, settings in
                        logAR.remove(from: keyFrame)
                        logAR.remove(from: liveFrames)
                        if let livePhoto = photo {
                            let finalPhoto = PHLivePhotoPlus(photo: livePhoto)
                            finalPhoto.keyPhotoPath = keyLiveFrame
                            finalPhoto.pairedVideoPath = keyLiveFrames
                            finished?(true, finalPhoto, finalPhoto.pairedVideoPath, finalPhoto.keyPhotoPath)
                            return
                        } else {
                            let finalPhoto = PHLivePhotoPlus(photo: photo!)
                            finalPhoto.keyPhotoPath = keyLiveFrame
                            finalPhoto.pairedVideoPath = keyLiveFrames
                            finished?(false, finalPhoto, finalPhoto.pairedVideoPath, finalPhoto.keyPhotoPath)
                            return
                        }
                    }
                }
            })
        }
    }
    
    func newPath(for JPEG: Bool, and live: Bool) -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        let livePhotosFolder = "\(documentsDirectory)/livePhotos"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        formatter.dateFormat = "yyyy-MM-dd'@'HH-mm-ssZZZZ"
        
        let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        
        do {
            try FileManager.default.createDirectory(atPath: livePhotosFolder, withIntermediateDirectories: true, attributes: nil)
        }catch let error {
            logAR.message("An error occurred while rendering the live photo: \(error)")
            return URL(fileURLWithPath: "\(documentsDirectory)/\(formatter.string(from: date))AR.jpg", isDirectory: false)
        }
        
        if JPEG && live {
            return URL(fileURLWithPath: "\(livePhotosFolder)/\(formatter.string(from: date))AR.jpg", isDirectory: false)
        } else if JPEG && !live {
            return URL(fileURLWithPath: "\(documentsDirectory)/\(formatter.string(from: date))AR.jpg", isDirectory: false)
        } else {
            return URL(fileURLWithPath: "\(livePhotosFolder)/\(formatter.string(from: date))AR.mov", isDirectory: false)
        }
    }
}
