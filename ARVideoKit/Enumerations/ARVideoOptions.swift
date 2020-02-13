//
//  ARVideoOptions.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/18/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//
import Foundation

/// Allows specifying the final video orientation.
@objc public enum ARFrameMode: Int {
    case auto    
    case aspectFit
    /// Recommended for iPhone X
    case aspectFill
}

/// Allows specifying the video rendering frame per second `FPS` rate.
@objc public enum ARVideoFrameRate: Int {
    /// The framework automatically sets the most appropriate `FPS` based on the device support.
    case auto = 0
    /// Sets the `FPS` to 30 frames per second.
    case fps30 = 30
    /// Sets the `FPS` to 60 frames per second.
    case fps60 = 60
}

/// Allows specifying the final video orientation.
@objc public enum ARVideoOrientation: Int {
    /// The framework automatically sets the video orientation based on the active `ARInputViewOrientation` orientations.
    case auto
    /// Sets the video orientation to always portrait.
    case alwaysPortrait
    /// Sets the video orientation to always landscape.
    case alwaysLandscape
}

/// Allows specifying when to request Microphone access.
@objc public enum RecordARMicrophonePermission: Int {
    /// The framework automatically requests Microphone access when needed.
    case auto
    /// Allows manual permission request.
    case manual
}

/// An object that returns the AR recorder current status.
@objc public enum RecordARStatus: Int {
    /// The current status of the recorder is unknown.
    case unknown
    /// The current recorder is ready to record.
    case readyToRecord
    /// The current recorder is recording.
    case recording
    /// The current recorder is paused.
    case paused
}

/// An object that returns the current Microphone status.
@objc public enum RecordARMicrophoneStatus: Int {
    // The current status of the Microphone access is unknown.
    case unknown
    // The current status of the Microphone access is enabled.
    case enabled
    // The current status of the Microphone access is disabled.
    case disabled
}
