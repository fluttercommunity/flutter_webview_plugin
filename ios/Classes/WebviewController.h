//
//  WebviewController.h
//  Pods
//
//  Created by Toufik Zitouni on 6/17/17.
//
//

#import <UIKit/UIKit.h>

@interface WebviewController : UIViewController
- (instancetype)initWithUrl:(NSString *)url withJavascript:(NSNumber *)withJavascript clearCache:(NSNumber *)clearCache clearCookes:(NSNumber *)clearCookies fullScreen:(NSNumber *)fullScreen;
@end
