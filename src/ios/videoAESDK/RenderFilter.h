//
//  RenderFilter.h
//  HelloCordova
//
//  Created by 管伟东 on 16/7/15.
//
//

#import "RSGLFilter.h"

@interface RenderFilter : RSGLFilter
- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer withComposition:(CMTime)compositionTime winthConfigItem:(NSArray *)configItems;
@end
