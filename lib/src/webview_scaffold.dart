import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/src/javascript_channel.dart';
import 'package:flutter_webview_plugin/src/webview_rect.dart';

class WebviewScaffold extends StatelessWidget {
  const WebviewScaffold({
    Key key,
    this.appBar,
    @required this.url,
    this.headers,
    this.javascriptChannels,
    this.withJavascript,
    this.clearCache,
    this.clearCookies,
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
  }) : super(key: key);

  final PreferredSizeWidget appBar;
  final String url;
  final Map<String, String> headers;
  final Set<JavascriptChannel> javascriptChannels;
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        persistentFooterButtons: persistentFooterButtons,
        bottomNavigationBar: bottomNavigationBar,
        body: WebviewRect(
          url: url,
          headers: headers,
          javascriptChannels: javascriptChannels,
          withJavascript: withJavascript,
          clearCache: clearCache,
          clearCookies: clearCookies,
          hidden: hidden,
          enableAppScheme: enableAppScheme,
          userAgent: userAgent,
          withZoom: withZoom,
          displayZoomControls: displayZoomControls,
          withLocalStorage: withLocalStorage,
          withLocalUrl: withLocalUrl,
          localUrlScope: localUrlScope,
          withOverviewMode: withOverviewMode,
          useWideViewPort: useWideViewPort,
          scrollBar: scrollBar,
          supportMultipleWindows: supportMultipleWindows,
          appCacheEnabled: appCacheEnabled,
          allowFileURLs: allowFileURLs,
          invalidUrlRegex: invalidUrlRegex,
          geolocationEnabled: geolocationEnabled,
          debuggingEnabled: debuggingEnabled,
          initialChild: initialChild,
        ));
  }
}
