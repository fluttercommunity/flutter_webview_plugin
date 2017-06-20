import 'dart:async';

import 'package:flutter/services.dart';

const _kChannel = 'flutter_webview_plugin';

/// Singleton Class that communicate with a fullscreen Webview Instance
/// Have to be instanciate after `runApp` called.
class FlutterWebviewPlugin {

  final MethodChannel _channel = const MethodChannel(_kChannel);
  StreamController<Null> _onDestroy = new StreamController.broadcast();
  StreamController<Null> _onBackPressed = new StreamController.broadcast();

  static FlutterWebviewPlugin _instance;
  FlutterWebviewPlugin._() {
    _init();
  }

  factory FlutterWebviewPlugin() => _instance ??= new FlutterWebviewPlugin._();

  _init() {
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
    }
  }

  //////////////////////

  /// Listening the OnDestroy LifeCycle Event for Android
  ///
  Stream<Null> get onDestroy => _onDestroy.stream;

  /// Listening the onBackPressed Event for Android
  ///
  Stream<Null> get onBackPressed => _onBackPressed.stream;

  /// Start the Webview with [url]
  /// - [withJavascript] enable Javascript or not for the Webview
  /// - [clearCache] clear the cache of the Webview
  /// - clearCookies] clear all cookies of the Webview
  Future<Null> launch(String url,
          {bool withJavascript: true,
          bool clearCache: false,
          bool clearCookies: false,
          bool fullScreen: true}) =>
      _channel.invokeMethod('launch', {
        "url": url,
        "withJavascript": withJavascript,
        "clearCache": clearCache,
        "clearCookies": clearCookies,
        "fullScreen": fullScreen
      });

  /// Close the Webview
  /// Will trigger the [onDestroy] event
  Future<Null> close() => _channel.invokeMethod("close");
}
