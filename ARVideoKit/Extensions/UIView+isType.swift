//
//  UIView+isType.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/18/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import ARKit

@available(iOS 11.0, *)
extension UIScreen {
    /**
     `isiPhone10` is a boolean that returns if the device is iPhone X or not.
     */
    var isNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
@available(iOS 11.0, *)
extension UIView {
    var parent: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder!.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    var isButton: Bool {
        return (self is UIButton)
    }
    
    var isARView: Bool {
        return (self is ARSCNView) || (self is ARSKView)
    }
}
