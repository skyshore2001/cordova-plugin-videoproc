//
//  VideoProc.m
//  HelloCordova
//
//  Created by 管伟东 on 16/7/14.
//
//

#import "VideoProc.h"
#import "ConfigItem.h"
#import "RSVideoChannel.h"
#import "RSAudioChannel.h"
#import "RSChunk.h"
#import "RSExportSession.h"
#import "RSVideoCompositionInstruction.h"
#import "AVAssetTrack+Transform.h"
#import "RSVideoCompositior.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <objc/runtime.h>
static char videoTrackId ;
@interface VideoProc()
@property (nonatomic ,strong)NSString * videoFile ;
@property (nonatomic ,strong)AVMutableComposition * mixComposition ;
@property (nonatomic ,strong)RSChunk  * mainVideoChunk ;
@property (nonatomic ,strong)NSArray  * configInfoArray;
@property (nonatomic ,strong)RSExportSession * exportSession;
@property (nonatomic ,strong)AVMutableVideoComposition * videoComposition;
@property (nonatomic ,strong)ALAssetsLibrary * library ;
@property (nonatomic ,assign)BOOL               replaceOrignAudio;
@property (nonatomic ,assign)CGFloat            videoVolume;
@property (nonatomic ,strong)AVMutableAudioMix * audioMix;
@property (nonatomic ,strong)NSMutableArray * audioArray ;
@end
@implementation VideoProc
- (instancetype)init
{
    self = [super init];
    if(!self)return nil;
    self.replaceOrignAudio = NO;
#ifdef kExportToLibrary
    self.library = [[ALAssetsLibrary alloc]init];
#endif
    return self;
}
- (void)compose:(NSString *)videoFile withConfig:(NSDictionary *)configInfo withSuccess:(SuccessBlock)successcb withFaild:(FaildBlock)faildcb
{
    self.configInfoArray  = [self _parseJsonString:configInfo];
    if (self.configInfoArray.count==0) {
        NSLog(@"parse json String error");
        return;
    }
    self.videoFile = videoFile;
    self.mainVideoChunk = [[RSChunk alloc]initWithUrlString:videoFile];
    [self _mixVideoAndAudioNeedMix:!_replaceOrignAudio];
    [self _doexportSuccess:^(NSURL  *fileUrl) {

#ifdef kExportToLibrary 
    [self.library saveVideo:fileUrl toAlbum:@"导出视频" completion:^(NSURL *assetURL, NSError *error) {
           UIAlertView * alter = [[UIAlertView alloc]initWithTitle:@"title" message:@"exportSuccess" delegate:nil cancelButtonTitle:@"cacle" otherButtonTitles:nil, nil];
           [alter show];
        } failure:^(NSError *error) {
            UIAlertView * alter = [[UIAlertView alloc]initWithTitle:@"title" message:@"exportFaild" delegate:nil cancelButtonTitle:@"cacle" otherButtonTitles:nil, nil];
            [alter show];
 
        }];
#endif
        if (successcb) {
            successcb(fileUrl);
        }
    } withFaild:^(NSString *errorString) {
        if (faildcb) {
            faildcb(errorString); 
        }
    }];
}

- (NSArray *)_parseJsonString:(NSDictionary *)config
{
    NSMutableArray * configInfo = [NSMutableArray array];
    if ([config objectForKey:@"replaceAudio"]==nil) {
        _replaceOrignAudio = false;
    }else
    {
        _replaceOrignAudio = [[config objectForKey:@"replaceAudio"]boolValue];
    }
    if ([config objectForKey:@"videoVolume"]==nil) {
        _videoVolume = 1.0 ;
    }else
    {
        _videoVolume = [[config objectForKey:@"videoVolume"]floatValue]; 
    }
    if (_videoVolume>1) {
        _videoVolume = 1.0;
    }
    if (_videoVolume<0) {
        _videoVolume = 0;
    }
    NSArray * items = [config objectForKey:@"items"];
    for (NSDictionary * item in items) {
        ConfigItem * configItem = [[ConfigItem alloc]init];
        configItem.type = [self _returnType:[item objectForKey:@"type"]];
        configItem.value=[item objectForKey:@"value"];
        configItem.frome = [[item objectForKey:@"from"]integerValue];
        configItem.to = [[item objectForKey:@"to"]integerValue];
        configItem.pointX = [[item objectForKey:@"x"]integerValue];
        configItem.pointY = [[item objectForKey:@"y"]integerValue];
        configItem.width = [[item objectForKey:@"width"]integerValue];
        configItem.height = [[item objectForKey:@"height"]integerValue];
        configItem.volume =[item objectForKey:@"volume"]?[[item objectForKey:@"volume"]floatValue]:1.0;
        [configInfo addObject:configItem];
    }
    return configInfo;
}


- (void)_mixVideoAndAudioNeedMix:(BOOL)needMix
{
    _audioArray = [NSMutableArray array];
    CGSize  tempNatureSize = [self.mixComposition naturalSize];
    self.mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack * videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.mainVideoChunk.duration) ofTrack:self.mainVideoChunk.video.videoTrack atTime:kCMTimeZero error:nil];
    if (needMix) {
        AVMutableCompositionTrack * orignAudioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [orignAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.mainVideoChunk.duration) ofTrack:self.mainVideoChunk.audio.audioTrack atTime:kCMTimeZero error:nil];
        AVMutableAudioMixInputParameters *videoParmaters= [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:orignAudioTrack];
        [videoParmaters setVolume:_videoVolume atTime:kCMTimeZero];
        [_audioArray addObject:videoParmaters];
    }
    for (ConfigItem *item in self.configInfoArray) {
        if (item.type == kMediaType_Audio) {
//            NSString * path = [[NSBundle mainBundle]pathForResource:@"1" ofType:@"mp3"];
//            RSAudioChannel * audioChannel = [[RSAudioChannel alloc]initWithMediaPath:path];
            RSAudioChannel * audioChannel = [[RSAudioChannel alloc]initWithMediaPath:item.value];
            AVMutableCompositionTrack * audioTrack  = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.mainVideoChunk.duration) ofTrack:audioChannel.audioTrack atTime:kCMTimeZero error:nil];
            AVMutableAudioMixInputParameters *videoParmaters= [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
            [videoParmaters setVolume:item.volume atTime:kCMTimeZero];
            [_audioArray addObject:videoParmaters];
        }
    }
#ifdef ImageAndText
   RSVideoCompositionInstruction * instruction = [[RSVideoCompositionInstruction alloc]initForegroundTrackID:self.mainVideoChunk.video.videoTrack.trackID forTimeRange:CMTimeRangeMake(kCMTimeZero, self.mixComposition.duration) withTransform:[self.mainVideoChunk.video.videoTrack properTransformForRenderSize:tempNatureSize]withConfig:self.configInfoArray];
#endif
    self.videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.mixComposition];
    self.videoComposition.frameDuration = CMTimeMake(1, 25);
    self.videoComposition.renderSize = [_mainVideoChunk videoFrameSize];
#ifdef ImageAndText
    self.videoComposition.instructions = @[instruction];
    self.videoComposition.customVideoCompositorClass = [RSVideoCompositior  class];
#endif 
    
}

- (void)_doexportSuccess:(SuccessBlock)scb withFaild:(FaildBlock)fcb;
{
    _audioMix = [AVMutableAudioMix audioMix];
    _audioMix.inputParameters = _audioArray;
    NSString * videoPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSAllDomainsMask, YES)[0];
    videoPath = [videoPath stringByAppendingPathComponent:@"video.mp4"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:videoPath])[fileManager removeItemAtPath:videoPath error:nil];
    NSURL * fileUrl = [NSURL fileURLWithPath:videoPath];
    self.exportSession = [[RSExportSession  alloc]initWithAVAssert:self.mixComposition
                                                     withOutPutURL:fileUrl
                                              withVideoComposition:self.videoComposition
                                                      withAudioMix:_audioMix];
//    self.exportSession.audioMix = _audioMix;
    [self.exportSession doExportWithProcess:^(CGFloat process) {
        NSLog(@"process = %f",process);
    } withSuccess:^(AVAssetExportSession *exportSession) {
        if (scb) {
            scb(exportSession.outputURL); 
        }
    } withFaild:^(NSError *exportError) {
        if (fcb) {
            fcb(exportError.localizedFailureReason);
        }
    }];
}


- (kMediaType)_returnType:(NSString *)typeStr
{
    if ([typeStr isEqualToString:@"video"]) {
        return kMediaType_Video;
    }else if([typeStr isEqualToString:@"audio"])
    {
        return kMediaType_Audio;
    }else if ([typeStr isEqualToString:@"image"])
    {
        return kMediaType_Picture;
    }else if([typeStr isEqualToString:@"text"])
    {
        return kMediaType_Text;
    }
    return kMediaType_unKnown;
}

- (UIImage *)_genImageAtTime:(CMTime)atTime withSize:(CGSize)imageSize
{
    AVAssetImageGenerator *generator         = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.mixComposition];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore   = CMTimeMake(25, 25);
    generator.requestedTimeToleranceAfter    = CMTimeMake(25, 25);
    generator.maximumSize                    = imageSize;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels ;
    NSError *error                           = nil;
    CGImageRef img                           = [generator copyCGImageAtTime:atTime actualTime:NULL error:&error];
    UIImage *image                           = [UIImage imageWithCGImage: img];
    return image;
}
- (UIImage *)getThumbnail
{
    return [self _genImageAtTime:CMTimeMake(25, 25) withSize:CGSizeMake(480,320)];
}

- (void)cancleExport
{
    [self.exportSession cancleExport];
}

@end
