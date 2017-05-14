#import "FlutterWebviewPlugin.h"

static NSString *const CHANNEL_NAME = @"flutter_webview_plugin";

@implementation FlutterWebviewPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
   FlutterMethodChannel *channel =
        [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME binaryMessenger:registrar.messenger];
   [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
     NSString *method = [call method];
     NSDictionary *arguments = [call arguments];

     result(FlutterMethodNotImplemented);
   }];
}

@end
