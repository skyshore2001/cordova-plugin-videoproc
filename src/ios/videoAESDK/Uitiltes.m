//
//  Uitiltes.m
//  PictureRenderSDK
//
//  Created by 管伟东 on 16/3/10.
//  Copyright © 2016年 rootsports Inc. All rights reserved.
//

#import "Uitiltes.h"

@implementation Uitiltes


+ (CVPixelBufferRef)cVPixelBufferFrome:(UIImage *)image
{
    CGImageRef cgImage = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pixelbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pixelbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pixelbuffer != NULL);
    CVPixelBufferLockBaseAddress(pixelbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pixelbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, 4*imageSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(cgImage),
                                           CGImageGetHeight(cgImage)), cgImage);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelbuffer, 0);
    return pixelbuffer;
}


+(UIImage*) drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point
{
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 0.0f);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor redColor] set];
    
    UIFont *font = [UIFont boldSystemFontOfSize:200];
    if([text respondsToSelector:@selector(drawInRect:withAttributes:)])
    {
        //iOS 7
        NSDictionary *att = @{NSFontAttributeName:font};
        [text drawInRect:rect withAttributes:att];
    }
    else
    {
        //legacy support
        [text drawInRect:CGRectIntegral(rect) withFont:font];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
