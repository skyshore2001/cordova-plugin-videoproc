//
//  RSVideoCompositionInstruction.m
//  saber
//
//  Created by 管伟东 on 15/11/20.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import "RSVideoCompositionInstruction.h"

@implementation RSVideoCompositionInstruction
@synthesize timeRange = _timeRange;
@synthesize enablePostProcessing = _enablePostProcessing;
@synthesize containsTweening = _containsTweening;
@synthesize requiredSourceTrackIDs = _requiredSourceTrackIDs;
@synthesize passthroughTrackID = _passthroughTrackID;
@synthesize foregroundTrackID = _foregroundTrackID;
@synthesize configItems = _configItems;
- (id)initForegroundTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange withTransform:(CGAffineTransform)transform {
    if (self = [super init]) {
        _foregroundTrackID = passthroughTrackID;
        _timeRange = timeRange;
        _containsTweening = NO;
        _enablePostProcessing = NO;
        _transform = transform;
    }
    return self;
}
- (id)initForegroundTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange withTransform:(CGAffineTransform)transform withConfig:(NSArray *)configItems {
    if (self = [super init]) {
        _foregroundTrackID = passthroughTrackID;
        _timeRange = timeRange;
        _containsTweening = NO;
        _enablePostProcessing = NO;
        _transform = transform;
        _configItems = configItems; 
    }
    return self;
}

- (id)initForegroundTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange withTransform:(CGAffineTransform)transform withSecondTrackID:(CMPersistentTrackID)passthroughTrackID2
{
    if (self = [super init]) {
        _foregroundTrackID = passthroughTrackID;
        NSNumber * value1 = [NSNumber numberWithInt:passthroughTrackID];
        NSNumber * value2 = [NSNumber numberWithInt:passthroughTrackID2];
        _requiredSourceTrackIDs =@[value1,value2];
        _foregroundTrackID =1000;
        _timeRange = timeRange;
        _containsTweening = NO;
        _enablePostProcessing = NO;
        _transform = transform;
    }
    return self;
}



@end
