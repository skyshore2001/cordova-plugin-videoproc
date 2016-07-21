//
//  RSBaseMedia.h
//  FirstPhase
//
//  Created by 管伟东 on 16/3/16.
//  Copyright © 2016年 rootsports Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video_Const.h"
@interface RSBaseMedia : NSObject
/**
 *  媒体路径,绝对路径
 */
@property (nonatomic ,retain) NSString *     mediaPath     ;
/**
 *  媒体名称
 */
@property (nonatomic ,retain) NSString      * mediaName;
/**
 *  媒体Url
 */
@property (nonatomic ,retain) NSURL         * mediaUrl;
/**
 *  媒体资源
 */
@property (nonatomic ,retain) AVAsset *      mediaAsset ;
/**
 *  类型 标示视频还是音频
 */
@property (nonatomic ,assign) kMediaType     type          ;
/**
 *  媒体总时长
 */
@property (nonatomic ,assign) CMTime        mediaDuration;

@property (nonatomic ,retain) AVURLAsset * mediaUrlAsset ;
/**
 *  初始化方法
 *
 *  @param mediapath 路径名称
 *  @param mediaName 媒体名称
 *
 *  @return instance of media
 */
- (instancetype)initWithMediaPath:(NSString *)mediapath withName:(NSString *)mediaName;

/**
 *  初始化方法
 *
 *  @param mediapath 路径名称
 *
 *  @return instance of media
 */
- (instancetype)initWithMediaPath:(NSString *)mediapath;

/**
 *  通过url初始化
 *
 *  @param videoUrl media url  必须是file url
 *
 *  @return instance of Media 
 */
- (instancetype)initWithURL:(NSURL *)videoUrl;
/**
 *  通过url初始化
 *
 *  @return instance of Media
 */
- (instancetype)initWithALAssertUrl:(NSURL *)alassetUrl;
/**
 *  通过媒体资源去初始化
 *
 *  @param asset 媒体资源
 *
 *  @return instance of Media
 */
- (instancetype)initWithALAsset:(AVAsset *)asset ;
@end
