//
//  UIViewController+hasType.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/18/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import ARKit

@available(iOS 11.0, *)
extension UIViewController {
    var hasARView: Bool {
        let views = self.view.subviews
        for v in views {
            if v is ARSCNView || v is ARSKView {
                return true
            }
        }
        return false
    }
}
