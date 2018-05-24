import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class WebviewScaffold extends StatefulWidget {
  final PreferredSizeWidget appBar;
  final String url;
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool enableAppScheme;
  final String userAgent;
  final bool primary;
  final List<Widget> persistentFooterButtons;
  final Widget bottomNavigationBar;
  final bool withZoom;
  final bool withLocalStorage;
  final bool withLocalUrl;

  WebviewScaffold(
      {Key key,
      this.appBar,
      @required this.url,
      this.withJavascript,
      this.clearCache,
      this.clearCookies,
      this.enableAppScheme,
      this.userAgent,
      this.primary: true,
      this.persistentFooterButtons,
      this.bottomNavigationBar,
      this.withZoom,
      this.withLocalStorage,
      this.withLocalUrl})
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
          rect: _rect,
          withZoom: widget.withZoom,
          withLocalStorage: widget.withLocalStorage,
          withLocalUrl: widget.withLocalUrl);
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
        persistentFooterButtons: widget.persistentFooterButtons,
        bottomNavigationBar: widget.bottomNavigationBar,
        body: new Center(child: new CircularProgressIndicator()));
  }

  Rect _buildRect(BuildContext context) {
    bool fullscreen = widget.appBar == null;

    final mediaQuery = MediaQuery.of(context);
    final topPadding = widget.primary ? mediaQuery.padding.top : 0.0;
    num top =
        fullscreen ? 0.0 : widget.appBar.preferredSize.height + topPadding;

    num height = mediaQuery.size.height - top;

    if (widget.bottomNavigationBar != null) {
      height -=
          56.0 + mediaQuery.padding.bottom; // todo(lejard_h) find a way to determine bottomNavigationBar programmatically
    }

    if (widget.persistentFooterButtons != null) {
      height -=
          53.0; // todo(lejard_h) find a way to determine persistentFooterButtons programmatically
      if (widget.bottomNavigationBar == null){
         height -= mediaQuery.padding.bottom;
      }
    }

    return new Rect.fromLTWH(0.0, top, mediaQuery.size.width, height);
  }
}
