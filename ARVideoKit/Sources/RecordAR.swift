//
//  RecordAR.swift
//  ARVideoKit
//
//  Created by Ahmed Bekhit on 10/18/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import Metal
import ARKit
import Photos
import PhotosUI

private var view: Any?
private var renderEngine: SCNRenderer!
private var gpuLoop: CADisplayLink!
private var isResting = false
private var ARcontentMode: ARFrameMode!
@available(iOS 11.0, *)
private var renderer: RenderAR!
/**
 This class renders the `ARSCNView` or `ARSKView` content with the device's camera stream to generate a video 📹, photo 🌄, live photo 🎇 or GIF 🎆.

 - Author: 🤓 Ahmed Fathi Bekhit © 2017
 * [Github](http://github.com/AFathi)
 * [Website](http://ahmedbekhit.com)
 * [Twitter](http://twitter.com/iAFapps)
 * [Email](mailto:me@ahmedbekhit.com)
 */
@available(iOS 11.0, *)
@objc public class RecordAR: ARView {
    //MARK: - Public objects to configure RecordAR
    /**
     An object that passes the AR recorder errors and status in the protocol methods.
     */
    @objc public var delegate: RecordARDelegate?
    /**
     An object that passes the AR rendered content in the protocol method.
     */
    @objc public var renderAR: RenderARDelegate?
    /**
     An object that returns the AR recorder current status.
     */
    @objc public internal(set)var status: RecordARStatus = .unknown
    /**
     An object that returns the current Microphone status.
     */
    @objc public internal(set)var micStatus: RecordARMicrophoneStatus = .unknown
    /**
     An object that allow customizing when to ask for Microphone permission, if needed. Default is `.manual`.
     */
    @objc public var requestMicPermission: RecordARMicrophonePermission = .manual {
        didSet {
            switch self.requestMicPermission {
            case .auto:
                if self.enableAudio {
                    self.requestMicrophonePermission()
                }
            case .manual:
                break
            }
        }
    }
    /**
     An object that allow customizing the video frame per second rate. Default is `.auto`.
     */
    @objc public var fps: ARVideoFrameRate = .auto
    /**
     An object that allow customizing the video orientation. Default is `.auto`.
     */
    @objc public var videoOrientation: ARVideoOrientation = .auto
    /**
     An object that allow customizing the AR content mode. Default is `.auto`.
     */
    @objc public var contentMode: ARFrameMode = .auto
    /**
     A boolean that enables or disables AR content rendering before recording for image & video processing. Default is `true`.
     */
    @objc public var onlyRenderWhileRecording: Bool = true {
        didSet {
            self.onlyRenderWhileRec = self.onlyRenderWhileRecording
        }
    }
    /**
     A boolean that enables or disables audio recording. Default is `true`.
     */
    @objc public var enableAudio: Bool = true {
        didSet {
            self.requestMicPermission = (self.requestMicPermission == .manual) ? .manual: .auto
        }
    }
    /**
     A boolean that enables or disables audio `mixWithOthers` if audio recording is enabled. This allows playing music and recording audio at the same time. Default is `true`.
     */
    @objc public var enableMixWithOthers: Bool = true
    /**
     A boolean that enables or disables adjusting captured media for sharing online. Default is `true`.
     */
    @objc public var adjustVideoForSharing: Bool = true
    /**
     A boolean that enables or disables adjusting captured GIFs for sharing online. Default is `true`.
     */
    @objc public var adjustGIFForSharing: Bool = true
    /**
     A boolean that enables or disables clearing cached media after exporting to Camera Roll. Default is `true`.
     */
    @objc public var deleteCacheWhenExported: Bool = true
    /**
     A boolean that enables or disables using envronment light rendering. Default is `false`.
     */
    @objc public var enableAdjustEnvironmentLighting: Bool = false {
        didSet{
            if (renderEngine != nil) {
                renderEngine.autoenablesDefaultLighting = enableAdjustEnvironmentLighting
            }
        }
    }
    
    //MARK: - Public initialization methods
    /**
     Initialize 🌞🍳 `RecordAR` with an `ARSCNView` 🚀.
     */
    @objc override public init?(ARSceneKit: ARSCNView) {
        super.init(ARSceneKit: ARSceneKit)
        view = ARSceneKit
        setup()
    }
    
    /**
     Initialize 🌞🍳 `RecordAR` with an `ARSKView` 👾.
     */
    @objc override public init?(ARSpriteKit: ARSKView) {
        super.init(ARSpriteKit: ARSpriteKit)
        view = ARSpriteKit
        scnView = SCNView(frame: UIScreen.main.bounds)
        
        let bundle = Bundle(for: RecordAR.self)
        let url = bundle.url(forResource: "video.scnassets/vid", withExtension: "scn")
        
        do {
            let scene = try SCNScene(url: url!, options: nil)
            scnView.scene = scene
            setup()
        }catch let error {
            logAR.message("Error occurred while loading SK Video Assets : \(error). Please download \"video.scnassets\" from\nwww.ahmedbekhit.com/ARVideoKitAssets")
        }
    }
    
    /**
     Initialize 🌞🍳 `RecordAR` with an `SCNView` 🚀.
     */
    @objc override public init?(SceneKit: SCNView) {
        super.init(SceneKit: SceneKit)
        view = SceneKit
        setup()
    }
    
    //MARK: - threads
    let writerQueue = DispatchQueue(label:"com.ahmedbekhit.WriterQueue")
    let gifWriterQueue = DispatchQueue(label: "com.ahmedbekhit.GIFWriterQueue", attributes: .concurrent)
    let audioSessionQueue = DispatchQueue(label: "com.ahmedbekhit.AudioSessionQueue", attributes: .concurrent)
    
    //MARK: - Objects
    private var scnView: SCNView!
    private var fileCount = 0
    
    var parent: UIViewController? {
        if let view = view as? ARSCNView {
            return view.parent!
        } else if let view = view as? ARSKView {
            return view.parent!
        } else if let view = view as? SCNView {
            return view.parent!
        }
        return nil
    }
    
    //Used for gif capturing
    var gifImages:[UIImage] = []
    //Used for checking current recorder status
    var isCapturingPhoto = false
    var isRecordingGIF = false
    var isRecording = false
    var adjustPausedTime = false
    var backFromPause = false
    var recordingWithLimit = false
    var onlyRenderWhileRec = true
    //Used to modify video time when paused
    var pausedFrameTime: CMTime?
    var resumeFrameTime: CMTime?
    //Used to locate the path of the video recording
    var currentVideoPath: URL?
    //Used to locate the path of the audio recording
    var currentAudioPath: URL?
    //Used to initialize the video writer
    var writer: WritAR?
    //Used to generate a new video path
    var newVideoPath: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        formatter.dateFormat = "yyyy-MM-dd'@'HH-mm-ssZZZZ"

        let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        
        let vidPath = "\(documentsDirectory)/\(formatter.string(from: date))ARVideo.mp4"
        return URL(fileURLWithPath: vidPath, isDirectory: false)
    }
    
    //MARK: - Video Setup
    func setup() {
        if let view = view as? ARSCNView {
            guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
                logAR.message("ERROR:- This device does not support Metal")
                return
            }
            renderEngine = SCNRenderer(device: mtlDevice, options: nil)
            renderEngine.scene = view.scene
            
            gpuLoop = CADisplayLink(target: self, selector: #selector(renderFrame))
            gpuLoop.preferredFramesPerSecond = fps.rawValue
            gpuLoop.add(to: .main, forMode: .common)
            
            status = .readyToRecord
        } else if let view = view as? ARSKView {
            guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
                logAR.message("ERROR:- This device does not support Metal")
                return
            }
            let material = SCNMaterial()
            material.diffuse.contents = view.scene
            
            let plane = SCNPlane(width: view.bounds.width, height: view.bounds.height)
            let node = SCNNode(geometry: plane)
            node.geometry?.firstMaterial = material
            node.position = SCNVector3Make(0, 0, 0)
            
            scnView.scene?.rootNode.addChildNode(node)
            
            renderEngine = SCNRenderer(device: mtlDevice, options: nil)
            renderEngine.scene = scnView.scene
            
            gpuLoop = CADisplayLink(target: self, selector: #selector(renderFrame))
            gpuLoop.preferredFramesPerSecond = fps.rawValue
            gpuLoop.add(to: .main, forMode: .common)
            
            status = .readyToRecord
        } else if let view = view as? SCNView {
            guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
                logAR.message("ERROR:- This device does not support Metal")
                return
            }
            renderEngine = SCNRenderer(device: mtlDevice, options: nil)
            renderEngine.scene = view.scene
            
            gpuLoop = CADisplayLink(target: self, selector: #selector(renderFrame))
            gpuLoop.preferredFramesPerSecond = fps.rawValue
            gpuLoop.add(to: .main, forMode: .common)
            
            status = .readyToRecord
        }
        
        onlyRenderWhileRec = onlyRenderWhileRecording
        
        renderer = RenderAR(view, renderer: renderEngine, contentMode: contentMode)

        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    


    //MARK: - Public methods for capturing videos, photos, Live Photos, and GIFs

    /// A method that renders a photo 🌄 and returns it as `UIImage`.
    @objc public func photo() -> UIImage {
        if let buffer = renderer.buffer {
            return imageFromBuffer(buffer: buffer)
        }
        return UIImage()
    }
    /**
     A method that renders a `PHLivePhoto` 🎇 and returns `PHLivePhotoPlus` in the completion handler.
     
     In order to manually export the `PHLivePhotoPlus`, use `export(live photo: PHLivePhotoPlus)` method.
     - parameter export: A boolean that enables or disables automatically exporting the `PHLivePhotoPlus` when ready.
     - parameter finished: A block that will be called when Live Photo rendering is complete.
     
        The block returns the following parameters:
     
        `status`
        A boolean that returns `true` when a `PHLivePhotoPlus` is successfully rendered. Otherwise, it returns `false`.
     
        `livePhoto`
        A `PHLivePhotoPlus` object that contains a `PHLivePhoto` and other objects to allow manual exporting of a live photo.
     
        `permissionStatus`
        A `PHAuthorizationStatus` object that returns the current application's status for exporting media to the Photo Library. It returns `nil` if the `export` parameter is `false`.
     
        `exported`
        A boolean that returns `true` when a `PHLivePhotoPlus` is successfully exported to the Photo Library. Otherwise, it returns `false`.
     */
    @objc public func livePhoto(export: Bool, _ finished: ((_ status: Bool, _ livePhoto: PHLivePhotoPlus, _ permissionStatus: PHAuthorizationStatus, _ exported: Bool) -> Swift.Void)? = nil) {
        self.record(forDuration: 3.0) { path in
            let generator: LivePhotoGenerator? = LivePhotoGenerator()
            generator?.generate(livePhoto: path) { success, photo, frames, keyFrame in
                if success && export {
                    if self.fileCount == 0 {
                        self.fileCount += 1
                        self.export(live: photo!) { done, status in
                            finished?(true, photo!, status, done)
                        }
                    }
                } else {
                    finished?(success, photo!, PHAuthorizationStatus.notDetermined, false)
                }
            }
        }
    }
    /**
     A method that generates a GIF 🎆 image and returns its local path (`URL`) in the completion handler.
     
     In order to manually export the GIF image `URL`, use `func export(image path: URL)` method.
     - parameter duration: A `TimeInterval` object that can be set to the duration specified in seconds.
     - parameter export: A boolean that enables or disables automatically exporting the GIF image `URL` when ready.
     - parameter finished: A block that will be called when GIF image rendering is complete.

        The block returns the following parameters:
     
        `status`
        A boolean that returns `true` when a GIF image `URL` is successfully rendered. Otherwise, it returns `false`.
     
        `gifPath`
        A `URL` object that contains the local file path of the GIF image to allow manual exporting of a GIF.
     
        `permissionStatus`
        A `PHAuthorizationStatus` object that returns the current application's status for exporting media to the Photo Library. It returns `nil` if the `export` parameter is `false`.
     
        `exported`
        A boolean that returns `true` when a GIF image `URL` is successfully exported to the Photo Library. Otherwise, it returns `false`.
     */
    @objc public func gif(forDuration duration: TimeInterval, export: Bool, _ finished: ((_ status: Bool, _ gifPath: URL, _ permissionStatus: PHAuthorizationStatus, _ exported: Bool) -> Swift.Void)? = nil) {
        writerQueue.sync {
            self.isRecordingGIF = true
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.isRecordingGIF = false
                let generator: GIFGenerator? = GIFGenerator()
                generator?.generate(gif: self.gifImages, with: 0.1, loop: 0, adjust: self.adjustGIFForSharing) { ready, path in
                    // FIXME: `path` may be nil
                    if ready {
                        self.gifImages.removeAll()
                        if export {
                            self.export(image: path!) { done, status in
                                finished?(ready, path!, status, done)
                            }
                        } else {
                            finished?(ready, path!, .notDetermined, false)
                        }
                    } else {
                        self.gifImages.removeAll()
                        finished?(ready, path!, .notDetermined, false)
                    }
                }
            }
        }
    }
    ///A method that starts or resumes ⏯ recording a video 📹.
    @objc public func record() {
        writerQueue.sync {
            if self.enableAudio && micStatus == .unknown {
                self.requestMicrophonePermission { _ in
                    self.isRecording = true
                    self.status = .recording
                }
            } else {
                self.isRecording = true
                self.status = .recording
            }
        }
    }
    /**
     A method that starts recording a video 📹 with a specified duration ⏳ in seconds.
     
     In order to stop the recording before the specified duration, simply call `stop()` or `stopAndExport()` methods.
     
     - WARNING: You CAN NOT `pause()` video recording when a duration is specified.
     - parameter duration: A `TimeInterval` object that can be set to the duration specified in seconds.
     - parameter finished: A block that will be called when the specified `duration` has ended.
     
        The block returns the following parameter:
     
        `videoPath`
        A `URL` object that contains the local file path of the video to allow manual exporting or preview of the video.
     */
    @objc public func record(forDuration duration: TimeInterval, _ finished: ((_ videoPath: URL) -> Swift.Void)? = nil) {
        writerQueue.sync {
            if self.enableAudio && micStatus == .unknown {
                self.requestMicrophonePermission { _ in
                    self.recordingWithLimit = true
                    self.isRecording = true
                    self.status = .recording
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        self.stop { path in
                            finished?(path)
                        }
                    }
                }
            } else {
                self.recordingWithLimit = true
                self.isRecording = true
                self.status = .recording
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.stop { path in
                        finished?(path)
                    }
                }
            }

        }
    }
    /**
     A method that pauses recording a video ⏸📹.
     
     In order to resume recording, simply call the `record()` method.
     */
    @objc public func pause() {
        if !recordingWithLimit {
            onlyRenderWhileRec = false
            isRecording = false
            adjustPausedTime = true
        } else {
            logAR.message("NOT PERMITTED: The [ pause() ] method CAN NOT be used while using [ record(forDuration duration: TimeInterval) ]")
        }
    }
    /**
     A method that stops ⏹ recording a video 📹 and exports it to the Photo Library 📲💾.
     
     - parameter finished: A block that will be called when the export process is complete.
     
        The block returns the following parameters:
     
        `videoPath`
        A `URL` object that contains the local file path of the video to allow manual exporting or preview of the video.
     
        `permissionStatus`
        A `PHAuthorizationStatus` object that returns the current application's status for exporting media to the Photo Library.
     
        `exported`
        A boolean that returns `true` when a video is successfully exported to the Photo Library. Otherwise, it returns `false`.
     */
    @objc public func stopAndExport(_ finished: ((_ videoPath: URL, _ permissionStatus: PHAuthorizationStatus, _ exported: Bool) -> Swift.Void)? = nil) {
        writerQueue.sync {
            self.isRecording = false
            self.adjustPausedTime = false
            self.backFromPause = false
            self.recordingWithLimit = false
            
            self.pausedFrameTime = nil
            self.resumeFrameTime = nil
            
            self.writer?.end {
                if let path = self.currentVideoPath {
                    self.export(video: path) { exported, status in
                        finished?(path, status, exported)
                    }
                    self.delegate?.recorder(didEndRecording: path, with: true)
                    self.status = .readyToRecord
                } else {
                    finished?(self.currentVideoPath!, .notDetermined, false)
                    self.status = .readyToRecord
                    self.delegate?.recorder(didFailRecording: errSecDecode as? Error, and: "An error occured while stopping your video.")
                }
                self.writer = nil
            }
        }
    }
    /**
     A method that stops ⏹ recording a video 📹 and returns the video path in the completion handler.
     
     - parameter finished: A block that will be called when the specified `duration` has ended.
     
        The block returns the following parameter:
     
        `videoPath`
        A `URL` object that contains the local file path of the video to allow manual exporting or preview of the video.
     */
    @objc public func stop(_ finished:((_ videoPath: URL) -> Swift.Void)? = nil) {
        writerQueue.sync {
            isRecording = false
            adjustPausedTime = false
            backFromPause = false
            recordingWithLimit = false
            
            pausedFrameTime = nil
            resumeFrameTime = nil
            
            DispatchQueue.main.async {
                self.writer?.end {
                    if let path = self.currentVideoPath {
                        finished?(path)
                        self.delegate?.recorder(didEndRecording: path, with: true)
                        self.status = .readyToRecord
                    } else {
                        self.status = .readyToRecord
                        self.delegate?.recorder(didFailRecording: errSecDecode as? Error, and: "An error occured while stopping your video.")
                    }
                    self.writer = nil
                }
            }
        }
    }
    /**
     A method that exports a video 📹 file path to the Photo Library 📲💾.
     
     - parameter path: A `URL` object that can be set to a local video file path to export to the Photo Library.

     - parameter finished: A block that will be called when the export process is complete.
     
        The block returns the following parameters:
     
        `exported`
        A boolean that returns `true` when a video is successfully exported to the Photo Library. Otherwise, it returns `false`.
     
        `permissionStatus`
        A `PHAuthorizationStatus` object that returns the current application's status for exporting media to the Photo Library.
     */
    @objc public func export(video path: URL, _ finished: ((_ exported: Bool, _ permissionStatus: PHAuthorizationStatus) -> Void)? = nil) {
        audioSessionQueue.async {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization() { status in
                    // Recursive call after authorization request
                    self.export(video: path, finished)
                }
            } else if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: path)
                }) { saved, error in
                    if saved && self.deleteCacheWhenExported {
                        logAR.remove(from: path)
                    }
                    finished?(saved, status)
                }
            } else if status == .denied || status == .restricted {
                finished?(false, status)
            }
        }
    }
    /**
     A method that exports any image 🌄/🎆 (including gif, jpeg, and png) to the Photo Library 📲💾.
     
     - parameter path: A `URL` object that can be set to a local image file path to export to the Photo Library.
     - parameter UIImage: A `UIImage` object.
     - parameter finished: A block that will be called when the export process is complete.
     
        The block returns the following parameters:
     
        `exported`
        A boolean that returns `true` when an image is successfully exported to the Photo Library. Otherwise, it returns `false`.
     
        `permissionStatus`
        A `PHAuthorizationStatus` object that returns the current application's status for exporting media to the Photo Library.
     */
    @objc public func export(image path: URL? = nil, UIImage: UIImage? = nil, _ finished: ((_ exported: Bool, _ permissionStatus: PHAuthorizationStatus) -> Void)? = nil) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                // Recursive call after authorization request
                self.export(image: path, UIImage: UIImage, finished)
            }
        } else if status == .authorized {
            PHPhotoLibrary.shared().performChanges({
                if let path = path {
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: path)
                } else if let image = UIImage {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }
            }) { saved, error in
                if saved && self.deleteCacheWhenExported {
                    if let path = path {
                        logAR.remove(from: path)
                    }
                }
                finished?(saved, status)
            }
        } else if status == .denied || status == .restricted {
            finished?(false, status)
        }
    }
    /**
     A method that exports a `PHLivePhotoPlus` 🎇 object to the Photo Library 📲💾.
     
     - parameter photo: A `PHLivePhotoPlus` object that can be set to the returned `PHLivePhotoPlus` object in the `livePhoto(export: Bool, _ finished:{})` method.
     
     - parameter finished: A block that will be called when the export process is complete.
     
     The block returns the following parameters:
     
     `exported`
     A boolean that returns `true` when the Live Photo is successfully exported to the Photo Library. Otherwise, it returns `false`.
     
     `permissionStatus`
     A `PHAuthorizationStatus` object that returns the current application's status for exporting media to the Photo Library.
     */
    @objc public func export(live photo: PHLivePhotoPlus, _ finished: ((_ exported: Bool, _ permissionStatus: PHAuthorizationStatus) -> Void)? = nil) {
        guard let keyPhotoPath = photo.keyPhotoPath else {
            logAR.message("An error occurred while exporting a live photo")
            return
        }
        guard let videoPath = photo.pairedVideoPath else {
            logAR.message("An error occurred while exporting a live photo")
            return
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                // Recursive call after authorization request
                self.export(live: photo, finished)
            }
        } else if status == .authorized {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                request.addResource(with: .photo, fileURL: keyPhotoPath, options: options)
                request.addResource(with: .pairedVideo, fileURL: videoPath, options: options)
            }) { saved, error  in
                if saved {
                    if self.deleteCacheWhenExported {
                        logAR.remove(from: keyPhotoPath)
                        logAR.remove(from: videoPath)
                    }
                    self.fileCount = 0
                } else {
                    logAR.message("An error occurred while exporting a live photo: \(error!)")
                }
                finished?(saved, status)
            }
        } else if status == .denied || status == .restricted {
            finished?(false, status)
        }
    }
    
    /**
     A method that requsts microphone 🎙 permission manually, if micPermission is set to `manual`.
     - parameter finished: A block that will be called when the audio permission is requested.
     
     The block returns the following parameter:
     
     `status`
     A boolean that returns `true` when a the Microphone access is permitted. Otherwise, it returns `false`.
     */
    @objc public func requestMicrophonePermission(_ finished: ((_ status: Bool) -> Swift.Void)? = nil) {
        AVAudioSession.sharedInstance().requestRecordPermission({ permitted in
            finished?(permitted)
            if permitted {
                self.micStatus = .enabled
            } else {
                self.micStatus = .disabled
            }
        })
    }
}

//MARK: - Public methods for setting up UIViewController orientations
@available(iOS 11.0, *)
@objc public extension RecordAR {
    /**
     A method that prepares the video recorder with `ARConfiguration` 📝.
     
     Recommended to use in the `UIViewController`'s method `func viewWillAppear(_ animated: Bool)`
     - parameter configuration: An object that defines motion and scene tracking behaviors for the session.
    */
    @objc func prepare(_ configuration: ARConfiguration? = nil) {
        ARcontentMode = contentMode
        onlyRenderWhileRec = onlyRenderWhileRecording
        if let view = view as? ARSCNView {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            ViewAR.orientation = .portrait
            
            //try resetting anchors for the initial landscape orientation issue.
            guard let config = configuration else { return }
            view.session.run(config)
        } else if let view = view as? ARSKView {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            ViewAR.orientation = .portrait
            guard let config = configuration else { return }
            view.session.run(config)
        } else if let _ = view as? SCNView {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            ViewAR.orientation = .portrait
        }
    }
    /**
     A method that switches off the orientation lock used in a `UIViewController` with AR scenes 📐😴.
     
     Recommended to use in the `UIViewController`'s method `func viewWillDisappear(_ animated: Bool)`.
    */
    @objc func rest() {
        ViewAR.orientation = UIInterfaceOrientationMask(ViewAR.orientations)
    }
}

//MARK: - AR Video Frames Rendering
@available(iOS 11.0, *)
extension RecordAR {
    @objc func renderFrame() {
        //frame rendering
        if self.onlyRenderWhileRec && !isRecording && !isRecordingGIF { return }

        guard let buffer = renderer.buffer else { return }
        guard let rawBuffer = renderer.rawBuffer else {
            logAR.message("ERROR:- An error occurred while rendering the camera's main buffers.")
            return
        }
        guard let size = renderer.bufferSize else {
            logAR.message("ERROR:- An error occurred while rendering the camera buffer.")
            return
        }
        renderer.ARcontentMode = contentMode

        self.writerQueue.sync {
            
            var time: CMTime { return CMTime(seconds: renderer.time, preferredTimescale: 1000000) }
            
            self.renderAR?.frame(didRender: buffer, with: time, using: rawBuffer)

            //gif images writing
            if self.isRecordingGIF {
                self.gifWriterQueue.sync {
                    self.gifImages.append(self.imageFromBuffer(buffer: buffer))
                }
            }
            
            //frame writing
            if self.isRecording {
                if let frameWriter = self.writer {
                    var finalFrameTime: CMTime?
                    if self.backFromPause {
                        if self.resumeFrameTime == nil {
                            self.resumeFrameTime = time
                        }
                        //Formula: (currentTime - (timeWhenResume - timeWhenPaused))
                        guard let resumeTime = self.resumeFrameTime,
                            let pausedTime = self.pausedFrameTime else { return }
                        finalFrameTime = self.adjustTime(current: time, resume: resumeTime, pause: pausedTime)
                    } else {
                        finalFrameTime = time
                    }
                    
                    frameWriter.insert(pixel: buffer, with: finalFrameTime!)
                    
                    guard let isWriting = frameWriter.isWritingWithoutError else { return }
                    if !isWriting {
                        self.isRecording = false
                        
                        self.status = .readyToRecord
                        self.delegate?.recorder(didFailRecording: errSecDecode as? Error, and: "An error occured while recording your video.")
                        self.delegate?.recorder(didEndRecording: self.currentVideoPath!, with: false)
                    }
                } else {
                    self.currentVideoPath = self.newVideoPath
                    
                    self.writer = WritAR(output: self.currentVideoPath!, width: Int(size.width), height: Int(size.height), adjustForSharing: self.adjustVideoForSharing, audioEnabled: self.enableAudio, orientaions: self.inputViewOrientations, queue: self.writerQueue, allowMix: self.enableMixWithOthers)
                    self.writer?.videoInputOrientation = self.videoOrientation
                    self.writer?.delegate = self.delegate
                }
            } else if !self.isRecording && self.adjustPausedTime {
                writer?.pause()

                self.adjustPausedTime = false
                
                if self.pausedFrameTime != nil {
                    self.pausedFrameTime = self.adjustTime(current: time, resume: self.resumeFrameTime!, pause: self.pausedFrameTime!)
                } else {
                    self.pausedFrameTime = time
                }
                
                self.backFromPause = true
                self.resumeFrameTime = nil
                
                self.status = .paused
                self.onlyRenderWhileRec = onlyRenderWhileRecording
            }
        }
    }
}
