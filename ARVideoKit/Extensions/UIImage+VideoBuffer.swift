//
//  UIImage+VideoBuffer.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/18/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import CoreVideo
import UIKit

extension UIImage
{
    func rotate(by degrees: CGFloat, flip: Bool? = nil) -> UIImage
    {
        let radians = CGFloat(degrees * (CGFloat.pi / 180.0))
        
        let bufferView = UIView(frame: CGRect(origin: CGPoint.zero, size: self.size))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: radians)
        bufferView.transform = t
        let bufferSize = bufferView.frame.size
        
        UIGraphicsBeginImageContextWithOptions(bufferSize, false, self.scale)
        let bitmap = UIGraphicsGetCurrentContext()
        bitmap?.translateBy(x: bufferSize.width / 2, y: bufferSize.height / 2)
        bitmap?.rotate(by: radians)
        if let isFlipped = flip {
            if !isFlipped {
                bitmap?.scaleBy(x: 1.0, y: -1.0)
            } else {
                bitmap?.scaleBy(x: -1.0, y: -1.0)
            }
        } else {
            bitmap?.scaleBy(x: -1.0, y: -1.0)
        }
        bitmap?.draw(self.cgImage!, in: CGRect(origin: CGPoint(x: -self.size.width / 2, y: -self.size.height / 2), size: self.size))
        
        let finalBuffer = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalBuffer!
    }
    
    var buffer: CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
