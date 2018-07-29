//
//  CGImage+Resize.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/27/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import CoreGraphics

extension CGImage {
    func resize(with ratio: Float) -> CGImage? {
        let imageWidth: Int = Int(Float(self.width) * ratio)
        let imageHeight: Int = Int(Float(self.height) * ratio)
        
        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: self.bitsPerComponent, bytesPerRow: self.bytesPerRow, space: colorSpace, bitmapInfo: self.alphaInfo.rawValue) else { return nil }
        
        context.interpolationQuality = .low
        context.draw(self, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        return context.makeImage()
    }
}
