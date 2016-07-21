//
//  RSAudio.m
//  FirstPhase
//
//  Created by 管伟东 on 16/3/16.
//  Copyright © 2016年 rootsports Inc. All rights reserved.
//

#import "RSAudioChannel.h"

@implementation RSAudioChannel

- (kMediaType)type
{
    return kMediaType_Audio;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@ ,\ntype: audio ,\npath: %@ ,\nduration: %.2f\n",self.mediaName,self.mediaPath ,CMTimeGetSeconds(self.mediaDuration)];
}
- (AVAssetTrack *)audioTrack
{
    return [[self mediaAsset]tracksWithMediaType:AVMediaTypeAudio][0];
}

@end
