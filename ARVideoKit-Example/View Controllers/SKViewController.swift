//
//  SKViewController.swift
//  ARVideoKit-Example
//
//  Created by Ahmed Bekhit on 11/2/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import ARKit
import ARVideoKit
import Photos

class SKViewController: UIViewController, ARSKViewDelegate, RenderARDelegate, RecordARDelegate  {
    
    @IBOutlet var SKSceneView: ARSKView!
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var pauseBtn: UIButton!
    
    var recorder:RecordAR?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        SKSceneView.delegate = self
        
        // Show statistics such as fps and node count
        SKSceneView.showsFPS = true
        SKSceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            SKSceneView.presentScene(scene)
        }
        
        // Initialize ARVideoKit recorder
        recorder = RecordAR(ARSpriteKit: SKSceneView)
        
        /*----👇---- ARVideoKit Configuration ----👇----*/
        
        // Set the recorder's delegate
        recorder?.delegate = self
        
        // Set the renderer's delegate
        recorder?.renderAR = self
        
        // Set the UIViewController orientations
        recorder?.inputViewOrientations = [.landscapeLeft, .landscapeRight, .portrait]
        
        // Configure RecordAR to store media files in local app directory
        recorder?.deleteCacheWhenExported = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        SKSceneView.session.run(configuration)
        
        // Prepare the recorder with sessions configuration
        recorder?.prepare(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        SKSceneView.session.pause()
        
        // Switch off the orientation lock for UIViewControllers with AR Scenes
        recorder?.rest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Hide Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Exported UIAlert present method
    func exportMessage(success: Bool, status:PHAuthorizationStatus) {
        if success {
            let alert = UIAlertController(title: "Exported", message: "Media exported to camera roll successfully!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if status == .denied || status == .restricted || status == .notDetermined {
            let errorView = UIAlertController(title: "😅", message: "Please allow access to the photo library in order to save this media file.", preferredStyle: .alert)
            let settingsBtn = UIAlertAction(title: "Open Settings", style: .cancel) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    } else {
                        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                    }
                }
            }
            errorView.addAction(UIAlertAction(title: "Later", style: UIAlertActionStyle.default, handler: {
                (UIAlertAction)in
            }))
            errorView.addAction(settingsBtn)
            self.present(errorView, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Exporting Failed", message: "There was an error while exporting your media file.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - Button Action Methods
extension SKViewController {
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func capture(_ sender: UIButton) {
        if sender.tag == 0 {
            //Photo
            if recorder?.status == .readyToRecord {
                let image = recorder?.photo()
                recorder?.export(UIImage: image) { saved, status in
                    if saved {
                        // Inform user photo has exported successfully
                        self.exportMessage(success: saved, status: status)
                    }
                }
            }
        }else if sender.tag == 1 {
            //Live Photo
            if recorder?.status == .readyToRecord {
                recorder?.livePhoto(export: true) { ready, photo, status, saved in
                    /*
                     if ready {
                     // Do something with the `photo` (PHLivePhotoPlus)
                     }
                     */
                    
                    if saved {
                        // Inform user Live Photo has exported successfully
                        self.exportMessage(success: saved, status: status!)
                    }
                }
            }
        }else if sender.tag == 2 {
            //GIF
            if recorder?.status == .readyToRecord {
                recorder?.gif(forDuration: 3.0, export: true) { ready, gifPath, status, saved in
                    /*
                     if ready {
                     // Do something with the `gifPath`
                     }
                     */
                    
                    if saved {
                        // Inform user GIF image has exported successfully
                        self.exportMessage(success: saved, status: status!)
                    }
                }
            }
        }
    }
    
    @IBAction func record(_ sender: UIButton) {
        if sender.tag == 0 {
            //Record
            if recorder?.status == .readyToRecord {
                sender.setTitle("Stop", for: .normal)
                pauseBtn.setTitle("Pause", for: .normal)
                pauseBtn.isEnabled = true
                recorder?.record()
            }else if recorder?.status == .recording {
                sender.setTitle("Record", for: .normal)
                pauseBtn.setTitle("Pause", for: .normal)
                pauseBtn.isEnabled = false
                recorder?.stop() { path in
                    self.recorder?.export(video: path) { saved, status in
                        DispatchQueue.main.sync {
                            self.exportMessage(success: saved, status: status)
                        }
                    }
                }
            }
        }else if sender.tag == 1 {
            //Record with duration
            if recorder?.status == .readyToRecord {
                sender.setTitle("Stop", for: .normal)
                pauseBtn.setTitle("Pause", for: .normal)
                pauseBtn.isEnabled = false
                recordBtn.isEnabled = false
                recorder?.record(forDuration: 10) { path in
                    self.recorder?.export(video: path) { saved, status in
                        DispatchQueue.main.sync {
                            sender.setTitle("w/Duration", for: .normal)
                            self.pauseBtn.setTitle("Pause", for: .normal)
                            self.pauseBtn.isEnabled = false
                            self.recordBtn.isEnabled = true
                            self.exportMessage(success: saved, status: status)
                        }
                    }
                }
            }else if recorder?.status == .recording {
                sender.setTitle("w/Duration", for: .normal)
                pauseBtn.setTitle("Pause", for: .normal)
                pauseBtn.isEnabled = false
                recordBtn.isEnabled = true
                recorder?.stop() { path in
                    self.recorder?.export(video: path) { saved, status in
                        DispatchQueue.main.sync {
                            self.exportMessage(success: saved, status: status)
                        }
                    }
                }
            }
        }else if sender.tag == 2 {
            //Pause
            if recorder?.status == .paused {
                sender.setTitle("Pause", for: .normal)
                recorder?.record()
            }else if recorder?.status == .recording {
                sender.setTitle("Resume", for: .normal)
                recorder?.pause()
            }
        }
    }
}

//MARK: - ARVideoKit Delegate Methods
extension SKViewController {
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {
        // Do some image/video processing.
    }
    
    func recorder(didEndRecording path: URL, with noError: Bool) {
        if noError {
            // Do something with the video path.
        }
    }
    
    func recorder(didFailRecording error: Error?, and status: String) {
        // Inform user an error occurred while recording.
    }
    
    func recorder(willEnterBackground status: RecordARStatus) {
        // Use this method to pause or stop video recording. Check [applicationWillResignActive(_:)](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622950-applicationwillresignactive) for more information.
        if status == .recording {
            recorder?.stopAndExport()
        }
    }
}

// MARK: - ARSKView Delegate Methods
extension SKViewController {
    var randoMoji:String {
        let emojis = ["👾", "🤓", "🔥", "😜", "😇", "🤣", "🤗"]
        return emojis[Int(arc4random_uniform(UInt32(emojis.count)))]
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let labelNode = SKLabelNode(text: randoMoji)
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        return labelNode;
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
