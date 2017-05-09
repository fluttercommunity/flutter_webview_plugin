import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterWebviewPlugin {
  static bool _init = false;
  static StreamController<Null> _onDestroy = new StreamController.broadcast();
  static Stream<Null> get onDestroy => _onDestroy.stream;

  static StreamController<Null> _onBackPressed =
      new StreamController.broadcast();
  static Stream<Null> get onBackPressed => _onDestroy.stream;

  static const MethodChannel _channel =
      const MethodChannel('flutter_webview_plugin');

  static Future<Null> launch(String url,
          {bool withJavascript: true,
          bool clearCache: false,
          bool clearCookies: false}) =>
      _channel.invokeMethod('launch', {
        "url": url,
        "withJavascript": withJavascript,
        "clearCache": clearCache,
        "clearCookies": clearCookies
      });

  static Future<Null> close() => _channel.invokeMethod("close");

  static init() {
    if (!_init) {
      _init = true;
      _channel.setMethodCallHandler(_handleMessages);
    }
  }

  static Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case "onDestroy":
        _onDestroy.add(null);
        break;
      case "onBackPressed":
        _onBackPressed.add(null);
        break;
    }
  }
}
