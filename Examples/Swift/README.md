# Swift Example
This folder provides you an example project written in Swift that demonstrates the use of [**ARVideoKit**](https://github.com/AFathi/ARVideoKit) framework.

## Implementation
1. `import ARVideoKit` in the application delegate `AppDelegate.swift` and a `UIViewController` with an `ARKit` scene.

2. In the application delegate `AppDelegate.swift`, add this 👇 in order to allow the framework access and identify the supported device orientations. **Recommended** if the application supports landscape orientations.
```
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
return ViewAR.orientation
}
```

3. In the selected `UIViewController` class, create an optional type [`RecordAR`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR) global variable.
```
var recorder:RecordAR?
```

4. Initialize [`RecordAR`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR) with [`ARSCNView`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#init-arscenekitarscnview) or [`ARSKView`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#init-arspritekitarskview). **Recommended** to initialize in `viewDidLoad()`.

Initializing RecordAR with `ARSCNView`
```
recorder = RecordAR(ARSceneKit: sceneView)
```
Initializing RecordAR with `ARSKView`
```
recorder = RecordAR(ARSpriteKit: SKSceneView)
```

5. Call the [`prepare()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-prepare_-configurationarconfiguration) method in `viewWillAppear(_ animated: Bool)`
```
let configuration = ARWorldTrackingConfiguration()
recorder?.prepare(configuration)
```

6. Call the [`rest()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-rest) method in `viewWillDisappear(_ animated: Bool)`
```
recorder?.rest()
```

7. Call the [`record()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-record) method in the proper method to start recording.
```
@IBAction func startRecording(_ sender: UIButton) {
recorder?.record()
}
```

8. Call the [`stopAndExport()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-stopandexport_-finished-_-videopath-url-_-permissionstatusphauthorizationstatus-_-exportedbool---swiftvoid--nil) method in the proper method to stop recording.
```
@IBAction func stopRecording(_ sender: UIButton) {
recorder?.stopAndExport()
}
```
