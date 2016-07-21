#include <sys/types.h>
#include <sys/sysctl.h>
#import <Cordova/CDV.h>
#import "CDVVideoProc.h"
#import "VideoProc.h"
#ifndef GuanT_Test
//#define GuanT_Test
#endif
@implementation CDVVideoProc

- (void)compose:(CDVInvokedUrlCommand*)command
{
	NSString *videoFile = [command.arguments objectAtIndex:0];
    NSDictionary *opt = [command.arguments objectAtIndex:1];
    
    if (videoFile != nil && [videoFile length] == 0) {
        NSString *errstr = @"找不到文件";
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errstr];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
#ifdef GuanT_Test
    videoFile = [[NSBundle mainBundle]pathForResource:@"2" ofType:@"MOV"];
    
    NSString * optdes = [[NSBundle mainBundle]pathForResource:@"config" ofType:@"json"];
    NSData * data = [NSData dataWithContentsOfFile:optdes];
    opt = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
#endif

    __weak CDVVideoProc * wself= self;
    [self.commandDelegate runInBackground:^{
        VideoProc * v = [[VideoProc alloc]init];
        [v compose:videoFile withConfig:opt withSuccess:^(NSURL * fileUrl) {

            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[fileUrl absoluteString]];
            [wself.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } withFaild:^(NSString *errorString) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorString];
            [wself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }];
}

@end
