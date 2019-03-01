//
//  RecordARDelegate.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/18/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import Foundation
import CoreVideo
import CoreMedia
import ARKit

/**
 The recorder protocol.
 
 - Author: Ahmed Fathi Bekhit
 * [Github](http://github.com/AFathi)
 * [Website](http://ahmedbekhit.com)
 * [Twitter](http://twitter.com/iAFapps)
 * [Email](mailto:me@ahmedbekhit.com)
 */
@available(iOS 11.0, *)
@objc public protocol RecordARDelegate {
    /**
     A protocol method that is triggered when a recorder ends recording.
     - parameter path: A `URL` object that returns the video file path.
     - parameter noError: A boolean that returns true when the recorder ends without errors. Otherwise, it returns false.
     */
    func recorder(didEndRecording path: URL, with noError: Bool)
    
    /**
     A protocol method that is triggered when a recorder fails recording.
     - parameter error: An `Error` object that returns the error value.
     - parameter status: A string that returns the reason of the recorder failure in a string literal format.
     */
    func recorder(didFailRecording error: Error?, and status: String)
    
    /**
     A protocol method that is triggered when a recorder is modified.
     - parameter duration: A double that returns the duration of current recording
     */
    @objc optional func recorder(didUpdateRecording duration: TimeInterval)

    /**
     A protocol method that is triggered when the application will resign active.
     - parameter status: A `RecordARStatus` object that returns the AR recorder current status.
     
     
     - NOTE: Check [applicationWillResignActive(_:)](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622950-applicationwillresignactive) for more information.
     */
    @objc func recorder(willEnterBackground status: RecordARStatus)
}
