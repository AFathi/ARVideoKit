//
//  prepare.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/16/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import ARKit
/**
 A struct that identifies the application `UIViewController`s and their orientations.

 - Author: Ahmed Fathi Bekhit
 * [Github](http://github.com/AFathi)
 * [Website](http://ahmedbekhit.com)
 * [Twitter](http://twitter.com/iAFapps)
 * [Email](mailto:me@ahmedbekhit.com)
 */
@available(iOS 11.0, *)
@objc public class ViewAR: NSObject {
    /**
     A `UIInterfaceOrientationMask` object that returns the recommended orientations for a `UIViewController` with AR scenes.
     
     Recommended to return in the application delegate method `func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask`.
    */
    @objc internal(set) public static var orientation: UIInterfaceOrientationMask {
        get { return mask }
        set { mask = newValue }
    }
    
    static var orientations: [UIInterfaceOrientationMask] {
        var all:[UIInterfaceOrientationMask] = []
        if let info = Bundle.main.infoDictionary {
            if let supportedOrientaions = info["UISupportedInterfaceOrientations"] as? NSArray {
                for orientation in supportedOrientaions {
                    if let o = orientation as? String {
                        if o == "UIInterfaceOrientationPortrait" {
                            all.append(.portrait)
                        } else if o == "UIInterfaceOrientationPortraitUpsideDown" {
                            all.append(.portraitUpsideDown)
                        } else if o == "UIInterfaceOrientationLandscapeLeft" {
                            all.append(.landscapeLeft)
                        } else if o == "UIInterfaceOrientationLandscapeRight" {
                            all.append(.landscapeRight)
                        }
                    }
                }
                return all
            }
        }
        return all
    }
    //returns the application's delegate to check if the current UIViewController contains an ARView
    private static var delegate = UIApplication.shared.delegate
    //variable for the setter in `mask`
    private static var m: UIInterfaceOrientationMask = .portrait
    //returns the most appropriate orientation based on the content of the UIViewController.
    private static var mask: UIInterfaceOrientationMask {
        get {
            if let vc = delegate?.window??.inputViewController {
                if vc.hasARView {
                    return .portrait
                } else {
                    return UIInterfaceOrientationMask(orientations)
                }
            }
            return m
        }
        set { m = newValue }
    }
}
