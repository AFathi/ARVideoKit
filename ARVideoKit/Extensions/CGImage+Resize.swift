//
//  CGImage+Resize.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/27/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import CoreGraphics

internal extension CGImage {
    internal func resize(with ratio:Float) -> CGImage? {
        let imageWidth = Float(self.width)
        let imageHeight = Float(self.height)
        
        let width = imageWidth * ratio
        let height = imageHeight * ratio
        
        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: self.bitsPerComponent, bytesPerRow: self.bytesPerRow, space: colorSpace, bitmapInfo: self.alphaInfo.rawValue) else { return nil }
        
        context.interpolationQuality = .low
        context.draw(self, in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))
        
        return context.makeImage()
    }
}
