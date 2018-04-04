//
//  SKViewController.h
//  ARKit-Video
//
//  Created by Ahmed Bekhit on 1/11/18.
//  Copyright © 2018 Ahmed Fathi Bekhit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <ARKit/ARKit.h>
#import <CoreMedia/CoreMedia.h>
#import <Photos/Photos.h>
@import ARVideoKit;

@interface SKViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (nonatomic, strong) IBOutlet ARSKView *SKSceneView;
- (IBAction)capture:(UIButton *)sender;
- (IBAction)record:(UIButton *)sender;
- (IBAction)goBack:(UIButton *)sender;

@end
