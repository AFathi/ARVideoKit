# Objective-C Example
This folder provides you an example project written in Objective-C that demonstrates the use of [**ARVideoKit**](https://github.com/AFathi/ARVideoKit) framework.

## Implementation
1. Import the `ARVideoKit` into the application delegate implementation file  `AppDelegate.m` and a `UIViewController` class with an `ARKit` scene.
```
@import ARVideoKit;
```

2. In the application delegate  implementation file  `AppDelegate.m`, add this 👇 in order to allow the framework access and identify the supported device orientations. **Recommended** if the application supports landscape orientations.
```
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
return ViewAR.orientation;
}
```

3. In the selected `UIViewController` class, create a  [`RecordAR`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR) global variable by adding the following in the interface section of the implementation file (e.g `ViewController.m`).
```
@interface ViewController ()
{
    RecordAR *recorder;
}
```

4. Initialize [`RecordAR`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR) with [`ARSCNView`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#init-arscenekitarscnview) or [`ARSKView`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#init-arspritekitarskview). **Recommended** to initialize in `(void)viewDidLoad`.

Initializing RecordAR with `ARSCNView`
```
recorder = [[RecordAR alloc] initWithARSceneKit:self.sceneView];
```
Initializing RecordAR with `ARSKView`
```
recorder = [[RecordAR alloc] initWithARSpriteKit:self.SKSceneView];
```

5. Call the [`prepare()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-prepare_-configurationarconfiguration) method in `(void)viewWillAppear:(BOOL)animated`
```
ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
[recorder prepare:configuration];
```

6. Call the [`rest()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-rest) method in `(void)viewWillDisappear:(BOOL)animated`
```
[recorder rest];
```

7. Call the [`record()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-record) method in the proper method to start recording.
```
- (IBAction)startRecording:(UIButton *)sender {
    if (recorder.status == RecordARStatusReadyToRecord) {
        [recorder record];
    }
}
```

8. Call the [`stopAndExport()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-stopandexport_-finished-_-videopath-url-_-permissionstatusphauthorizationstatus-_-exportedbool---swiftvoid--nil) method in the proper method to stop recording.
```
- (IBAction)stopRecording:(UIButton *)sender {
    if (recorder.status == RecordARStatusRecording) {
        [recorder stopAndExport:NULL];
    }
}
```
