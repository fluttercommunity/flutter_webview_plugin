//
//  WebviewController.m
//  Pods
//
//  Created by Toufik Zitouni on 6/17/17.
//
//

#import "WebviewController.h"
#import "FlutterWebviewPlugin.h"

@interface WebviewController ()
@property (nonatomic, retain) NSString *url;
@property NSNumber *withJavascript;
@property NSNumber *clearCache;
@property NSNumber *clearCookies;
@end

@implementation WebviewController

- (instancetype)initWithUrl:(NSString *)url withJavascript:(NSNumber *)withJavascript clearCache:(NSNumber *)clearCache clearCookes:(NSNumber *)clearCookies {
    self = [super init];
    if (self) {
        self.url = url;
        self.withJavascript = withJavascript;
        self.clearCache = clearCache;
        self.clearCookies = clearCookies;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    
    if ([self.clearCache boolValue]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
    
    if ([self.clearCookies boolValue]) {
        [[NSURLSession sharedSession] resetWithCompletionHandler:^{
            
        }];
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:webView];
}

- (IBAction)backButtonPressed:(id)sender {
    [channel invokeMethod:@"onBackPressed" arguments:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
