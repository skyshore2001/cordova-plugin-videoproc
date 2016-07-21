//
//  RSVideoCompositionInstruction.h
//  saber
//
//  Created by 管伟东 on 15/11/20.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface RSVideoCompositionInstruction : NSObject<AVVideoCompositionInstruction>

@property CMPersistentTrackID foregroundTrackID;
@property CMPersistentTrackID backgroundTrackID;
@property CGAffineTransform transform;
@property NSArray * configItems; 
- (id)initForegroundTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange withTransform:(CGAffineTransform)transform;
- (id)initForegroundTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange withTransform:(CGAffineTransform)transform withConfig:(NSArray *)configItems; 
- (id)initForegroundTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange withTransform:(CGAffineTransform)transform withSecondTrackID:(CMPersistentTrackID)passthroughTrackID2;

@end
