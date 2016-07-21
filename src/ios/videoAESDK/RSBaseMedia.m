//
//  RSBaseMedia.m
//  FirstPhase
//
//  Created by 管伟东 on 16/3/16.
//  Copyright © 2016年 rootsports Inc. All rights reserved.
//

#import "RSBaseMedia.h"

@implementation RSBaseMedia

- (instancetype)initWithMediaPath:(NSString *)mediapath withName:(NSString *)mediaName
{
    self = [super init];
    if(!self)return nil;
    _mediaName = mediaName;
    _mediaPath = mediapath ;
    _mediaAsset = [AVAsset assetWithURL:[self mediaUrl]];
    _mediaUrlAsset = [AVURLAsset assetWithURL:[self mediaUrl]];
    BOOL ret = [self _loadAssetPropertiesSynchronously:_mediaAsset];
    if (_mediaPath.length==0||!ret) {
        NSLog(@"file  %@  not Exist!! ",_mediaPath);
        return nil;
    }
    return self;
}
- (instancetype)initWithMediaPath:(NSString *)mediapath
{
    return [self initWithMediaPath:mediapath withName:nil];
}

- (instancetype)initWithURL:(NSURL *)videoUrl
{
    self = [super init];
    if(!self)return nil;
    _mediaPath = [videoUrl relativePath];
    
    return [self initWithMediaPath:_mediaPath withName:nil];
}
- (instancetype)initWithALAssertUrl:(NSURL *)alassetUrl
{
    self = [super init];
    if(!self)return nil;
    _mediaName = [alassetUrl relativePath];
    _mediaPath = [alassetUrl absoluteString] ;
    _mediaAsset = [AVAsset assetWithURL:alassetUrl];
    _mediaUrlAsset = [AVURLAsset assetWithURL:alassetUrl];
    BOOL ret = [self _loadAssetPropertiesSynchronously:_mediaAsset];
    if (_mediaPath.length==0||!ret) {
        NSLog(@"file  %@  not Exist!! ",_mediaPath);
        return nil;
    }
    return self;
}

- (instancetype)initWithALAsset:(AVAsset *)asset
{
    self = [super init];
    if(!self)return nil;
    _mediaAsset = asset;
    _mediaUrlAsset = (AVURLAsset *)asset;
    BOOL ret = [self _loadAssetPropertiesSynchronously:asset];
    if(!ret){
        NSLog(@"asset  %@  load Faild!! ",_mediaPath);
        return nil;
    }
    return self;
}

- (BOOL)_loadAssetPropertiesSynchronously:(AVAsset *)asset {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL isLoaded = NO;
    NSArray *values = @[@"duration", @"tracks", @"composable"];
    [asset loadValuesAsynchronouslyForKeys:values completionHandler:^{
        [values enumerateObjectsUsingBlock:^(NSString *valueStr, NSUInteger idx, BOOL *stop) {
            isLoaded = YES;
            if ([asset statusOfValueForKey:valueStr error:nil] == AVKeyValueStatusFailed) {
                isLoaded = NO;
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
            }
            
            dispatch_semaphore_signal(semaphore);
        }];
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 10.f * NSEC_PER_SEC));
    return isLoaded;
}

- (NSURL*)mediaUrl
{
    if (_mediaPath ==nil)
        return 0;
    return [NSURL fileURLWithPath:_mediaPath];
}

- (NSString *)mediaName
{
    return _mediaName;
}
- (NSString *)mediaPath
{
    return _mediaPath;
}

- (AVAsset *)mediaUrlAsset
{
    return _mediaUrlAsset ;
}
- (AVAsset *)mediaAsset
{
    return _mediaAsset;
}
- (kMediaType)type
{
    return kMediaType_unKnown;
}

- (CMTime)mediaDuration
{
    return [[self mediaUrlAsset]duration];
}
@end
