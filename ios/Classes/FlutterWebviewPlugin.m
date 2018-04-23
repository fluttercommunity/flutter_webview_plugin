#import "FlutterWebviewPlugin.h"

static NSString *const CHANNEL_NAME = @"flutter_webview_plugin";

// UIWebViewDelegate
@interface FlutterWebviewPlugin() <WKNavigationDelegate, UIScrollViewDelegate> {
    BOOL _enableAppScheme;
    BOOL _enableZoom;
    NSMutableDictionary *_additionalHttpHeaders;
}
@end

@implementation FlutterWebviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    channel = [FlutterMethodChannel
               methodChannelWithName:CHANNEL_NAME
               binaryMessenger:[registrar messenger]];
    
    UIViewController *viewController = (UIViewController *)registrar.messenger;
    FlutterWebviewPlugin* instance = [[FlutterWebviewPlugin alloc] initWithViewController:viewController];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        _additionalHttpHeaders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"launch" isEqualToString:call.method]) {
        if (!self.webview)
            [self initWebview:call];
        else
            [self navigate:call];
        result(nil);
    } else if ([@"close" isEqualToString:call.method]) {
        [self closeWebView];
        result(nil);
    } else if ([@"eval" isEqualToString:call.method]) {
        [self evalJavascript:call completionHandler:^(NSString * response) {
            result(response);
        }];
    } else if ([@"resize" isEqualToString:call.method]) {
        [self resize:call];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initWebview:(FlutterMethodCall*)call {
    NSNumber *clearCache = call.arguments[@"clearCache"];
    NSNumber *clearCookies = call.arguments[@"clearCookies"];
    NSNumber *hidden = call.arguments[@"hidden"];
    NSDictionary *rect = call.arguments[@"rect"];
    _enableAppScheme = call.arguments[@"enableAppScheme"];
    _additionalHttpHeaders = call.arguments[@"additionalHttpHeaders"];
    NSString *userAgent = call.arguments[@"userAgent"];
    NSNumber *withZoom = call.arguments[@"withZoom"];
    
    if (clearCache != (id)[NSNull null] && [clearCache boolValue]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
    
    if (clearCookies != (id)[NSNull null] && [clearCookies boolValue]) {
        [[NSURLSession sharedSession] resetWithCompletionHandler:^{
        }];
    }
    
    if (userAgent != (id)[NSNull null]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": userAgent}];
    }
    
    CGRect rc;
    if (rect != nil) {
        rc = [self parseRect:rect];
    } else {
        rc = self.viewController.view.bounds;
    }
    
    self.webview = [[WKWebView alloc] initWithFrame:rc];
    self.webview.navigationDelegate = self;
    self.webview.scrollView.delegate = self;
    self.webview.hidden = [hidden boolValue];

    _enableZoom = [withZoom boolValue];

    [self.viewController.view addSubview:self.webview];

    [self navigate:call];
}

- (CGRect)parseRect:(NSDictionary *)rect {
    return CGRectMake([[rect valueForKey:@"left"] doubleValue],
                      [[rect valueForKey:@"top"] doubleValue],
                      [[rect valueForKey:@"width"] doubleValue],
                      [[rect valueForKey:@"height"] doubleValue]);
}

- (void)navigate:(FlutterMethodCall*)call {
    if (self.webview != nil) {
        NSString *url = call.arguments[@"url"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        for (NSString *key in _additionalHttpHeaders) {
            [request setValue:_additionalHttpHeaders[key] forHTTPHeaderField:key];
        }
        [self.webview loadRequest:request];
    }
}

- (void)evalJavascript:(FlutterMethodCall*)call
     completionHandler:(void (^_Nullable)(NSString * response))completionHandler {
    if (self.webview != nil) {
        NSString *code = call.arguments[@"code"];
        [self.webview evaluateJavaScript:code
                       completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            completionHandler([NSString stringWithFormat:@"%@", response]);
        }];
    } else {
        completionHandler(nil);
    }
}

- (void)resize:(FlutterMethodCall*)call {
    if (self.webview != nil) {
        NSDictionary *rect = call.arguments[@"rect"];
        CGRect rc = [self parseRect:rect];
        self.webview.frame = rc;
    }
}

- (void)closeWebView {
    if (self.webview != nil) {
        [self.webview stopLoading];
        [self.webview removeFromSuperview];
        self.webview.navigationDelegate = nil;
        self.webview = nil;

        // manually trigger onDestroy
        [channel invokeMethod:@"onDestroy" arguments:nil];
    }
}

#pragma mark -- WkWebView Delegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    id data = @{@"url": navigationAction.request.URL.absoluteString,
                @"type": @"shouldStart",
                @"navigationType": [NSNumber numberWithInt:navigationAction.navigationType]};
    [channel invokeMethod:@"onState" arguments:data];

    if (navigationAction.navigationType == WKNavigationTypeBackForward) {
        [channel invokeMethod:@"onBackPressed" arguments:nil];
    } else {
        id data = @{@"url": navigationAction.request.URL.absoluteString};
        [channel invokeMethod:@"onUrlChanged" arguments:data];
    }
    if (_enableAppScheme ||
        ([webView.URL.scheme isEqualToString:@"http"] ||
         [webView.URL.scheme isEqualToString:@"https"] ||
         [webView.URL.scheme isEqualToString:@"about"])) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [channel invokeMethod:@"onState" arguments:@{@"type": @"startLoad", @"url": webView.URL.absoluteString}];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [channel invokeMethod:@"onState" arguments:@{@"type": @"finishLoad", @"url": webView.URL.absoluteString}];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    id data = [FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code]
                                  message:error.localizedDescription
                                  details:error.localizedFailureReason];
    [channel invokeMethod:@"onError" arguments:data];
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.pinchGestureRecognizer.isEnabled != _enableZoom) {
        scrollView.pinchGestureRecognizer.enabled = _enableZoom;
    }
}

@end
