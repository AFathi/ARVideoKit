//
//  SCNViewController.h
//  ARKit-Video
//
//  Created by Ahmed Bekhit on 1/11/18.
//  Copyright © 2018 Ahmed Fathi Bekhit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import <CoreMedia/CoreMedia.h>
@import ARVideoKit;

@interface SCNViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
- (IBAction)capture:(UIButton *)sender;
- (IBAction)record:(UIButton *)sender;
- (IBAction)goBack:(UIButton *)sender;
@end
