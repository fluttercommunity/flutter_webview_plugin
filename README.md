# flutter_webview_plugin

Plugin that allow Flutter to communicate with a native WebView.

## Getting Started

For help getting started with Flutter, view our online [documentation](http://flutter.io/).

### How it works

#### Launch WebView Fullscreen (default)

On Android, add the Activity to you `AndroidManifest.xml`:

```xml
<activity android:name="com.flutter_webview_plugin.WebviewActivity" android:parentActivityName=".MainActivity"/>
```

***For Android, it will launch a new Activity inside the App with the Webview inside. Does not allow to integrate a Webview inside a Flutter Widget***

***For IOS, it will launch a new UIViewController inside the App with the UIWebView inside. Does not allow to integrate a Webview inside a Flutter Widget***


```dart
final flutterWebviewPlugin = new FlutterWebviewPlugin();  

flutterWebviewPlugin.launch(url);  
```

#### Close launched WebView

```dart
final flutterWebviewPlugin = new FlutterWebviewPlugin();  

flutterWebviewPlugin.launch(url);  

....

// Close WebView.
// This will also emit the onDestroy event.
flutterWebviewPlugin.close();
```

#### Hidden webView

```dart
final flutterWebviewPlugin = new FlutterWebviewPlugin();  

flutterWebviewPlugin.launch(url, hidden: true);
```

#### Webview inside custom Rectangle

```dart
final flutterWebviewPlugin = new FlutterWebviewPlugin();  

flutterWebviewPlugin.launch(url,
                  fullScreen: false,
                  rect: new Rect.fromLTWH(
                      0.0, 
                      0.0, 
                      MediaQuery.of(context).size.width, 
                      300.0));
```

### Webview Events

- `Stream<Null>` onDestroy
- `Stream<String>` onUrlChanged
- `Stream<Null>` onBackPressed
- `Stream<WebViewStateChanged>` onStateChanged

***Don't forget to dispose webview***
`flutterWebviewPlugin.dispose()`