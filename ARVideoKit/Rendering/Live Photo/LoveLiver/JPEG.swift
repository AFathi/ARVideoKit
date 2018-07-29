//
//  JPEG.swift
//  LoveLiver
//
//  Created by mzp on 10/10/15.
//  Copyright © 2015 mzp. All rights reserved.
//

import Foundation
import MobileCoreServices
import ImageIO

class JPEG {
    private let kFigAppleMakerNote_AssetIdentifier = "17"
    private let path: String

    init(path: String) {
        self.path = path
    }

    func read() -> String? {
        guard let makerNote = metadata()?.object(forKey: kCGImagePropertyMakerAppleDictionary) as? NSDictionary? else {
            return nil
        }
        return makerNote?.object(forKey: kFigAppleMakerNote_AssetIdentifier) as? String
    }

    func write(_ dest: String, assetIdentifier: String) {
        guard let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: dest) as CFURL, kUTTypeJPEG, 1, nil)
            else { return }
        defer { CGImageDestinationFinalize(dest) }
        guard let imageSource = self.imageSource() else { return }
        guard let metadata = self.metadata()?.mutableCopy() as? NSMutableDictionary else { return }

        let makerNote = NSMutableDictionary()
        makerNote.setObject(assetIdentifier, forKey: kFigAppleMakerNote_AssetIdentifier as NSCopying)
        metadata.setObject(makerNote, forKey: kCGImagePropertyMakerAppleDictionary as String as String as NSCopying)
        CGImageDestinationAddImageFromSource(dest, imageSource, 0, metadata)
    }

    private func metadata() -> NSDictionary? {
        return self.imageSource().flatMap {
            CGImageSourceCopyPropertiesAtIndex($0, 0, nil) as NSDictionary?
        }
    }

    private func imageSource() ->  CGImageSource? {
        return self.data().flatMap {
            CGImageSourceCreateWithData($0 as CFData, nil)
        }
    }

    private func data() -> Data? {
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
}
