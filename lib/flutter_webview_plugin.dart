import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

const _kChannel = 'flutter_webview_plugin';

// TODO: more genral state for iOS/android
enum WebViewState { shouldStart, startLoad, finishLoad }

/// Singleton Class that communicate with a fullscreen Webview Instance
/// Have to be instanciate after `runApp` called.
class FlutterWebViewPlugin {
  final MethodChannel _channel;

  final StreamController<Null> _onDestroy = new StreamController.broadcast();
  final StreamController<Null> _onBackPressed =
      new StreamController.broadcast();

  final StreamController<String> _onUrlChanged =
      new StreamController.broadcast();

  final StreamController<Null> _onStateChanged =
      new StreamController.broadcast();

  final StreamController<Null> _onError = new StreamController.broadcast();

  FlutterWebViewPlugin() : _channel = const MethodChannel(_kChannel) {
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
        _onStateChanged.add(call.arguments);
        break;
      case "onError":
        _onError.add(call.arguments);
        break;
    }
  }

  /// Listening the OnDestroy LifeCycle Event for Android
  /// content is Map for url
  Stream<Null> get onDestroy => _onDestroy.stream;

  /// Listening url changed
  /// iOS WebView: worked
  /// android: worked
  Stream<Null> get onUrlChanged => _onUrlChanged.stream;

  /// Listening the onBackPressed Event for Android
  /// content null
  /// iOS WebView: worked
  /// android: worked
  Stream<Null> get onBackPressed => _onBackPressed.stream;

  /// Listening the onState Event for iOS WebView and Android
  /// content is Map for type: {shouldStart|startLoad|finishLoad}
  /// more detail than other events
  /// iOS WebView: worked
  /// android: Not for now.
  Stream<Null> get onStateChanged => _onStateChanged.stream;

  /// Start the Webview with [url]
  /// - [withJavascript] enable Javascript or not for the Webview
  ///     iOS WebView: Not implemented yet
  ///     android: Implemented.
  /// - [clearCache] clear the cache of the Webview
  ///     iOS WebView: Not implemented yet
  ///     iOS WkWebView: TODO: later
  ///     android: Implemented
  /// - [clearCookies] clear all cookies of the Webview
  ///     iOS WebView: Not implemented yet
  ///     iOS WkWebView: will implement later
  ///     android: Implemented
  /// - [hidden] not show
  ///     iOS WebView: not shown(addSubView) in ViewController
  ///     android: Implemented
  ///   [fullScreen]: show in full screen mode, default true
  ///     iOS WebView: without rect, show in full screen mode
  ///     android: Implemented
  ///   [rect]: show in rect(not full screen)
  ///     iOS WebView: worked
  ///     android: Implemented
  ///   [enableAppScheme]: false will enable all schemes, true only for httt/https/about
  ///     iOS WebView: worked
  ///     android: Not implemented yet
  ///   [userAgent]: set the User-Agent of WebView
  ///     iOS WebView: worked
  ///     android: Implemented
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

  /// iOS WebView: worked
  /// android: implemented
  Future<String> evalJavascript(String code) {
    return _channel.invokeMethod('eval', {"code": code});
  }

  /// Close the Webview
  /// Will trigger the [onDestroy] event
  Future<Null> close() => _channel.invokeMethod("close");
}
