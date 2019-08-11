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
internal extension UIViewController {
    var hasARView : Bool {
        let views = self.view.subviews
        for v in views {
            if let _ = v as? ARSCNView {
                return true
            } else if let _ = v as? ARSKView {
                return true
            } else {
                return false
            }
        }
        return false
    }
}
