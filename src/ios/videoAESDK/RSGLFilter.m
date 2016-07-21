//
//  RSGLFilter.m
//  saber
//
//  Created by 管伟东 on 15/11/24.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import "RSGLFilter.h"
#import "Video_Const.h"
NSString *const kRSImageVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 inputTextureCoordinate;
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position  ;
     textureCoordinate = inputTextureCoordinate;
 }
 );

NSString *const kRSImagePassthroughFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate)*vec4(0.8,0.9,0.2,1.0);
 }
 );

@interface RSGLFilter()
{
    CGSize inputTextureSize, cachedMaximumOutputSize, forcedMaximumSize;
    EAGLContext *imageProcessingContext ;
    KSMatrix4 projection ;
}


@end
@implementation RSGLFilter
@synthesize filterProgram = _filterProgram;

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString
{
    self = [super init];
    if(!self)return nil;
    uniformStateRestorationBlocks = [NSMutableDictionary dictionaryWithCapacity:10];
    inputRotation = kGPUImageNoRotation;
    backgroundColorRed = 0.0;
    backgroundColorGreen = 0.0;
    backgroundColorBlue = 0.0;
    backgroundColorAlpha = 0.0;
    filterProgram = [[RSGLProgram alloc]initWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString];
    if (!filterProgram.initialized)
    {
        [self initializeAttributes];
        if (![filterProgram link])
        {
            NSString *progLog = [filterProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [filterProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [filterProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            filterProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    filterPositionAttribute = [filterProgram attributeIndex:@"position"];
    filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
    filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"];
    [self setProgram];
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    [self setupOffscreenRenderContext]; 
    return self;
}
- (void)setProgram
{
    imageProcessingContext = filterProgram.currentContext;
    [EAGLContext setCurrentContext:imageProcessingContext];
    _currentContext = imageProcessingContext;
    if ([EAGLContext currentContext] != imageProcessingContext)
    {
        [EAGLContext setCurrentContext:imageProcessingContext];
    }
    
    if (self.currentShaderProgram != filterProgram)
    {
        self.currentShaderProgram = filterProgram;
        [filterProgram use];
    }
}
- (void)initializeAttributes
{
    [filterProgram addAttribute:@"position"];
    [filterProgram addAttribute:@"inputTextureCoordinate"];
}
- (void)addAttributeWithName:(NSString *)AttributeName
{
    [filterProgram addAttribute:AttributeName];
    ;
}
- (void)setDefaultTextureAttributes
{
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}
- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [self initWithVertexShaderFromString:kRSImageVertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}
- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kRSImagePassthroughFragmentShaderString]))
    {
        return nil;
    }
    return self;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize
{
   
}
- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex
{
    CGSize rotatedSize = sizeToRotate;
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        rotatedSize.width = sizeToRotate.height;
        rotatedSize.height = sizeToRotate.width;
    }
    
    return rotatedSize;
}
- (CGPoint)rotatedPoint:(CGPoint)pointToRotate forRotation:(GPUImageRotationMode)rotation
{
    CGPoint rotatedPoint;
    switch(rotation)
    {
        case kGPUImageNoRotation: return pointToRotate; break;
        case kGPUImageFlipHorizonal:
        {
            rotatedPoint.x = 1.0 - pointToRotate.x;
            rotatedPoint.y = pointToRotate.y;
        }; break;
        case kGPUImageFlipVertical:
        {
            rotatedPoint.x = pointToRotate.x;
            rotatedPoint.y = 1.0 - pointToRotate.y;
        }; break;
        case kGPUImageRotateLeft:
        {
            rotatedPoint.x = 1.0 - pointToRotate.y;
            rotatedPoint.y = pointToRotate.x;
        }; break;
        case kGPUImageRotateRight:
        {
            rotatedPoint.x = pointToRotate.y;
            rotatedPoint.y = 1.0 - pointToRotate.x;
        }; break;
        case kGPUImageRotateRightFlipVertical:
        {
            rotatedPoint.x = pointToRotate.y;
            rotatedPoint.y = pointToRotate.x;
        }; break;
        case kGPUImageRotateRightFlipHorizontal:
        {
            rotatedPoint.x = 1.0 - pointToRotate.y;
            rotatedPoint.y = 1.0 - pointToRotate.x;
        }; break;
        case kGPUImageRotate180:
        {
            rotatedPoint.x = 1.0 - pointToRotate.x;
            rotatedPoint.y = 1.0 - pointToRotate.y;
        }; break;
    }
    
    return rotatedPoint;
}

- (CGSize)sizeOfFBO;
{
    CGSize outputSize = [self maximumOutputSize];
    if ( (CGSizeEqualToSize(outputSize, CGSizeZero)) || (inputTextureSize.width < outputSize.width) )
    {
        return inputTextureSize;
    }
    else
    {
        return outputSize;
    }
}
- (CGSize)maximumOutputSize;
{
    return CGSizeZero;
}

+ (const GLfloat *)textureCoordinatesForRotation:(GPUImageRotationMode)rotationMode;
{
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat rotateLeftTextureCoordinates[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
    };
    
    static const GLfloat rotateRightTextureCoordinates[] = {
        0.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    static const GLfloat verticalFlipTextureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    
    static const GLfloat horizontalFlipTextureCoordinates[] = {
        1.0f, 0.0f,
        0.0f, 0.0f,
        1.0f,  1.0f,
        0.0f,  1.0f,
    };
    
    static const GLfloat rotateRightVerticalFlipTextureCoordinates[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat rotateRightHorizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotate180TextureCoordinates[] = {
        1.0f, 1.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    switch(rotationMode)
    {
        case kGPUImageNoRotation: return noRotationTextureCoordinates;
        case kGPUImageRotateLeft: return rotateLeftTextureCoordinates;
        case kGPUImageRotateRight: return rotateRightTextureCoordinates;
        case kGPUImageFlipVertical: return verticalFlipTextureCoordinates;
        case kGPUImageFlipHorizonal: return horizontalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipVertical: return rotateRightVerticalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipHorizontal: return rotateRightHorizontalFlipTextureCoordinates;
        case kGPUImageRotate180: return rotate180TextureCoordinates;
    }
}
- (void)setupOffscreenRenderContext
{
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
        _videoTextureCache = NULL;
    }
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, imageProcessingContext, NULL, &_videoTextureCache);
    if (err != noErr) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
    }
    glDisable(GL_DEPTH_TEST);
    //创建和绑定frameBuffer
    glGenFramebuffers(1, &offscreenBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, offscreenBufferHandle);
}


- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer
{
    
}

- (void) renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer withComposition:(CMTime)compositionTime
{
    
}

- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer1 withSourceBuffer2:(CVPixelBufferRef)foregroundPixelBuffer2
{
    //subClass implement
}

- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer1 withSourceBuffer2:(CVPixelBufferRef)foregroundPixelBuffer2 withCompositionTime:(CMTime)compositionTime
{
    
}
- (CVOpenGLESTextureRef)rgbaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVOpenGLESTextureRef bgraTexture = NULL;
    CVReturn err;
    if (!_videoTextureCache) {
        NSLog(@"No video texture cache");
        goto bail;
    }
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_DEPTH_COMPONENT,
                                                       GL_RGB,
                                                       (int)CVPixelBufferGetWidth(pixelBuffer),
                                                       (int)CVPixelBufferGetHeight(pixelBuffer),
                                                       GL_DEPTH_COMPONENT,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &bgraTexture);
    if (!bgraTexture || err) {
        NSLog(@"Error creating BGRA texture using CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
bail:
    return bgraTexture;
}

- (CVOpenGLESTextureRef)bgraTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVOpenGLESTextureRef bgraTexture = NULL;
    CVReturn err;
    if (!_videoTextureCache) {
        NSLog(@"No video texture cache");
        goto bail;
    }
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       (int)CVPixelBufferGetWidth(pixelBuffer),
                                                       (int)CVPixelBufferGetHeight(pixelBuffer),
                                                       GL_RGBA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &bgraTexture);
    if (!bgraTexture || err) {
        NSLog(@"Error creating BGRA texture using CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
bail:
    return bgraTexture;
}
- (CVOpenGLESTextureRef)rgbTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVOpenGLESTextureRef bgraTexture = NULL;
    CVReturn err;
    if (!_videoTextureCache) {
        NSLog(@"No video texture cache");
        goto bail;
    }
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_SRGB_EXT,
                                                       (int)CVPixelBufferGetWidth(pixelBuffer),
                                                       (int)CVPixelBufferGetHeight(pixelBuffer),
                                                       GL_RGB,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &bgraTexture);
    if (!bgraTexture || err) {
        NSLog(@"Error creating BGRA texture using CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
bail:
    return bgraTexture;
}

void printIfError(){
    GLenum gl_error=glGetError();
    if(gl_error!=GL_NO_ERROR)
        printf("OpenGL error %x: %s\n", gl_error, glCheckFramebufferStatus(GL_FRAMEBUFFER)==36053?"framebuffer Success":"frameBuffer faild");
}


#pragma mark - guan 2015年11月25日
#pragma mark - ChangeOpenGL Lang
- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;
{
    backgroundColorRed = redComponent;
    backgroundColorGreen = greenComponent;
    backgroundColorBlue = blueComponent;
    backgroundColorAlpha = alphaComponent;
}
- (void)setInteger:(GLint)newInteger forUniformName:(NSString *)uniformName;
{
    GLuint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setInteger:newInteger forUniform:uniformIndex program:filterProgram];
}
- (void)setFloat:(GLfloat)newFloat forUniformName:(NSString *)uniformName;
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setFloat:newFloat forUniform:uniformIndex program:filterProgram];
}
- (void)setSize:(CGSize)newSize forUniformName:(NSString *)uniformName;
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setSize:newSize forUniform:uniformIndex program:filterProgram];
}
- (void)setPoint:(CGPoint)newPoint forUniformName:(NSString *)uniformName
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setPoint:newPoint forUniform:uniformIndex program:filterProgram];
}
- (void)setFloatVec3:(KSVec3)newVec3 forUniformName:(NSString *)uniformName
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setVec3:newVec3 forUniform:uniformIndex program:filterProgram]; 
}
- (void)setFloatVec4:(KSVec4)newVec4 forUniform:(NSString *)uniformName
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setVec4:newVec4 forUniform:uniformIndex program:filterProgram];
}
- (void)setfloatColor4:(KSColor)newVec4 forUniform:(NSString *)uniformName
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setfloatColor4:newVec4 forUniform:uniformIndex program:filterProgram];
}
- (void)setFloatArray:(GLfloat *)array length:(GLsizei)count forUniform:(NSString*)uniformName
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setFloatArray:array length:count forUniform:uniformIndex program:filterProgram];
}
- (void)setMatrix4f:(KSMatrix4)matrix forUniform:(NSString *)uniformName
{
       GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setMatrix4f:matrix forUniform:uniformIndex program:filterProgram];
}

- (void)setfloatColor4:(KSColor)newVec4 forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform4fv(uniform, 1, (GLfloat *)&newVec4);
    }];
}

- (void)setMatrix3f:(KSMatrix3)matrix forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniformMatrix3fv(uniform, 1, GL_FALSE, (GLfloat *)&matrix.m[0][0]);
    }];
}
- (void)setMatrix4f:(KSMatrix4)matrix forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniformMatrix4fv(uniform, 1, GL_FALSE, (GLfloat *)&matrix.m[0][0]);
    }];
}
- (void)setVec4:(KSVec4)vectorValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform4fv(uniform, 1, (GLfloat *)&vectorValue);
    }];
}
- (void)setInteger:(GLint)intValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
            glUniform1i(uniform, intValue);
    }];
}
- (void)setFloat:(GLfloat)floatValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform1f(uniform, floatValue);
    }];
}
- (void)setSize:(CGSize)sizeValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        GLfloat sizeArray[2];
        sizeArray[0] = sizeValue.width;
        sizeArray[1] = sizeValue.height;
        glUniform2fv(uniform, 1, sizeArray);
    }];
}

- (void)setPoint:(CGPoint)pointValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        GLfloat positionArray[2];
        positionArray[0] = pointValue.x;
        positionArray[1] = pointValue.y;
        
        glUniform2fv(uniform, 1, positionArray);
    }];
}

- (void)setVec3:(KSVec3)vectorValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform3fv(uniform, 1, (GLfloat *)&vectorValue);
    }];
}
- (void)setVec3:(KSVec3)newVec3 forUniformName:(NSString *)uniformName
{
    GLint uniformIndex = [filterProgram uniformIndex:uniformName];
    [self setVec3:newVec3 forUniform:uniformIndex program:filterProgram];
}


- (void)setFloatArray:(GLfloat *)arrayValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram
{
    [EAGLContext setCurrentContext:imageProcessingContext];
    [filterProgram use];
    NSData* arrayData = [NSData dataWithBytes:arrayValue length:arrayLength * sizeof(arrayValue[0])];
    [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
        glUniform1fv(uniform, arrayLength, [arrayData bytes]);
    }];
}

- (void)setAndExecuteUniformStateCallbackAtIndex:(GLint)uniform forProgram:(RSGLProgram *)shaderProgram toBlock:(dispatch_block_t)uniformStateBlock;
{
    [uniformStateRestorationBlocks setObject:[uniformStateBlock copy] forKey:[NSNumber numberWithInt:uniform]];
    uniformStateBlock();
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;
{
    [uniformStateRestorationBlocks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        dispatch_block_t currentBlock = obj;
        currentBlock();
    }];
}

- (void)dealloc
{
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
    }
}
@end
