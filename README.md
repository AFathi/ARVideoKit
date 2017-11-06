# ARVideoKit
An iOS Framework that enables developers to capture videos 📹, photos 🌄, Live Photos 🎇, and GIFs 🎆 with ARKit content.

| Table of Contents  |  Description       |
| ------------------ |:------------------:|
| [Documentation](https://github.com/AFathi/ARVideoKit/wiki) | Describes the configuration options `ARVideoKit` offers |
| [Preview](#preview)                                        | Displays 2 GIF images captured using the supported [`gif`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-gifforduration-durationtimeinterval-exportbool-_-finished-_-statusbool-_-gifpath-url-_-permissionstatusphauthorizationstatus-_-exportedbool---swiftvoid--nil) method in `ARVideoKit`|
| [Key Features](#key-features) | Lists the key features `ARVideoKit` offers     |
| [Compatibility](#compatibility) | Describes the `ARVideoKit` device and iOS compatibality |
| [Example Project](#example-project) | Explains how to run the example project provided in this repository |
| [Installation](#installation) | Describes the [Manual](#manual) option to install `ARVideoKit`   |
| [Implementation](#implementation) | Lists the [steps needed](#implementation), [notes](#note), and [reference](#youre-all-set-) for more options  |
| [License](#license) | Describes `ARVideoKit` license |

## Preview
|[Initialized with SpriteKit](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#init-arspritekitarskview)👇 ‍‍‍‍‍‍ ‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍|[Initialized with SceneKit](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#init-arscenekitarscnview) 👇 ‍‍‍‍‍‍ ‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍|
|--------------|--------------|

![SpriteKit Preview](http://www.ahmedbekhit.com/SK_PREV.gif) ![SceneKit Preview](http://www.ahmedbekhit.com/SCN_PREVIEW.gif)
## Key Features
✅ Capture [Photos](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-photo---uiimage) from [`ARSCNView`](https://developer.apple.com/documentation/arkit/arscnview) and [`ARSKView`](https://developer.apple.com/documentation/arkit/arskview)

✅ Capture [Live Photos](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-livephotoexportbool-_-finished-_-statusbool-_-livephotophlivephotoplus-_-permissionstatusphauthorizationstatus-_-exportedbool---swiftvoid--nil) & [GIFs](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-gifforduration-durationtimeinterval-exportbool-_-finished-_-statusbool-_-gifpath-url-_-permissionstatusphauthorizationstatus-_-exportedbool---swiftvoid--nil) from [`ARSCNView`](https://developer.apple.com/documentation/arkit/arscnview) and [`ARSKView`](https://developer.apple.com/documentation/arkit/arskview)

✅ [Record](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-record) Videos from [`ARSCNView`](https://developer.apple.com/documentation/arkit/arscnview) and [`ARSKView`](https://developer.apple.com/documentation/arkit/arskview)

✅ [Pause/Resume](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-pause) video

✅ Allow device's Music playing in the [background while recording a video](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#var-enablemixwithothersbool)

✅ [Returns](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#var-onlyrenderwhilerecordingbool) rendered and raw buffers in a [protocol](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#var-renderarrenderardelegate) [method](https://github.com/AFathi/ARVideoKit/wiki/RenderARDelegate#func-framedidrender-buffercvpixelbuffer-with-timecmtime-using-rawbuffercvpixelbuffer) for additional Image & Video processing
## Compatibility
`ARVideoKit` is compatible on iOS devices that support both [`ARKit`](https://developer.apple.com/documentation/arkit) and [`Metal`](https://developer.apple.com/documentation/metal). Check Apple's [iOS Device Compatibility Reference](#) for more information.

`ARVideoKit` requires:
- iOS 11
- Swift 3.2 or higher

## Example Project
To try the example project, simply clone this repository and open `ARVideoKit-Example.xcodeproj` project file.

## Installation
### Manual
Drag the `ARVideoKit.framework` file as an embedded binary of your project targets. `ARVideoKit.framework` can be found in `/Framework/` folder in this repository.
![Tutorial](http://www.ahmedbekhit.com/arvideokit_install_new.gif)

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

7. Call the [`record()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-record) method in an appropriate method.
```
@IBAction func startRecording(_ sender: UIButton) {
recorder?.record()
}
```

8. Call the [`stopAndExport()`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-stopandexport_-finished-_-videopath-url-_-permissionstatusphauthorizationstatus-_-exportedbool---swiftvoid--nil) method in an appropriate method.
```
@IBAction func stopRecording(_ sender: UIButton) {
recorder?.stopAndExport()
}
```

### NOTE
Make sure you add the usage description of the `camera`, `microphone`, and `photo library` in the app's `Info.plist`.
```
<key>NSCameraUsageDescription</key>
<string>AR Camera</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Export AR Media</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Export AR Media</string>
<key>NSMicrophoneUsageDescription</key>
<string>Audiovisual Recording</string>
```
![Info Plist Screenshot](http://www.ahmedbekhit.com/infoPlistUsage.png)
### You're all set. 🤓
Check [`RecordAR`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR) documentation for more options!

## [License](#)
Copyright 2017 Ahmed Fathi Bekhit

`ARVideoKit` is licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
