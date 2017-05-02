# flutter_webview_plugin


Plugin that allow Flutter to communicate with a native Webview.


***It will launch a new Activity inside the App with the Webview inside. Does not allow to integrate a Webview inside a Flutter Widget***

TODO:

 - [x] Android
 - [ ] IOS


## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).


### Android

Add the Activity to you `AndroidManifest.xml`

```xml
<activity android:name="com.flutter_webview_plugin.WebviewActivity"
                  android:parentActivityName=".MainActivity"/>
```
