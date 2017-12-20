import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

const _kChannel = 'flutter_webview_plugin';

// TODO: more general state for iOS/android
enum WebViewState { shouldStart, startLoad, finishLoad }

// TODO: use an id by webview to be able to manage multiple webview

/// Singleton Class that communicate with a Webview Instance
/// Have to be instanciate after `runApp` called.
class FlutterWebviewPlugin {
  final _channel = const MethodChannel(_kChannel);

  final _onDestroy = new StreamController<Null>.broadcast();
  final _onBackPressed = new StreamController<Null>.broadcast();
  final _onUrlChanged = new StreamController<String>.broadcast();
  final _onStateChanged = new StreamController<WebViewStateChanged>.broadcast();
  final _onError = new StreamController<String>.broadcast();

  static FlutterWebviewPlugin _instance;

  factory FlutterWebviewPlugin() => _instance ??= new FlutterWebviewPlugin._();

  FlutterWebviewPlugin._() {
    _channel.setMethodCallHandler(_handleMessages);
  }

  Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case "onDestroy":
        _onDestroy.add(null);
        break;
      case "onBackPressed":
        _onBackPressed.add(null);
        break;
      case "onUrlChanged":
        _onUrlChanged.add(call.arguments["url"]);
        break;
      case "onState":
        _onStateChanged.add(new WebViewStateChanged.fromMap(call.arguments));
        break;
      case "onError":
        _onError.add(call.arguments);
        break;
    }
  }

  /// Listening the OnDestroy LifeCycle Event for Android
  Stream<Null> get onDestroy => _onDestroy.stream;

  /// Listening url changed
  Stream<String> get onUrlChanged => _onUrlChanged.stream;

  /// Listening the onBackPressed Event for Android
  /// content null
  /// iOS WebView: worked
  /// android: worked
  Stream<Null> get onBackPressed => _onBackPressed.stream;

  /// Listening the onState Event for iOS WebView and Android
  /// content is Map for type: {shouldStart(iOS)|startLoad|finishLoad}
  /// more detail than other events
  Stream<WebViewStateChanged> get onStateChanged => _onStateChanged.stream;

  /// Start the Webview with [url]
  /// - [withJavascript] enable Javascript or not for the Webview
  ///     iOS WebView: Not implemented yet
  /// - [clearCache] clear the cache of the Webview
  ///     iOS WebView: Not implemented yet
  /// - [clearCookies] clear all cookies of the Webview
  ///     iOS WebView: Not implemented yet
  /// - [hidden] not show
  /// - [fullScreen]: show in full screen mode, default true
  /// - [rect]: show in rect(not full screen)
  /// - [enableAppScheme]: false will enable all schemes, true only for httt/https/about
  ///     android: Not implemented yet
  /// - [userAgent]: set the User-Agent of WebView
  Future<Null> launch(String url,
      {bool withJavascript: true,
      bool clearCache: false,
      bool clearCookies: false,
      bool hidden: false,
      bool fullScreen: true,
      bool enableAppScheme: true,
      Rect rect: null,
      String userAgent: null}) async {
    Map<String, dynamic> args = {
      "url": url,
      "withJavascript": withJavascript,
      "clearCache": clearCache,
      "hidden": hidden,
      "clearCookies": clearCookies,
      "fullScreen": fullScreen,
      "enableAppScheme": enableAppScheme,
      "userAgent": userAgent
    };
    if (!fullScreen) assert(rect != null);
    if (rect != null) {
      args["rect"] = {
        "left": rect.left,
        "top": rect.top,
        "width": rect.width,
        "height": rect.height
      };
    }
    await _channel.invokeMethod('launch', args);
  }

  /// Execute Javascript inside webview
  Future<String> evalJavascript(String code) {
    return _channel.invokeMethod('eval', {"code": code});
  }

  /// Close the Webview
  /// Will trigger the [onDestroy] event
  Future<Null> close() => _channel.invokeMethod("close");

  /// Close all Streams
  void dispose() {
    _onDestroy.close();
    _onBackPressed.close();
    _onUrlChanged.close();
    _onStateChanged.close();
    _onError.close();
    _instance = null;
  }
}

class WebViewStateChanged {
  final WebViewState type;
  final String url;
  final int navigationType;

  WebViewStateChanged(this.type, this.url, this.navigationType);

  factory WebViewStateChanged.fromMap(Map<String, dynamic> map) {
    WebViewState t;
    switch (map["type"]) {
      case "shouldStart":
        t = WebViewState.shouldStart;
        break;
      case "startLoad":
        t = WebViewState.startLoad;
        break;
      case "finishLoad":
        t = WebViewState.finishLoad;
        break;
    }
    return new WebViewStateChanged(t, map["url"], map["navigationType"]);
  }
}
