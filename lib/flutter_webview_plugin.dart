import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

const _kChannel = 'flutter_webview_plugin';
const _kEvent = 'flutter_webview_plugin_event';

/// Singleton Class that communicate with a fullscreen Webview Instance
/// Have to be instanciate after `runApp` called.
class FlutterWebviewPlugin {
  final MethodChannel _channel;

  final EventChannel _event;
  Stream<String> _stateChanged;

  Stream<String> get stateChanged {
    if (_stateChanged == null) {
      _stateChanged = _event.receiveBroadcastStream();
    }
    return _stateChanged;
  }

  final StreamController<Null> _onDestroy = new StreamController.broadcast();
  final StreamController<Null> _onBackPressed =
      new StreamController.broadcast();

  final StreamController<String> _onUrlChanged =
      new StreamController.broadcast();

  FlutterWebviewPlugin()
      : _channel = const MethodChannel(_kChannel),
        _event = const EventChannel(_kEvent) {
    _channel.setMethodCallHandler(_handleMessages);
  }

  Future<Null> _handleMessages(MethodCall call) async {
    print("_handleMessages $call");
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
      bool hidden: false,
      bool fullScreen: true,
      Rect rect: null}) async {
    Map<String, dynamic> args = {
      "url": url,
      "withJavascript": withJavascript,
      "clearCache": clearCache,
      "hidden": hidden,
      "clearCookies": clearCookies,
      "fullScreen": fullScreen
    };
    if (!fullScreen) assert(rect != null);
    if (rect != null) {
      args["rect"] = {
        "left": rect.left,
        "right": rect.right,
        "width": rect.width,
        "height": rect.height
      };
    }
    await _channel.invokeMethod('launch', args);
  }

  Future<Null> evalJavascript(String code) {
    return _channel.invokeMethod('eval', {"code": code});
  }

  /// Close the Webview
  /// Will trigger the [onDestroy] event
  Future<Null> close() => _channel.invokeMethod("close");

  /// Listening url changed
  ///
  Stream<String> get onUrlChanged => _onUrlChanged.stream;
}
