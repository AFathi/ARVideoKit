//
//  Generate+GIF.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/27/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import MobileCoreServices

class GIFGenerator {
    let gifQueue = DispatchQueue(label:"com.ahmedbekhit.GIFQueue", attributes: .concurrent)
    private var currentGIFPath: URL?
    private var newGIFPath: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        formatter.dateFormat = "yyyy-MM-dd'@'HH-mm-ssZZZZ"
        
        let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        
        let gifPath = "\(documentsDirectory)/\(formatter.string(from: date))AR.gif"
        return URL(fileURLWithPath: gifPath, isDirectory: false)
    }
    
    func generate(gif images:[UIImage], with delay: Float, loop count: Int = 0, adjust: Bool, _ finished: ((_ status: Bool, _ path: URL?) -> Void)? = nil) {
        currentGIFPath = newGIFPath
        gifQueue.async {
            let gifSettings = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: count]]
            let imageSettings = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: delay]]
            
            guard let path = self.currentGIFPath else { return }
            guard let destination = CGImageDestinationCreateWithURL(path as CFURL, kUTTypeGIF, images.count, nil) else {
                finished?(false, nil)
                return
            }
            logAR.message("\(destination)")
            CGImageDestinationSetProperties(destination, gifSettings as CFDictionary)
            for image in images {
                if let imageRef = image.cgImage {
                    var ratio: Float = 0.0
                    if adjust { ratio = 0.5 } else { ratio = 1.0 }
                    CGImageDestinationAddImage(destination, imageRef.resize(with: ratio)!, imageSettings as CFDictionary)
                }
            }
            
            if !CGImageDestinationFinalize(destination){
                finished?(false, nil)
                return
            } else {
                finished?(true, path)
            }
        }
    }
}
