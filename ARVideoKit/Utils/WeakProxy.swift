//
//  SSSS.swift
//  ARVideoKit
//
//  Created by Saul Moreno Abril on 01/05/2019.
//  Copyright © 2019 Ahmed Fathit Bekhit. All rights reserved.
//

import Foundation

class WeakProxy: NSObject {
    weak var target: NSObjectProtocol?

    init(target: NSObjectProtocol) {
        self.target = target
        super.init()
    }

    override func responds(to aSelector: Selector!) -> Bool {
        return (target?.responds(to: aSelector) ?? false) || super.responds(to: aSelector)
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}
