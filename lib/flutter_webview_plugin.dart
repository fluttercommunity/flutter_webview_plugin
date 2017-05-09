import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterWebviewPlugin {

  static FlutterWebviewPlugin _instance;
  FlutterWebviewPlugin._() {
    _init();
  }
  factory FlutterWebviewPlugin() => _instance ??= new FlutterWebviewPlugin._();


  StreamController<Null> _onDestroy = new StreamController.broadcast();
  Stream<Null> get onDestroy => _onDestroy.stream;

  StreamController<Null> _onBackPressed =
  new StreamController.broadcast();

  Stream<Null> get onBackPressed => _onDestroy.stream;

  final MethodChannel _channel = const MethodChannel('flutter_webview_plugin');

  Future<Null> launch(String url,
      {bool withJavascript: true,
        bool clearCache: false,
        bool clearCookies: false}) =>
      _channel.invokeMethod('launch', {
        "url": url,
        "withJavascript": withJavascript,
        "clearCache": clearCache,
        "clearCookies": clearCookies
      });

  Future<Null> close() => _channel.invokeMethod("close");

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
}