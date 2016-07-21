//
//  RSMedia.m
//  VideoAe
//
//  Created by 管伟东 on 16/4/5.
//  Copyright © 2016年 rootsport Inc. All rights reserved.
//

#import "RSChunk.h"

@implementation RSChunk
- (instancetype)initWithALAssetUrl:(NSURL *)url
{
    self = [super init];
    if(!self)return nil;
    self.video = [[RSVideoChannel alloc]initWithALAssertUrl:url];
    self.audio = [[RSAudioChannel alloc]initWithALAssertUrl:url];
    return self;
}
- (instancetype)initWithVideo:(RSVideoChannel *)video withAudio:(RSAudioChannel *)audio
{
    self = [super init];
    if(!self)return nil;
    self.video = video;
    self.audio = audio;
    return self;
}

- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super init];
    if(!self)return nil;
    self.video = [[RSVideoChannel alloc]initWithMediaPath:urlString];
    self.audio = [[RSAudioChannel alloc]initWithMediaPath:urlString];
    return self;
}
- (CMTime)duration
{
    return self.video.mediaDuration;
}
- (CGSize)videoFrameSize
{
    return [self.video natureSize];
}

@end
