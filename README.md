# flutter_webview_plugin


Plugin that allow Flutter to communicate with a native Webview.


***For Android, it will launch a new Activity inside the App with the Webview inside. Does not allow to integrate a Webview inside a Flutter Widget***

***For IOS, it will launch a new UIViewController inside the App with the UIWebView inside. Does not allow to integrate a Webview inside a Flutter Widget***

 - [x] Android
 - [x] IOS


## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).


### Dart

```dart
var flutterWebviewPlugin = new FlutterWebviewPlugin();
```

### Android

Add the Activity to you `AndroidManifest.xml`

```xml
<activity android:name="com.flutter_webview_plugin.WebviewActivity"
                  android:parentActivityName=".MainActivity"/>
```

### IOS

No extra configuration is needed
