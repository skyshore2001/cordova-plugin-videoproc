//
//  RSExportSession.h
//  FirstPhase
//
//  Created by 管伟东 on 16/3/21.
//  Copyright © 2016年 rootsports Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Video_Const.h"
/**
 *  导出视频成功的block
 *
 *  @return exportSession 返回
 */
typedef void (^ExporterSuccessBlock)(AVAssetExportSession * exportSession);
/**
 *  导出进度的回调
 *
 *  @param process 导出进度
 */
typedef void (^ExporterProcessBlock)(CGFloat process);
/**
 *  导出视频失败的block
 *
 *  @return exportSession
 */
typedef void (^ExporterFaildBlock)(NSError * exportError);

@interface RSExportSession : NSObject
/**
 * 视频质量
 */
@property (nonatomic ,assign) RSVideoQuality videoQuality;
/**
 *  导出文件类型 如 mp4 , 3gp
 */
@property (nonatomic ,retain) NSString *  outputFileType;
/**
 *  设置混音
 */
@property (nonatomic ,retain)AVAudioMix * audioMix ;

@property (nonatomic ,copy)ExporterProcessBlock exportPorcessBlock; 
- (instancetype)initWithAVAssert:(AVAsset *)assert
                   withOutPutURL:(NSURL *)fileUrl
            withVideoComposition:(AVMutableVideoComposition *)videoComposition
                    withAudioMix:(AVAudioMix *)audioMix ;
/**
 *  导出视频
 *
 *  @param successCb 导出视频成功的回调
 *  @param faildCb   导出视频失败的回调
 */
- (void)doExportWithProcess:(ExporterProcessBlock)processcb
                withSuccess:(ExporterSuccessBlock )successCb
                  withFaild:(ExporterFaildBlock)faildCb ;
/**
 *  取消导出
 */
- (void)cancleExport;

@end
