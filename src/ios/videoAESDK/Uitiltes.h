//
//  Uitiltes.h
//  PictureRenderSDK
//
//  Created by 管伟东 on 16/3/10.
//  Copyright © 2016年 rootsports Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@interface Uitiltes : NSObject

// add by guan 2016年3月10日
// 把UIimage转化为CVPiexBuffer
+ (CVPixelBufferRef)cVPixelBufferFrome:(UIImage *)image ;

+(UIImage*) drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point ;
@end
