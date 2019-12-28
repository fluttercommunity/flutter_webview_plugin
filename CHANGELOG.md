# 0.3.10+1
- fixed android build

# 0.3.10
- add mediaPlaybackRequiresUserGesture parameter
- Add ignore ssl error parameter

# 0.3.9+1

- Fixed error methods on iOS

# 0.3.9

- Fixed error methods on iOS
- fixed build
- fixed ios clean cookies
- 4 Make plugin work in headless mode when extending FlutterApplication
- added canGoBack and canGoForward methods

# 0.3.8

- Fix iOS local URL support (fixes #114)
- bugfix: Added google() repository to allprojects to satisfy androidx build rules
- fixed min sdk for android

# 0.3.7

- Added reloading url with headers
- Added support for reloading url with headers

# 0.3.6

- Allow web contents debugging in Chrome
- Android: allow geolocation and file chooser simultaneously
- Add min sdk requirement and descriptions
- fix bug android webview httperror exception
- Exposes displayZoomControls, withOverviewMode and useWideViewPort settings for Android WebView

# 0.3.5

- Ability to choose from camera or gallery when using
- Support for webview’s estimated loading progress #255
- Fix back button handler to be compatible with the WillPopScope widget

# 0.3.4

- WebView always hidden on iOS

# 0.3.3

- BREAKING CHANGE - AndroidX support

# 0.3.2

- enable Javascript in iOS, support abort loading specific URLs
- add resizeToAvoidBottomInset to WebviewScaffold; #301

# 0.3.1

- Add support for geolocation Android
- fix No269: Can't load target="_blank" links on iOS
- fix: reloadUrl will not return Future
- Fix height of keyboard
- Fix Hide/Show WebView
- hotfix widget back to initialChild after webview is tapped on Android

# 0.3.0

- Fixes rect capture issue. Ensures WebView remains in the correct place on screen even when keyboard appears.
- Fixed iOS crash issue with Flutter `>= 0.10.2`.
- Added new `clearCookies` feature.
- Added support for `hidden` and `initialChild` feature to show page loading view.
- Added supportMultipleWindows: enables Multiple Window Support on Android.
- Added appCacheEnabled: enables Application Caches API on Android.
- Added allowFileURLs: allows `file://` local file URLs.
- iOS Now supports: `reload`, `goBack`, and `goForward`.
- iOS Bug fix `didFailNavigation` #77
- Updated Android `compileSdkVersion` to `27` matching offical Flutter plugins.
- Fixed Android `reloadUrl` so settings are not cleared.
- Enabled compatible `Mixed Content Mode` on Android.

# 0.2.1

- Added webview scrolling listener
- Added stopLoading() method

# 0.2.0

- update sdk
- prevent negative webview height in scaffold
- handle type error in getCookies
- Support file upload via WebView on Android
- fix WebviewScaffold crash on iOS
- Scrollbar functionality to Web view
- Add support of HTTP errors
- Add headers when loading url

# 0.1.6

- fix onStateChanged
- Taking safe areas into account for bottom bars
- iOS
    + withLocalUrl option for iOS > 9.0
- Android
    + add reload, goBack and foForward function

# 0.1.5

- iOS use WKWebView instead of UIWebView

# 0.1.4

- support localstorage for ANDROID

# 0.1.3

- support zoom in webview

# 0.1.2

- support bottomNavigationBar and persistentFooterButtons on webview scaffold

# 0.1.1
- support back button navigation for Android
    + if cannot go back, it will trigger onDestroy
- support preview dart2

# 0.1.0+1

- fix Android close webview

# 0.1.0

- iOS && Android:
    - get cookies
    - eval javascript
    - user agent setting
    - state change event
    - embed in rectangle or fullscreen if null
    - hidden webview

- Android
    - adding Activity in manifest is not needed anymore

- Add `WebviewScaffold`

# 0.0.9

- Android: remove the need to use FlutterActivity as base activity

# 0.0.5

- fix "onDestroy" event for iOS [#4](https://github.com/dart-flitter/flutter_webview_plugin/issues/4)
- fix fullscreen mode for iOS [#5](https://github.com/dart-flitter/flutter_webview_plugin/issues/5)

# 0.0.4

- IOS implementation
- Update to last version of Flutter

# 0.0.3

- Documentation

# 0.0.2

- Initial version for Android
