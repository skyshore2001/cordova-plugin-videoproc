//
//  RSExportSession.m
//  FirstPhase
//
//  Created by 管伟东 on 16/3/21.
//  Copyright © 2016年 rootsports Inc. All rights reserved.
//

#import "RSExportSession.h"
@interface RSExportSession()
@property (nonatomic ,strong) AVAsset *              avAsset                   ;
@property (nonatomic ,strong) AVMutableVideoComposition * videoComposition;
@property (nonatomic ,strong) AVAssetExportSession * exportSession             ;
@property (nonatomic ,strong) NSURL   *              outPutUrl                 ;
@property (nonatomic ,strong) NSString *            presetName  ;
@end

@implementation RSExportSession
- (instancetype)initWithAVAssert:(AVAsset *)assert withOutPutURL:(NSURL *)fileUrl  withVideoComposition:(AVMutableVideoComposition *)videoComposition withAudioMix:(AVAudioMix *)audioMix
{
    self = [super init];
    if(!self)return nil;
    self.avAsset = assert;
    [self.exportSession presetName]; 
    self.videoComposition = videoComposition;
    self.outPutUrl = fileUrl;
    self.audioMix = audioMix;
    [self _setDefaultConfig];
    return self;
}

- (void)_setDefaultConfig
{
    self.videoQuality = RSVideoHighestQuality;
    self.outputFileType = AVFileTypeMPEG4;
    self.presetName =AVAssetExportPresetHighestQuality;
}

- (void)doExportWithProcess:(ExporterProcessBlock)processcb  withSuccess:(ExporterSuccessBlock )successCb withFaild:(ExporterFaildBlock)faildCb
{
    self.exportPorcessBlock = [processcb copy];
    self.exportSession = [AVAssetExportSession exportSessionWithAsset:self.avAsset presetName:self.presetName];
    self.exportSession.outputFileType = self.outputFileType;
    self.exportSession.outputURL = self.outPutUrl;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.videoComposition = self.videoComposition;
    __block NSTimer * timer  = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateExportProgress:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    __weak RSExportSession * wself = self;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (wself.exportSession.status == AVAssetExportSessionStatusCompleted) {
                BlockCallWithOneArg(successCb, wself.exportSession);
                [timer invalidate];
                timer = nil;
            }
            else{
                BlockCallWithOneArg(faildCb, wself.exportSession.error);
                [timer invalidate];
                timer = nil;
            }
        });
        
    }];

}
- (void)updateExportProgress:(AVAssetExportSession*)exportSession
{
    if (self.exportPorcessBlock) {
        self.exportPorcessBlock(self.exportSession.progress);
    }
}
- (void)cancleExport
{
    [self.exportSession cancelExport];
}
@end
