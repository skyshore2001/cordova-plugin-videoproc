//
//  VideoProc.h
//  HelloCordova
//
//  Created by 管伟东 on 16/7/14.
//
//

#import <Foundation/Foundation.h>
typedef void (^SuccessBlock)(NSURL * fileUrl);
typedef void (^FaildBlock)(NSString * errorString);
@interface VideoProc : NSObject

- (void)compose:(NSString *)videoFile withConfig:(NSDictionary *)configInfo withSuccess:(SuccessBlock)successcb withFaild:(FaildBlock)faildcb;
/**
 *  获取缩略图
 *
 *  @return 获取缩略图
 */
- (UIImage *)getThumbnail;
/**
 *  取消生成视频
 */
- (void)cancleExport;

@end
