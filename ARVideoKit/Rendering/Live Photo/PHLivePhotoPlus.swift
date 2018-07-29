//
//  PHLivePhotoPlus.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/30/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import Photos

/**
 A `PHLivePhotoPlus` object is a `PHLivePhoto` sub-class that contains objects to allow manual exporting of a live photo.
 
 - Author: Ahmed Fathi Bekhit
 * [Github](http://github.com/AFathi)
 * [Website](http://ahmedbekhit.com)
 * [Twitter](http://twitter.com/iAFapps)
 * [Email](mailto:me@ahmedbekhit.com)
 */
@available(iOS 9.1, *)
@objc public class PHLivePhotoPlus: PHLivePhoto {
    var pairedVideoPath: URL?
    var keyPhotoPath: URL?
    
    /// A `PHLivePhoto` object that returns the Live Photo content from `PHLivePhotoPlus`.
    @objc public var livePhoto: PHLivePhoto?
    
    @objc public override init() {
        super.init()
    }
    
    @objc public init(photo: PHLivePhoto) {
        super.init()
        livePhoto = photo
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
