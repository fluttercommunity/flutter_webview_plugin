#import <Flutter/Flutter.h>
#import "WebviewController.h"

static FlutterMethodChannel *channel;

@interface FlutterWebviewPlugin : NSObject<FlutterPlugin>
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) UIWebView *webview;
@end
