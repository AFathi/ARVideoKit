//
//  ViewController.m
//  ARKit-Video
//
//  Created by Ahmed Bekhit on 1/11/18.
//  Copyright © 2018 Ahmed Fathi Bekhit. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *skBtn;
@property (weak, nonatomic) IBOutlet UIButton *scnBtn;
@end

    
@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.skBtn.layer.cornerRadius = self.skBtn.bounds.size.height/2;
    self.scnBtn.layer.cornerRadius = self.scnBtn.bounds.size.height/2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
