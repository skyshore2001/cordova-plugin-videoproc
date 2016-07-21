//
//  RSVideo.m
//  FirstPhase
//
//  Created by 管伟东 on 16/3/16.
//  Copyright © 2016年 rootsports Inc. All rights reserved.
//

#import "RSVideoChannel.h"
@implementation RSVideoChannel

- (AVAssetTrack *)videoTrack
{
    return [[self mediaAsset]tracksWithMediaType:AVMediaTypeVideo][0];
}

- (kMediaType)type
{
    return kMediaType_Video;
}

- (CGFloat)frameRate
{
    return [[self videoTrack]nominalFrameRate];
}

- (CGSize)natureSize
{
    return [[self videoTrack]naturalSize];
}

- (UIImage *)genImageAtTime:(CMTime)atTime withSize:(CGSize)imageSize
{
    if(![self mediaUrlAsset])return nil;
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:[self mediaUrlAsset]];
    generator.appliesPreferredTrackTransform = YES;
    
    generator.requestedTimeToleranceBefore = CMTimeMake(1, [self frameRate]);
    generator.requestedTimeToleranceAfter = CMTimeMake(1, [self frameRate]);
    generator.maximumSize = imageSize;
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:atTime actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage: img];
    return image;
}

- (void)genimagesAtTimes:(NSArray *)atTimes withTrune:(NSInteger)truneCount withSize:(CGSize)imageSize Success:(GenImageSuccess)success Faild:(GenImageFaild)faild
{
    if(![self mediaUrlAsset])return ;
    if(truneCount == -1)truneCount = atTimes.count;
    NSMutableArray * images = @[].mutableCopy;
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:[self mediaUrlAsset]];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = CMTimeMake([self frameRate], [self frameRate]);
    generator.requestedTimeToleranceAfter = CMTimeMake([self frameRate], [self frameRate]);
    generator.maximumSize = imageSize;
    [generator generateCGImagesAsynchronouslyForTimes:atTimes completionHandler:^(CMTime requestedTime, CGImageRef   image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *  error)
    {
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage  * img = [UIImage imageWithCGImage:image];
            [images addObject:img];
            if (images.count == truneCount) {
                BlockCallWithOneArg(success, images);
            }
        }else
        {
            BlockCallWithOneArg(success, images);
        }
    }];
}

- (void)genimagesAtTimes:(NSArray *)atTimes withSize:(CGSize)imageSize Success:(GenImageSuccess)success Faild:(GenImageFaild)faild
{
    [self genimagesAtTimes:atTimes withTrune:-1 withSize:imageSize Success:success Faild:faild];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@,\n type: video ,\n path: %@ ,\nframeRate: %f,\n size %.2f x %.2f,\nduration: %.2f\n",self.mediaName,self.mediaPath ,self.frameRate ,self.natureSize.width ,self.natureSize.height ,CMTimeGetSeconds([self mediaDuration])];
}
@end
