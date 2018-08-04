//
//  RenderARDelegate.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/21/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import Foundation
import CoreVideo
import CoreMedia
import ARKit

/**
 The renderer protocol.
 
 - Author: Ahmed Fathi Bekhit
 * [Github](http://github.com/AFathi)
 * [Website](http://ahmedbekhit.com)
 * [Twitter](http://twitter.com/iAFapps)
 * [Email](mailto:me@ahmedbekhit.com)
 */
@available(iOS 11.0, *)
@objc public protocol RenderARDelegate {
    /**
     A protocol method that is triggered when a frame renders the `ARSCNView` or `ARSKView` content with the device's camera stream.
     - parameter buffer: A `CVPixelBuffer` object that returns the rendered buffer.
     - parameter time: A `CMTime` object that returns the time a buffer was rendered with.
     - parameter rawBuffer: A `CVPixelBuffer` object that returns the raw buffer.
     */
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer)
}
