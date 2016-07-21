//
//  RSMVString.m
//  saber
//
//  Created by 管伟东 on 15/12/14.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import "RSMVString.h"

@implementation RSMVString

- (instancetype)initWithcString:(NSString  *)string withFontSize:(CGFloat)size withPosition:(CGPoint)position
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, 640, 360)];
        UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(position.x, position.y, size*string.length, size)];
        
        lable.text = string;
        lable.textColor = [UIColor whiteColor];
        lable.textAlignment  = NSTextAlignmentCenter;
        lable.backgroundColor = [UIColor blackColor];
        self.backgroundColor = [UIColor blackColor];
        lable.font = [UIFont systemFontOfSize:size];
        [self addSubview:lable];
    }
    return self;
}
+(UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
-(CVPixelBufferRef)convertViewToImage{
                                                                                                                                                                                                                                                                                                                                                                      
    UIGraphicsBeginImageContext(self.bounds.size);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return [self pixelBufferFromCGImage:image.CGImage];
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), 
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}
@end
