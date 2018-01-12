//
//  Scene.swift
//  tstAR view
//
//  Created by Ahmed Bekhit on 10/2/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import SpriteKit
import ARKit
extension SKLabelNode {
    func fitToHeight(maxHeight:CGFloat){
        while frame.size.height >= maxHeight {
            fontSize-=1.0
        }
    }
}

class Scene: SKScene {
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
