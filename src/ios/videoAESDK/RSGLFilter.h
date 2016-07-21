//
//  RSGLFilter.h
//  saber
//
//  Created by 管伟东 on 15/11/24.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLESMath.h"
#import "RSGLProgram.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVFoundation.h>
#define VideoTailDuration 25
#define GPUImageHashIdentifier #
#define GPUImageWrappedLabel(x) x
#define GPUImageEscapedHashIdentifier(a) GPUImageWrappedLabel(GPUImageHashIdentifier)a  

#define GPUImageRotationSwapsWidthAndHeight(rotation) ((rotation) == kGPUImageRotateLeft || (rotation) == kGPUImageRotateRight || (rotation) == kGPUImageRotateRightFlipVertical || (rotation) == kGPUImageRotateRightFlipHorizontal)

typedef enum { kGPUImageNoRotation, kGPUImageRotateLeft, kGPUImageRotateRight, kGPUImageFlipVertical, kGPUImageFlipHorizonal, kGPUImageRotateRightFlipVertical, kGPUImageRotateRightFlipHorizontal, kGPUImageRotate180 } GPUImageRotationMode;
void printIfError();

@interface RSGLFilter : NSObject
{
    RSGLProgram *filterProgram;
    GLint filterPositionAttribute, filterTextureCoordinateAttribute;
    GLint filterInputTextureUniform;
    GLfloat backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha;
    BOOL isEndProcessing;
    NSMutableDictionary *uniformStateRestorationBlocks;
    GPUImageRotationMode inputRotation;
    GLuint  offscreenBufferHandle ;
}
@property (nonatomic ,retain)RSGLProgram * filterProgram ;
@property (nonatomic,retain)RSGLProgram * currentShaderProgram ;
@property (nonatomic,retain)EAGLContext * currentContext ;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef videoTextureCache;
@property (nonatomic,assign)CMTime videoCompositionDuration;
- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
- (void)setupOffscreenRenderContext;
- (void)initializeAttributes;
- (void)setDefaultTextureAttributes ;
- (void)setProgram ;
- (void)addAttributeWithName:(NSString *)AttributeName; 
- (CVOpenGLESTextureRef)bgraTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (CVOpenGLESTextureRef)rgbaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (CVOpenGLESTextureRef)rgbTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer ;  
- (void)setupFilterForSize:(CGSize)filterFrameSize;
- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
- (CGPoint)rotatedPoint:(CGPoint)pointToRotate forRotation:(GPUImageRotationMode)rotation;
+ (const GLfloat *)textureCoordinatesForRotation:(GPUImageRotationMode)rotationMode;
- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer;

- (void) renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer withComposition:(CMTime)compositionTime ;
- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer1 withSourceBuffer2:(CVPixelBufferRef)foregroundPixelBuffer2;

- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer1 withSourceBuffer2:(CVPixelBufferRef)foregroundPixelBuffer2 withCompositionTime:(CMTime)compositionTime ;

//改变glsl
- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;
- (void)setInteger:(GLint)newInteger forUniformName:(NSString *)uniformName;
- (void)setFloat:(GLfloat)newFloat forUniformName:(NSString *)uniformName;
- (void)setSize:(CGSize)newSize forUniformName:(NSString *)uniformName;
- (void)setPoint:(CGPoint)newPoint forUniformName:(NSString *)uniformName;
- (void)setFloatVec3:(KSVec3)newVec3 forUniformName:(NSString *)uniformName;
- (void)setFloatVec4:(KSVec4)newVec4 forUniform:(NSString *)uniformName;
- (void)setfloatColor4:(KSColor)newVec4 forUniform:(NSString *)uniformName;
- (void)setFloatArray:(GLfloat *)array length:(GLsizei)count forUniform:(NSString*)uniformName;
- (void)setMatrix4f:(KSMatrix4)matrix forUniform:(NSString *)uniformName;

//3d
- (void)setMatrix3f:(KSMatrix3)matrix forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
- (void)setMatrix4f:(KSMatrix4)matrix forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
- (void)setFloat:(GLfloat)floatValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
- (void)setPoint:(CGPoint)pointValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
- (void)setSize:(CGSize)sizeValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
- (void)setVec3:(KSVec3)vectorValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
- (void)setfloatColor4:(KSColor)newVec4 forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
- (void)setVec3:(KSVec3)newVec3 forUniformName:(NSString *)uniformName;  
- (void)setVec4:(KSVec4)vectorValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
- (void)setFloatArray:(GLfloat *)arrayValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;
- (void)setInteger:(GLint)intValue forUniform:(GLint)uniform program:(RSGLProgram *)shaderProgram;

- (void)setAndExecuteUniformStateCallbackAtIndex:(GLint)uniform forProgram:(RSGLProgram *)shaderProgram toBlock:(dispatch_block_t)uniformStateBlock;
- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;
@end
