//
//  AVAssetTrack+Transform.h
//  saber
//
//  Created by 管伟东 on 15/11/20.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAssetTrack (Transform)
- (CGAffineTransform)properTransformForRenderSize:(CGSize)renderSize;
@end
