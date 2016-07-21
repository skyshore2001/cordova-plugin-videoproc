//
//  RSVideo.h
//  FirstPhase
//
//  Created by 管伟东 on 16/3/16.
//  Copyright © 2016年 rootsports Inc. All rights reserved.
//

#import "RSBaseMedia.h"
#import <AVFoundation/AVFoundation.h>
typedef void (^GenImageSuccess)(NSArray*imageArray);
typedef void (^GenImageFaild)(NSError * error);


@interface RSVideoChannel : RSBaseMedia
/**
 *  视频轨道 ,返回第一个
 */
@property (nonatomic ,retain) AVAssetTrack * videoTrack ;
/**
 *  帧率
 */
@property (nonatomic ,assign) CGFloat        frameRate  ;
/**
 *  分辨率
 */
@property (nonatomic ,assign) CGSize     natureSize;

/**
 *  获取某个时间点的图片
 *
 *  @param atTime    时间点 CMTimeMake(帧数,帧率)
 *  @param imageSize 生成图片的大小
 *
 *  @return 生成的图片
 */

- (UIImage *)genImageAtTime:(CMTime)atTime withSize:(CGSize)imageSize;
/**
 *  获取时间数组的图片数组
 *
 *  @param atTimes   时间点数组 数组内容为CMTime 的NSValue
 *  @param imageSize 图片的尺寸
 *  @param success   图片数组获取成功的block (imageArray<UIImage> ,返回图片数组)
 *  @param faild     图片数组获取失败的block (error ,返回Error)
 */

- (void)genimagesAtTimes:(NSArray *)atTimes withSize:(CGSize)imageSize Success:(GenImageSuccess)success Faild:(GenImageFaild)faild;

/**
 *  获取时间数组的图片数组
 *
 *  @param atTimes    时间点数组 数组内容为CMTime 的NSValue
 *  @param truneCount 截断图片个数
 *  @param imageSize  图片的尺寸
 *  @param success    图片数组获取成功的block (imageArray<UIImage> ,返回图片数组图片个数以截断个数为准)
 *  @param faild      图片数组获取失败的block (error ,返回Error)
 */

- (void)genimagesAtTimes:(NSArray *)atTimes withTrune:(NSInteger)truneCount withSize:(CGSize)imageSize Success:(GenImageSuccess)success Faild:(GenImageFaild)faild;
@end
