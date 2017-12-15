import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

const _kChannel = 'flutter_webview_plugin';
const _kEvent = 'flutter_webview_plugin_event';

// TODO: more genral state for iOS/android
enum WebViewState { startLoad, finishLoad }

// copy from UIWebView.h
enum _WebViewNavigateType {
  TypeLinkClicked,
  TypeFormSubmitted,
  TypeBackForward,
  TypeReload,
  TypeFormResubmitted,
  TypeOther
}

/// Singleton Class that communicate with a fullscreen Webview Instance
/// Have to be instanciate after `runApp` called.
class FlutterWebViewPlugin {
  final MethodChannel _channel;

  /// iOS WebView: Implemented
  /// Android WebView: not implemented
  final EventChannel _event;
  Stream<String> _stateChanged;

  Stream<String> get stateChanged {
    assert(_WebViewNavigateType.TypeLinkClicked.index == 0);
    assert(_WebViewNavigateType.TypeOther.index == 5);
    if (_stateChanged == null) {
      _stateChanged = _event.receiveBroadcastStream();
      _stateChanged.listen((var result) {
        // the list like: [state, url, navtype]
        if (result is List && result.length == 3) {
          if (_WebViewNavigateType.TypeBackForward.index == result[2]) {
            _onBackPressed.add(Null);
          } else if (_WebViewNavigateType.TypeOther.index == result[2] ||
              _WebViewNavigateType.TypeLinkClicked.index == result[2] ||
              _WebViewNavigateType.TypeFormSubmitted.index == result[2]) {
            // TODO: find out better way
            _onUrlChanged.add(result[1]);
          }
        } else if (result is String) {
          if (result == "destroy") {
            _onDestroy.add(Null);
          }
        }
      });
    }
    return _stateChanged;
  }

  final StreamController<Null> _onDestroy = new StreamController.broadcast();
  final StreamController<Null> _onBackPressed =
      new StreamController.broadcast();

  final StreamController<String> _onUrlChanged =
      new StreamController.broadcast();

  FlutterWebViewPlugin()
      : _channel = const MethodChannel(_kChannel),
        _event = const EventChannel(_kEvent) {
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
  ///     android: Not implemented yet.
  ///   [fullScreen]: show in full screen mode, default true
  ///     iOS WebView: without rect, show in full screen mode
  ///     android: Implemented
  ///   [rect]: show in rect(not full screen)
  ///     iOS WebView: worked
  ///     android: Not implemented yet
  ///   [enableAppScheme]: false will enable all schemes, true only for httt/https/about
  ///     iOS WebView: worked
  ///     android: Not implemented yet
  ///   [userAgent]: set the User-Agent of WebView
  ///     iOS WebView: worked
  ///     android: Not implemented yet
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
        "right": rect.right,
        "width": rect.width,
        "height": rect.height
      };
    }
    await _channel.invokeMethod('launch', args);
  }

  /// iOS WebView: worked
  /// android: Not implemented yet
  Future<String> evalJavascript(String code) {
    return _channel.invokeMethod('eval', {"code": code});
  }

  /// Close the Webview
  /// Will trigger the [onDestroy] event
  Future<Null> close() => _channel.invokeMethod("close");

  /// Listening url changed
  /// iOS WebView: worked
  /// android: worked
  Stream<String> get onUrlChanged => _onUrlChanged.stream;
}
