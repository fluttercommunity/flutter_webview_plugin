# flutter_webview_plugin

Plugin that allow Flutter to communicate with a native WebView.

***For Android, it will launch a new Activity inside the App with the Webview inside. Does not allow to integrate a Webview inside a Flutter Widget***

***For IOS, it will launch a new UIViewController inside the App with the UIWebView inside. Does not allow to integrate a Webview inside a Flutter Widget***

 - [x] Android
 - [x] IOS

## Getting Started

For help getting started with Flutter, view our online [documentation](http://flutter.io/).

### How it works

#### Launch WebView with variable url

```dart
void launchWebView(String url) sync {
  var flutterWebviewPlugin = new FlutterWebviewPlugin();  
  
  flutterWebviewPlugin.launch(url);  
  
  // Wait in this async function until destroy of WebView.
  await flutterWebviewPlugin.onDestroy.first;
}
```

### Close launched WebView

```dart
void launchWebViewAndCloseAfterWhile(String url) {
  var flutterWebviewPlugin = new FlutterWebviewPlugin();  
  
  flutterWebviewPlugin.launch(url);  
  
  // After 10 seconds.
  new Timer(const Duration(seconds: 10), () {
    // Close WebView.
    // This will also emit the onDestroy event.
    flutterWebviewPlugin.close();
  });
}
```

### Android

Add the Activity to you `AndroidManifest.xml`:

```xml
<activity android:name="com.flutter_webview_plugin.WebviewActivity" android:parentActivityName=".MainActivity"/>
```

### iOS

No extra configuration is needed.
