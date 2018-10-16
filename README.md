[![pub package](https://img.shields.io/pub/v/flutter_webview_plugin.svg)](https://pub.dartlang.org/packages/flutter_webview_plugin) 


# flutter_webview_plugin

Plugin that allow Flutter to communicate with a native WebView.

***Warning:***
The webview is not integrated in the widget tree, it is a native view on top of the flutter view.
you won't be able to use snackbars, dialogs ...

## Getting Started

For help getting started with Flutter, view our online [documentation](http://flutter.io/).

### How it works

#### Launch WebView Fullscreen with Flutter navigation

```dart
new MaterialApp(
      routes: {
        "/": (_) => new WebviewScaffold(
              url: "https://www.google.com",
              appBar: new AppBar(
                title: new Text("Widget webview"),
              ),
            )
      },
    );
```

`FlutterWebviewPlugin` provide a singleton instance linked to one unique webview,
so you can take control of the webview from anywhere in the app

listen for events
```dart
final flutterWebviewPlugin = new FlutterWebviewPlugin();

flutterWebviewPlugin.onUrlChanged.listen((String url) {
  
});
```

#### Listen for scroll event in webview

```dart
final flutterWebviewPlugin = new FlutterWebviewPlugin();
flutterWebviewPlugin.onScrollYChanged.listen((double offsetY) { // latest offset value in vertical scroll
  // compare vertical scroll changes here with old value
});

flutterWebviewPlugin.onScrollXChanged.listen((double offsetX) { // latest offset value in horizontal scroll
  // compare horizontal scroll changes here with old value
});

````

Note: Do note there is a slight difference is scroll distance between ios and android. Android scroll value difference tends to be larger than ios devices.


#### Hidden WebView

```dart
final flutterWebviewPlugin = new FlutterWebviewPlugin();  

flutterWebviewPlugin.launch(url, hidden: true);
```

#### Close launched WebView

```dart
flutterWebviewPlugin.close();
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
- `Stream<WebViewStateChanged>` onStateChanged
- `Stream<String>` onError

***Don't forget to dispose webview***
`flutterWebviewPlugin.dispose()`

### Webview Functions

```dart
Future<Null> launch(String url,
         {Map<String, String> headers: null,
         bool withJavascript: true,
         bool clearCache: false,
         bool clearCookies: false,
         bool hidden: false,
         bool enableAppScheme: true,
         Rect rect: null,
         String userAgent: null,
         bool withZoom: false,
         bool withLocalStorage: true,
         bool scrollBar: true});
```
```dart
Future<String> evalJavascript(String code);
```
```dart
Future<Map<String, dynamic>> getCookies();
```
```dart
Future<Null> resize(Rect rect);
```
```dart
Future<Null> show();
```
```dart
Future<Null> hide();
```
```dart
Future<Null> reloadUrl(String url);
```
