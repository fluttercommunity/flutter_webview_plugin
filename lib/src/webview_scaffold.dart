import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'base.dart';

class WebviewScaffold extends StatefulWidget {
  final PreferredSizeWidget appBar;
  final String url;
  final withJavascript;
  final clearCache;
  final clearCookies;
  final enableAppScheme;
  final userAgent;
  final primary;

  WebviewScaffold(
      {Key key,
      this.appBar,
      @required this.url,
      this.withJavascript,
      this.clearCache,
      this.clearCookies,
      this.enableAppScheme,
      this.userAgent,
      this.primary: true})
      : super(key: key);

  @override
  _WebviewScaffoldState createState() => new _WebviewScaffoldState();
}

class _WebviewScaffoldState extends State<WebviewScaffold> {
  final webviewReference = new FlutterWebviewPlugin();
  Rect _rect;
  Timer _resizeTimer;

  void initState() {
    super.initState();
    webviewReference.close();
  }

  void dispose() {
    super.dispose();
    webviewReference.close();
    webviewReference.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rect == null) {
      _rect = _buildRect(context);
      webviewReference.launch(widget.url,
          withJavascript: widget.withJavascript,
          clearCache: widget.clearCache,
          clearCookies: widget.clearCookies,
          enableAppScheme: widget.enableAppScheme,
          userAgent: widget.userAgent,
          rect: _rect);
    } else {
      Rect rect = _buildRect(context);
      if (_rect != rect) {
        _rect = rect;
        _resizeTimer?.cancel();
        _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
          // avoid resizing to fast when build is called multiple time
          webviewReference.resize(_rect);
        });
      }
    }
    return new Scaffold(
        appBar: widget.appBar,
        body: new Center(child: new CircularProgressIndicator()));
  }

  Rect _buildRect(BuildContext context) {
    bool fullscreen = widget.appBar == null;

    final mediaQuery = MediaQuery.of(context);
    final topPadding = widget.primary ? mediaQuery.padding.top : 0.0;
    final appBarHeight =
        fullscreen ? 0.0 : widget.appBar.preferredSize.height + topPadding;
    return new Rect.fromLTWH(0.0, appBarHeight, mediaQuery.size.width,
        mediaQuery.size.height - appBarHeight);
  }
}
