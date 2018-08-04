//
//  RenderAR.swift
//  ARVideoKit
//
//  Created by Ahmed Bekhit on 1/7/18.
//  Copyright © 2018 Ahmed Fathit Bekhit. All rights reserved.
//

import Foundation
import ARKit

private var view: Any?
private var renderEngine: SCNRenderer!

@available(iOS 11.0, *)
struct RenderAR {
    var ARcontentMode: ARFrameMode!
    
    init(_ ARview: Any?, renderer: SCNRenderer, contentMode: ARFrameMode) {
        view = ARview
        renderEngine = renderer
        ARcontentMode = contentMode
    }
    
    let pixelsQueue = DispatchQueue(label: "com.ahmedbekhit.PixelsQueue", attributes: .concurrent)
    var time: CFTimeInterval { return CACurrentMediaTime()}
    var rawBuffer: CVPixelBuffer? {
        if let view = view as? ARSCNView {
            guard let rawBuffer = view.session.currentFrame?.capturedImage else { return nil }
            return rawBuffer
        } else if let view = view as? ARSKView {
            guard let rawBuffer = view.session.currentFrame?.capturedImage else { return nil }
            return rawBuffer
        } else if view is SCNView {
            return buffer
        }
        return nil
    }
    
    var bufferSize: CGSize? {
        guard let raw = rawBuffer else { return nil }
        var width = CVPixelBufferGetWidth(raw)
        var height = CVPixelBufferGetHeight(raw)
        
        if let contentMode = ARcontentMode {
            switch contentMode {
            case .auto:
                if UIScreen.main.isiPhone10 {
                    width = Int(UIScreen.main.nativeBounds.width)
                    height = Int(UIScreen.main.nativeBounds.height)
                }
            case .aspectFit:
                width = CVPixelBufferGetWidth(raw)
                height = CVPixelBufferGetHeight(raw)
            case .aspectFill:
                width = Int(UIScreen.main.nativeBounds.width)
                height = Int(UIScreen.main.nativeBounds.height)
            default:
                if UIScreen.main.isiPhone10 {
                    width = Int(UIScreen.main.nativeBounds.width)
                    height = Int(UIScreen.main.nativeBounds.height)
                }
            }
        }
        
        if width > height {
            return CGSize(width: height, height: width)
        } else {
            return CGSize(width: width, height: height)
        }
    }
    
    var bufferSizeFill: CGSize? {
        guard let raw = rawBuffer else { return nil }
        let width = CVPixelBufferGetWidth(raw)
        let height = CVPixelBufferGetHeight(raw)
        if width > height {
            return CGSize(width: height, height: width)
        } else {
            return CGSize(width: width, height: height)
        }
    }
    
    var buffer: CVPixelBuffer? {
        if view is ARSCNView {
            guard let size = bufferSize else { return nil }
            //UIScreen.main.bounds.size
            var renderedFrame: UIImage?
            pixelsQueue.sync {
                renderedFrame = renderEngine.snapshot(atTime: self.time, with: size, antialiasingMode: .none)
            }
            if let _ = renderedFrame {
            } else {
                renderedFrame = renderEngine.snapshot(atTime: time, with: size, antialiasingMode: .none)
            }
            guard let buffer = renderedFrame!.buffer else { return nil }
            return buffer
        } else if view is ARSKView {
            guard let size = bufferSize else { return nil }
            var renderedFrame: UIImage?
            pixelsQueue.sync {
                renderedFrame = renderEngine.snapshot(atTime: self.time, with: size, antialiasingMode: .none).rotate(by: 180)
            }
            if renderedFrame == nil {
                renderedFrame = renderEngine.snapshot(atTime: time, with: size, antialiasingMode: .none).rotate(by: 180)
            }
            guard let buffer = renderedFrame!.buffer else { return nil }
            return buffer;
        } else if view is SCNView {
            let size = UIScreen.main.bounds.size
            var renderedFrame: UIImage?
            pixelsQueue.sync {
                renderedFrame = renderEngine.snapshot(atTime: self.time, with: size, antialiasingMode: .none)
            }
            if let _ = renderedFrame {
            } else {
                renderedFrame = renderEngine.snapshot(atTime: time, with: size, antialiasingMode: .none)
            }
            guard let buffer = renderedFrame!.buffer else { return nil }
            return buffer
        }
        return nil
    }
}
