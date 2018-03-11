#import "FlutterWebviewPlugin.h"

static NSString *const CHANNEL_NAME = @"flutter_webview_plugin";

// UIWebViewDelegate
@interface FlutterWebviewPlugin() <UIWebViewDelegate> {
    BOOL _enableAppScheme;
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
        result([self evalJavascript:call]);
    } else if ([@"resize" isEqualToString:call.method]) {
        [self resize:call];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initWebview:(FlutterMethodCall*)call {
    // NSNumber *withJavascript = call.arguments[@"withJavascript"];
    NSNumber *clearCache = call.arguments[@"clearCache"];
    NSNumber *clearCookies = call.arguments[@"clearCookies"];
    NSNumber *hidden = call.arguments[@"hidden"];
    NSDictionary *rect = call.arguments[@"rect"];
    _enableAppScheme = call.arguments[@"enableAppScheme"];
    NSString *userAgent = call.arguments[@"userAgent"];
    NSNumber *withZoom = call.arguments[@"withZoom"];
    
    //
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
    
    self.webview = [[UIWebView alloc] initWithFrame:rc];
    self.webview.delegate = self;
    
    if (withZoom != (id)[NSNull null] && [withZoom boolValue]) {
        self.webview.scalesPageToFit = YES;
    }
    
    if (hidden != (id)[NSNull null] && [hidden boolValue]) {
        self.webview.hidden = YES;
    }
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
    NSString *url = call.arguments[@"url"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webview loadRequest:request];
}

- (NSString *)evalJavascript:(FlutterMethodCall*)call {
    NSString *code = call.arguments[@"code"];
    
    NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:code];
    return result;
}

- (void)resize:(FlutterMethodCall*)call {
    NSDictionary *rect = call.arguments[@"rect"];
    CGRect rc = [self parseRect:rect];
    self.webview.frame = rc;
}

- (void)closeWebView {
    [self.webview stopLoading];
    [self.webview removeFromSuperview];
    self.webview.delegate = nil;
    self.webview = nil;
    
    // manually trigger onDestroy
    [channel invokeMethod:@"onDestroy" arguments:nil];
}


#pragma mark -- WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    id data = @{@"url": request.URL.absoluteString,
                @"type": @"shouldStart",
                @"navigationType": [NSNumber numberWithInt:navigationType]};
    [channel invokeMethod:@"onState" arguments:data];
    
    if (navigationType == UIWebViewNavigationTypeBackForward)
        [channel invokeMethod:@"onBackPressed" arguments:nil];
    else {
        id data = @{@"url": request.URL.absoluteString};
        [channel invokeMethod:@"onUrlChanged" arguments:data];
    }
    
    if (_enableAppScheme)
        return YES;

    // disable some scheme
    return [request.URL.scheme isEqualToString:@"http"] ||
            [request.URL.scheme isEqualToString:@"https"] ||
            [request.URL.scheme isEqualToString:@"about"];
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    [channel invokeMethod:@"onState" arguments:@{@"type": @"startLoad", @"url": webView.request.URL.absoluteString}];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [channel invokeMethod:@"onState" arguments:@{@"type": @"finishLoad", @"url": webView.request.URL.absoluteString}];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    id data = [FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code]
                                  message:error.localizedDescription
                                  details:error.localizedFailureReason];
    [channel invokeMethod:@"onError" arguments:data];
}

#pragma mark -- WkWebView Delegate
@end
