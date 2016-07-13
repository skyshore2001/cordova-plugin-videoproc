#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface CDVVideoProc : CDVPlugin
{}

+ (NSString*)cordovaVersion;

- (void)compose:(CDVInvokedUrlCommand*)command;

@end
