//
//  RecordAR+PhotoRender.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/27/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import AVFoundation
import Photos

@available(iOS 11.0, *)
extension RecordAR {
    
    func adjustTime(current: CMTime, resume: CMTime, pause: CMTime) -> CMTime {
        return CMTimeSubtract(current, CMTimeSubtract(resume, pause))
    }
    
    func imageFromBuffer(buffer: CVPixelBuffer) -> UIImage {
        let coreImg = CIImage(cvPixelBuffer: buffer)
        let context = CIContext()
        let cgImg = context.createCGImage(coreImg, from: coreImg.extent)
        
        var angleEnabled: Bool {
            for v in inputViewOrientations {
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
        
        switch videoOrientation {
        case .alwaysPortrait:
            rotationAngle = 0
        case .alwaysLandscape:
            if rotationAngle != 90 || rotationAngle != -90 {
                rotationAngle = -90
            }
        default:
            break
        }
        
        return UIImage(cgImage: cgImg!).rotate(by: rotationAngle, flip: false)
    }
    
    @objc func appWillEnterBackground() {
        delegate?.recorder(willEnterBackground: status)
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
}
