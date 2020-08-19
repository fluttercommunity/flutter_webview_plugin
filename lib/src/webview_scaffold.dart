import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_webview_plugin/src/javascript_channel.dart';

import 'base.dart';

class WebviewScaffold extends StatefulWidget {
  const WebviewScaffold({
    Key key,
    this.appBar,
    @required this.url,
    this.headers,
    this.javascriptChannels,
    this.withJavascript,
    this.clearCache,
    this.clearCookies,
    this.mediaPlaybackRequiresUserGesture = true,
    this.enableAppScheme,
    this.userAgent,
    this.primary = true,
    this.persistentFooterButtons,
    this.bottomNavigationBar,
    this.withZoom,
    this.displayZoomControls,
    this.withLocalStorage,
    this.withLocalUrl,
    this.localUrlScope,
    this.withOverviewMode,
    this.useWideViewPort,
    this.scrollBar,
    this.supportMultipleWindows,
    this.appCacheEnabled,
    this.hidden = false,
    this.initialChild,
    this.allowFileURLs,
    this.resizeToAvoidBottomInset = false,
    this.invalidUrlRegex,
    this.geolocationEnabled,
    this.debuggingEnabled = false,
    this.ignoreSSLErrors = false,
    this.transitionType = TransitionType.Non
  }) :
        assert(transitionType != null,'TransitionType must not null !'),
        super(key: key);
  /// in Debug mode,the first init webview page at slide/scale transition,will display misalignment
  /// after that will be display properly.
  ///
  /// in Profile/Release mode, will always display properly.
  final TransitionType transitionType;

  final PreferredSizeWidget appBar;
  final String url;
  final Map<String, String> headers;
  final Set<JavascriptChannel> javascriptChannels;
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool mediaPlaybackRequiresUserGesture;
  final bool enableAppScheme;
  final String userAgent;
  final bool primary;
  final List<Widget> persistentFooterButtons;
  final Widget bottomNavigationBar;
  final bool withZoom;
  final bool displayZoomControls;
  final bool withLocalStorage;
  final bool withLocalUrl;
  final String localUrlScope;
  final bool scrollBar;
  final bool supportMultipleWindows;
  final bool appCacheEnabled;
  final bool hidden;
  final Widget initialChild;
  final bool allowFileURLs;
  final bool resizeToAvoidBottomInset;
  final String invalidUrlRegex;
  final bool geolocationEnabled;
  final bool withOverviewMode;
  final bool useWideViewPort;
  final bool debuggingEnabled;
  final bool ignoreSSLErrors;

  @override
  _WebviewScaffoldState createState() => _WebviewScaffoldState();
}

class _WebviewScaffoldState extends State<WebviewScaffold> {
  final webviewReference = FlutterWebviewPlugin();
  Rect _rect;
  Timer _resizeTimer;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  var _onBack;

  @override
  void initState() {
    super.initState();
    webviewReference.close();
    perceptionPageTransition();

    _onBack = webviewReference.onBack.listen((_) async {
      if (!mounted) {
        return;
      }

      // The willPop/pop pair here is equivalent to Navigator.maybePop(),
      // which is what's called from the flutter back button handler.
      final pop = await _topMostRoute.willPop();
      if (pop == RoutePopDisposition.pop) {
        // Close the webview if it's on the route at the top of the stack.
        final isOnTopMostRoute = _topMostRoute == ModalRoute.of(context);
        if (isOnTopMostRoute) {
          webviewReference.close();
        }
        Navigator.pop(context);
      }
    });

    if (widget.hidden) {
      _onStateChanged =
          webviewReference.onStateChanged.listen((WebViewStateChanged state) {
        if (state.type == WebViewState.finishLoad) {
          webviewReference.show();
        }
      });
    }
  }

  /// coordinate the webview rect whit page's transition
  void perceptionPageTransition(){
    if(widget.transitionType != TransitionType.Non){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        //avoid to concurrent modification exception
        WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
          if(context != null){
            driveWebView();
          }
        });
      });
    }
  }

  void driveWebView(){
    final RenderBox box = context.findRenderObject();
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final Rect rect = box.paintBounds;
    if(offset.dx == rect.left)return;

    final double value = offset.dx/size.width;

    switch(widget.transitionType){
      case TransitionType.Slide:
        webviewReference.resize(_rect.shift(offset));
        break;
      case TransitionType.Scale:
        final double www = box.size.width*(value*2);
        final double hhh = box.size.height*(value*2);
        webviewReference.resize(Rect.fromLTWH(offset.dx,offset.dy,size.width-www , size.height-hhh));
        break;
      case TransitionType.Non:
        // TODO: Handle this case.
        break;
    }
  }


  /// Equivalent to [Navigator.of(context)._history.last].
  Route<dynamic> get _topMostRoute {
    var topMost;
    Navigator.popUntil(context, (route) {
      topMost = route;
      return true;
    });
    return topMost;
  }

  @override
  void dispose() {
    super.dispose();
    _onBack?.cancel();
    _resizeTimer?.cancel();
    webviewReference.close();
    if (widget.hidden) {
      _onStateChanged.cancel();
    }
    webviewReference.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      persistentFooterButtons: widget.persistentFooterButtons,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: _WebviewPlaceholder(
        onRectChanged: (Rect value) {
          if (_rect == null) {
            _rect = value;
            webviewReference.launch(
              widget.url,
              headers: widget.headers,
              javascriptChannels: widget.javascriptChannels,
              withJavascript: widget.withJavascript,
              clearCache: widget.clearCache,
              clearCookies: widget.clearCookies,
              mediaPlaybackRequiresUserGesture: widget.mediaPlaybackRequiresUserGesture,
              hidden: widget.hidden,
              enableAppScheme: widget.enableAppScheme,
              userAgent: widget.userAgent,
              rect: _rect,
              withZoom: widget.withZoom,
              displayZoomControls: widget.displayZoomControls,
              withLocalStorage: widget.withLocalStorage,
              withLocalUrl: widget.withLocalUrl,
              localUrlScope: widget.localUrlScope,
              withOverviewMode: widget.withOverviewMode,
              useWideViewPort: widget.useWideViewPort,
              scrollBar: widget.scrollBar,
              supportMultipleWindows: widget.supportMultipleWindows,
              appCacheEnabled: widget.appCacheEnabled,
              allowFileURLs: widget.allowFileURLs,
              invalidUrlRegex: widget.invalidUrlRegex,
              geolocationEnabled: widget.geolocationEnabled,
              debuggingEnabled: widget.debuggingEnabled,
              ignoreSSLErrors: widget.ignoreSSLErrors,
            );
          } else {
            if (_rect != value) {
              _rect = value;
              _resizeTimer?.cancel();
              _resizeTimer = Timer(const Duration(milliseconds: 250), () {
                // avoid resizing to fast when build is called multiple time
                webviewReference.resize(_rect);
              });
            }
          }
        },
        child: widget.initialChild ??
            const Center(child: const CircularProgressIndicator()),
      ),
    );
  }
}

class _WebviewPlaceholder extends SingleChildRenderObjectWidget {
  const _WebviewPlaceholder({
    Key key,
    @required this.onRectChanged,
    Widget child,
  }) : super(key: key, child: child);

  final ValueChanged<Rect> onRectChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _WebviewPlaceholderRender(
      onRectChanged: onRectChanged,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _WebviewPlaceholderRender renderObject) {
    renderObject..onRectChanged = onRectChanged;
  }
}

class _WebviewPlaceholderRender extends RenderProxyBox {
  _WebviewPlaceholderRender({
    RenderBox child,
    ValueChanged<Rect> onRectChanged,
  })  : _callback = onRectChanged,
        super(child);

  ValueChanged<Rect> _callback;
  Rect _rect;

  Rect get rect => _rect;

  set onRectChanged(ValueChanged<Rect> callback) {
    if (callback != _callback) {
      _callback = callback;
      notifyRect();
    }
  }

  void notifyRect() {
    if (_callback != null && _rect != null) {
      _callback(_rect);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final rect = offset & size;
    if (_rect != rect) {
      _rect = rect;
      notifyRect();
    }
  }
}
