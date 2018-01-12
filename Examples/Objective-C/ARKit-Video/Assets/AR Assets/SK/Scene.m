//
//  Scene.m
//  sktstobjc
//
//  Created by Ahmed Bekhit on 1/11/18.
//  Copyright © 2018 Ahmed Fathi Bekhit. All rights reserved.
//

#import "Scene.h"

@implementation Scene

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
}

- (void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.view isKindOfClass:[ARSKView class]]) {
        return;
    }
    
    ARSKView *sceneView = (ARSKView *)self.view;
    ARFrame *currentFrame = [sceneView.session currentFrame];
    
    // Create anchor using the camera's current position
    if (currentFrame) {
        
        // Create a transform with a translation of 0.2 meters in front of the camera
        matrix_float4x4 translation = matrix_identity_float4x4;
        translation.columns[3].z = -0.2;
        matrix_float4x4 transform = matrix_multiply(currentFrame.camera.transform, translation);
        
        // Add a new anchor to the session
        ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
        [sceneView.session addAnchor:anchor];
    }
}

@end
