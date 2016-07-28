//
//  RSVideoCompositior.m
//  saber
//
//  Created by 管伟东 on 15/11/20.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import "RSVideoCompositior.h"
#import <CoreVideo/CoreVideo.h>  
#import "RSVideoCompositionInstruction.h"
#import "RenderFilter.h"
@interface RSVideoCompositior()
{
    CVPixelBufferRef dstPixelBuffer;
}
@property (nonatomic, strong) dispatch_queue_t renderingQueue;
@property (nonatomic, strong) dispatch_queue_t renderContextQueue;
@property (nonatomic, strong) AVVideoCompositionRenderContext *renderContext;
@property (nonatomic, assign) CVPixelBufferRef previousBuffer;
@property (nonatomic, strong) RSVideoCompositionInstruction *currentInstruction;
@property (nonatomic, assign) BOOL shouldCancelAllRequests;
@property (nonatomic, assign) BOOL renderContextDidChange;
@property (nonatomic ,assign) CMTime compositionDuration;
@property (nonatomic ,assign) NSInteger totalFrameIndex;
@property (nonatomic ,retain)RenderFilter * renderFilter ;
@property (nonatomic ,retain)NSArray * chunks ;
@property (nonatomic ,assign)BOOL isBackGround;
@end
static NSMutableArray * renderChunks = nil;
static UIImage * tailImage = nil;
@implementation RSVideoCompositior
- (instancetype)init
{
    self = [super init];
    if (self) {
        _renderingQueue = dispatch_queue_create("rs.rsvideocompositior.renderingqueue", DISPATCH_QUEUE_SERIAL);
        _renderContextQueue = dispatch_queue_create("rs.rsvideocompositior.rendercontextqueue", DISPATCH_QUEUE_SERIAL);
        _previousBuffer = nil;
        _renderContextDidChange = NO;
        self.renderFilter = [[RenderFilter alloc]init];
        [self _registerNotification];
    }
    return self;
}
- (void)_registerNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_handleToBack) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_handleComeFromeBack) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)_handleToBack
{
    self.isBackGround = YES;
}
- (void)_handleComeFromeBack
{
    self.isBackGround = NO;
}


- (void)dealloc {
    if(dstPixelBuffer!=NULL)
    {
        CFRelease(dstPixelBuffer);
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (NSDictionary *)sourcePixelBufferAttributes
{
    return @{(NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}
- (NSDictionary *)requiredPixelBufferAttributesForRenderContext
{
    return @{(NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}
- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext
{
    dispatch_sync(_renderContextQueue, ^() {
        _renderContext = newRenderContext;
        _renderContextDidChange = YES;
    });
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)asyncVideoCompositionRequest {
    @autoreleasepool {
        dispatch_async(_renderingQueue,^() {
            if (_shouldCancelAllRequests) {
                NSLog(@"finishCancle");
                [asyncVideoCompositionRequest finishCancelledRequest];
            } else {
                NSError *err = nil;
                CVPixelBufferRef resultPixels = [self newRenderedPixelBufferForRequest:asyncVideoCompositionRequest error:&err];
                if (resultPixels) {
                    [asyncVideoCompositionRequest finishWithComposedVideoFrame:resultPixels];
                    if(dstPixelBuffer!=NULL){
                        CVPixelBufferRelease(dstPixelBuffer);
                        dstPixelBuffer =NULL;
                    }
                } else {
                    NSLog(@"finsh withError err = %@",err);
                    NSLog(@"current render Time = %f",CMTimeGetSeconds(asyncVideoCompositionRequest.compositionTime));
                    [asyncVideoCompositionRequest finishWithError:err];
                }
            }
        });
    }
}

- (void)cancelAllPendingVideoCompositionRequests
{
    _shouldCancelAllRequests = YES;
    dispatch_barrier_async(_renderingQueue, ^() {
        _shouldCancelAllRequests = NO;
    });
}
- (CVPixelBufferRef)newRenderedPixelBufferForRequest:(AVAsynchronousVideoCompositionRequest *)request error:(NSError **)error {
    if (_renderContextDidChange&&[request.videoCompositionInstruction isKindOfClass:[AVMutableVideoCompositionInstruction class]])
    {
        CMPersistentTrackID ids = [[request.sourceTrackIDs firstObject]intValue];
        CVPixelBufferRef  sourcePixelBufferRef =  [request sourceFrameByTrackID:ids];
        return CVPixelBufferRetain(sourcePixelBufferRef);
    }
    if (_renderContextDidChange || self.currentInstruction != request.videoCompositionInstruction) {
        self.currentInstruction = (RSVideoCompositionInstruction *)request.videoCompositionInstruction;
        _renderContextDidChange = YES;
    }
    CMTimeRange timeRange =  request.videoCompositionInstruction.timeRange;
    
    _compositionDuration =  timeRange.duration;
    self.renderFilter.videoCompositionDuration = _compositionDuration;
    CMPersistentTrackID foregroundTrackID = [(RSVideoCompositionInstruction *)request.videoCompositionInstruction foregroundTrackID];
    NSArray * configItem = [(RSVideoCompositionInstruction *)request.videoCompositionInstruction configItems];
    
    CVPixelBufferRef foregroundSourceBuffer = [request sourceFrameByTrackID:foregroundTrackID];
    NSLog(@"totalTime = %f  , request time= %f",CMTimeGetSeconds(_compositionDuration),CMTimeGetSeconds(request.compositionTime));
    if (foregroundSourceBuffer) {
        dstPixelBuffer = [_renderContext newPixelBuffer];
        if (self.isBackGround) {
            if(foregroundSourceBuffer)
            {
                return foregroundSourceBuffer;
            }else
            {
                return dstPixelBuffer;
            }
        }
        [self.renderFilter renderPixelBuffer:dstPixelBuffer usingForegroundSourceBuffer:foregroundSourceBuffer withComposition:request.compositionTime winthConfigItem:configItem];
        return dstPixelBuffer;
    }else
    {
        if(foregroundSourceBuffer){
            return foregroundSourceBuffer;
        }else{
            dstPixelBuffer = [_renderContext newPixelBuffer];
            return dstPixelBuffer   ;
        }
    }
    
}

@end
