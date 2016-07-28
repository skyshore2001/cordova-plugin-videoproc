//
//  RSMVString.h
//  saber
//
//  Created by 管伟东 on 15/12/14.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSMVString :UIView
- (instancetype)initWithcString:(NSString  *)string withFontSize:(CGFloat)size withPosition:(CGPoint)position;
-(UIImage *)convertViewToImage;
@end
