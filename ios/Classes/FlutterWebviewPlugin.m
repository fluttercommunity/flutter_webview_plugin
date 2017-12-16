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
            [self initWebView:call];
        else
            [self launch:call];
        result(nil);
    } else if ([@"close" isEqualToString:call.method]) {
        [self closeWebView];
        result(nil);
    } else if ([@"eval" isEqualToString:call.method]) {
        result([self evalJavascript:call]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initWebView:(FlutterMethodCall*)call {
    // NSNumber *withJavascript = call.arguments[@"withJavascript"];
    NSNumber *clearCache = call.arguments[@"clearCache"];
    NSNumber *clearCookies = call.arguments[@"clearCookies"];
    NSNumber *hidden = call.arguments[@"hidden"];
    NSDictionary *rect = call.arguments[@"rect"];
    _enableAppScheme = call.arguments[@"enableAppScheme"];
    NSString *userAgent = call.arguments[@"userAgent"];
    
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
        rc = CGRectMake([[rect valueForKey:@"left"] doubleValue],
                        [[rect valueForKey:@"top"] doubleValue],
                        [[rect valueForKey:@"width"] doubleValue],
                        [[rect valueForKey:@"height"] doubleValue]);
    } else {
        // TODO: create top NavigatorController and push
        rc = self.viewController.view.bounds;
    }
    
    self.webview = [[UIWebView alloc] initWithFrame:rc];
    self.webview.delegate = self;
    
    if (hidden != (id)[NSNull null] && [hidden boolValue])
        self.webview.hidden = YES;
    [self.viewController.view addSubview:self.webview];
    
    [self launch:call];
}

- (void)launch:(FlutterMethodCall*)call {
    NSString *url = call.arguments[@"url"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webview loadRequest:request];
}

- (NSString *)evalJavascript:(FlutterMethodCall*)call {
    NSString *code = call.arguments[@"code"];
    
    NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:code];
    return result;
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
    [channel invokeMethod:@"onState" arguments:@{@"type": @"startLoad"}];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [channel invokeMethod:@"onState" arguments:@{@"type": @"finishLoad"}];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    id data = [FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code]
                                  message:error.localizedDescription
                                  details:error.localizedFailureReason];
    [channel invokeMethod:@"onError" arguments:data];
}

#pragma mark -- WkWebView Delegate
@end
