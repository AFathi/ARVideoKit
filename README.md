# ARVideoKit
An iOS Framework that enables developers to capture videos 📹, photos 🌄, Live Photos 🎇, and GIFs 🎆 with ARKit content.

In other words, you **NO LONGER** have to ~screen record~/~screenshot~ to capture videos 📹 and photos 🌄 of your awesome ARKit apps!

| Table of Contents  |  Description       |
| ------------------ |:------------------:|
| [Documentation](https://github.com/AFathi/ARVideoKit/wiki) | Describes the configuration options `ARVideoKit` offers |
| [Preview](#preview)                                        | Displays 2 GIF images captured using the supported [`gif`](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#func-gifforduration-durationtimeinterval-exportbool-_-finished-_-statusbool-_-gifpath-url-_-permissionstatusphauthorizationstatus-_-exportedbool---swiftvoid--nil) method in `ARVideoKit`|
| [Key Features](#key-features) | Lists the key features `ARVideoKit` offers     |
| [Compatibility](#compatibility) | Describes the `ARVideoKit` device and iOS compatibality |
| [Example Project](#example-project) | Explains how to run the example project provided in this repository |
| [Installation](#installation) | Describes the [Manual](#manual) option to install `ARVideoKit`   |
| [Implementation](#implementation) | Lists the [steps needed](#implementation), [notes](#note), and [reference](#youre-all-set-) for more options  |
| [Publishing to the App Store](#publishing-to-the-app-store) | Describes the steps **required** before submitting an application using `ARVideoKit` to the App Store. |
| [License](#license) | Describes `ARVideoKit` license |

## Preview
|👾 [Initialized with SpriteKit](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#init-arspritekitarskview)👇 ‍‍‍‍‍‍ ‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍|🚀 [Initialized with SceneKit](https://github.com/AFathi/ARVideoKit/wiki/RecordAR#init-arscenekitarscnview) 👇 ‍‍‍‍‍‍ ‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍ ‍‍ ‍‍‍‍‍‍ ‍‍|
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
`ARVideoKit` is compatible on iOS devices that support both [`ARKit`](https://developer.apple.com/documentation/arkit) and [`Metal`](https://developer.apple.com/documentation/metal). Check Apple's [iOS Device Compatibility Reference](https://developer.apple.com/library/content/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/DeviceCompatibilityMatrix/DeviceCompatibilityMatrix.html#//apple_ref/doc/uid/TP40013599-CH17-SW1) for more information.

`ARVideoKit` requires:
- iOS 11
- Swift 3.2 or higher

## Example Project
To try the example project, simply clone this repository and open `ARVideoKit-Example.xcodeproj` project file.

It's **recommended** to test `SKViewController` by assigning it as the initial view controller.
![is initial VC](http://ahmedbekhit.com/isinitialVC.png)
## Installation
### Manual
Drag the `ARVideoKit.framework` file as an embedded binary of your project targets. `ARVideoKit.framework` can be found in the `/Framework/` folder of this repository.
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

## Publishing to the App Store
Before publishing to the App Store make sure to add the [ARVideoKit License](#license) to your app licences list.

Additionally, you MUST **strip out the simulator architectures** from the framework before pushing an application to the App Store.

To do so, follow those steps:

1. Install Carthage
> Download `Carthage.pkg` [from here](https://github.com/Carthage/Carthage/releases)

> Or install with Homebrew using this command `brew install carthage` 
2. Go to your project target's `Build Phase`
<img width="684" alt="screen shot 2017-11-14 at 8 21 44 pm" src="https://user-images.githubusercontent.com/4106695/32813978-e70ae5a0-c97a-11e7-9d19-3ef434e4c4f1.png">

3. Add a new `Run Script Phase`
<img width="686" alt="screen shot 2017-11-14 at 8 22 14 pm" src="https://user-images.githubusercontent.com/4106695/32814003-0ab4cffc-c97b-11e7-97d0-cf3143afec6d.png">

4. Add the following command to the `Run Script Phase`
```
/usr/local/bin/carthage copy-frameworks
```
<img width="676" alt="screen shot 2017-11-14 at 8 30 12 pm" src="https://user-images.githubusercontent.com/4106695/32814033-3302bece-c97b-11e7-867c-e8707ac7dd6b.png">

5. Finally, add `ARVideoKit.framework` file path as an `Input File`. In my case, I have it in a folder named `Frameworks` inside my project folder
<img width="672" alt="screen shot 2017-11-14 at 8 41 06 pm" src="https://user-images.githubusercontent.com/4106695/32814258-327bd048-c97c-11e7-8148-8d606d545214.png">

## [License](LICENSE)
Copyright 2017 Ahmed Fathi Bekhit, www.ahmedbekhit.com, me@ahmedbekhit.com

`ARVideoKit` is licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
