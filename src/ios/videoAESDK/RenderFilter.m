//
//  RenderFilter.m
//  HelloCordova
//
//  Created by 管伟东 on 16/7/15.
//
//

#import "RenderFilter.h"
#import "Video_Const.h"
#import "ConfigItem.h"
#import "Uitiltes.h"
#import "GLModel.h"
#import "RSMVString.h"

NSString *const kVertShaderString = SHADER_STRING
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


NSString *const kFragShaderString = SHADER_STRING
(
 precision highp float;
 precision mediump int;
 varying highp vec2 textureCoordinate;
 uniform sampler2D Sampler;
 uniform  float brightness;
 
 void main()
 {
     mediump vec4 out_Color = texture2D(Sampler, textureCoordinate);
     gl_FragColor =vec4(out_Color.r,out_Color.g,out_Color.b,out_Color.a)*brightness;
 }
 );

NSString *const kFrag2ShaderString = SHADER_STRING
(
 precision highp float;
 precision mediump int;
 varying highp vec2 textureCoordinate;
 uniform sampler2D Sampler;
 uniform  float brightness;
 
 void main()
 {
     mediump vec4 out_Color = texture2D(Sampler, textureCoordinate);
     gl_FragColor =vec4(out_Color.b,out_Color.g,out_Color.r,out_Color.a)*brightness;
 }
 );

GLfloat quadVertexData [] = {
    -1.0 , -1.0, 1.0,
    1.0 , -1.0, 1.0,
    -1.0 ,  1.0, 1.0,
    1.0 ,  1.0, 1.0
};
@interface RenderFilter()
{
    CVOpenGLESTextureRef destTexture;
    CVOpenGLESTextureRef foregroundTexture;
    NSMutableArray * programeSlots;

}
@property(nonatomic ,strong)NSMutableArray  *    configItemsArray;
@property(nonatomic ,strong)NSMutableArray  *    picTureArray ;

@end

@implementation RenderFilter

- (instancetype)init
{
    self = [super initWithVertexShaderFromString:kVertShaderString fragmentShaderFromString:kFragShaderString];
    if (!self)return nil;
    [self addAttributeWithName:@"inputTextureCoordinate"];
    [self addAttributeWithName:@"position"];
    [self setProgram];
    filterPositionAttribute = [filterProgram attributeIndex:@"position"];
    filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    programeSlots = [NSMutableArray array];
    return self;
}

- (void)_handleConfigItems:(NSArray *)configItems
{
    if(self.configItemsArray.count !=0)return;
    self.configItemsArray = [NSMutableArray arrayWithArray:configItems];
    for (int index = 0; index <self.configItemsArray.count; index++) {
        ConfigItem * item = self.configItemsArray[index];
        if(item.type !=kMediaType_Text&&item.type != kMediaType_Picture)continue;
        kMediaType mediaType = kMediaType_unKnown;
        GLModel * model = [[GLModel alloc]init];
        if (item.type == kMediaType_Picture) {
            mediaType = kMediaType_Picture ;
//           NSString * path =  [[NSBundle mainBundle]pathForResource:@"1" ofType:@"png"];
            UIImage * image = [UIImage imageWithContentsOfFile:item.value];
//           NSString * path =  [[NSBundle mainBundle]pathForResource:@"0" ofType:@"png"];
//            UIImage * image = [UIImage imageWithContentsOfFile:path];
            model.image = image;
        }else if(item.type ==kMediaType_Text){
            RSMVString *textPic = [[RSMVString alloc]initWithcString:item.value withFontSize:kFontSize withPosition:CGPointMake(item.pointX, item.pointY)];
            UIImage * image = [textPic convertViewToImage];
            model.image = image;
            mediaType = kMediaType_Text;
        }
        //programe 相关
        GLuint programe = [filterProgram compileVShaderString:kVertShaderString withFShaderString:kFrag2ShaderString];
        GLuint position =  glGetAttribLocation(programe, "position");
        GLuint textureSlot =  glGetAttribLocation(programe, "inputTextureCoordinate");
        GLuint sample = glGetUniformLocation(programe, "Sampler");
        GLuint brignessSlot = glGetUniformLocation(programe, "brightness");

        model.type = mediaType; 
        model.glPrograme = programe;
        model.glPositionSlot = position;
        model.sampleSlot = sample;
        model.glTextureSlot = textureSlot;
        model.brignessSlot = brignessSlot;
        model.index  = index;
        CGImageRef newImageSource = model.image.CGImage;
        model.textFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource)) ;
        glEnableVertexAttribArray(model.glPositionSlot);
        glEnableVertexAttribArray(model.glTextureSlot);
        [programeSlots addObject:model];
        
    }
}
- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer withComposition:(CMTime)compositionTime winthConfigItem:(NSArray *)configItems
{
    [self _handleConfigItems:configItems];
    [self setProgram];
    glEnable(GL_BLEND);
    glBindFramebuffer(GL_FRAMEBUFFER, offscreenBufferHandle);
    [self renderObjectWithPixel:destinationPixelBuffer];
    foregroundTexture = NULL;
    if (foregroundPixelBuffer) {
        glActiveTexture(GL_TEXTURE0);
        [self setInteger:0 forUniformName:@"Sampler"];
        foregroundTexture = [self bgraTextureForPixelBuffer:foregroundPixelBuffer];
        glBindTexture(CVOpenGLESTextureGetTarget(foregroundTexture), CVOpenGLESTextureGetName(foregroundTexture));
        [self setDefaultTextureAttributes];
        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0,[[self class] textureCoordinatesForRotation:kGPUImageNoRotation]);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
        glViewport(0, 0, (int)CVPixelBufferGetWidth(destinationPixelBuffer), (int)CVPixelBufferGetHeight(destinationPixelBuffer));
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        [self renderWithTime:compositionTime];
    }
    int j = 0 ;
    if (programeSlots.count!=0) {
        @autoreleasepool {
        for (int index = 0 ; index < programeSlots.count; index++) {
            GLModel * model = programeSlots[index];
            ConfigItem * item = self.configItemsArray[model.index];
            if(item.to ==-1)item.to = CMTimeGetSeconds(self.videoCompositionDuration);
            if (CMTimeGetSeconds(compositionTime)<item.frome||CMTimeGetSeconds(compositionTime)>item.to) {
                continue ;
            }
            glUseProgram(model.glPrograme);
//            if (model.pixelBuffer) {
            
                CFDataRef dataFromImageDataProvider = NULL;
                if (model.type == kMediaType_Picture) {
                    glActiveTexture(GL_TEXTURE1+j);
                    dataFromImageDataProvider = model.textFromImageDataProvider;
                    GLubyte *imageData = NULL;
                    imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
                    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,
                                 (int)CGImageGetWidth(model.image.CGImage),
                                 (int)CGImageGetHeight(model.image.CGImage),
                                 0,
                                 GL_RGBA, GL_UNSIGNED_BYTE, imageData);
                    glBindTexture(GL_TEXTURE_2D, 0);
                    glUniform1i(model.sampleSlot,1+j);
                    j ++ ;
                }else if(model.type == kMediaType_Text)
                {
                    glActiveTexture(GL_TEXTURE7);
                    dataFromImageDataProvider = model.textFromImageDataProvider;
                    GLubyte *imageData = NULL;
                    imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
                    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,
                                 (int)CGImageGetWidth(model.image.CGImage),
                                 (int)CGImageGetHeight(model.image.CGImage),
                                 0,
                                 GL_RGBA, GL_UNSIGNED_BYTE, imageData);
                    glBindTexture(GL_TEXTURE_2D, 0);
                    glUniform1i(model.sampleSlot,7);
                }
                [self setDefaultTextureAttributes];
                 glViewport(0, 0, (int)CVPixelBufferGetWidth(destinationPixelBuffer), (int)CVPixelBufferGetHeight(destinationPixelBuffer));
                glUniform1f(model.brignessSlot, 1.0);
                glVertexAttribPointer(model.glTextureSlot, 2, GL_FLOAT, 0, 0,[[self class] textureCoordinatesForRotation:kGPUImageNoRotation]);
                glEnableVertexAttribArray(model.glTextureSlot);
                if (model.type == kMediaType_Picture) {
                    glViewport((GLuint)item.pointX, (GLuint)item.pointY,(GLuint)item.width,(GLuint)item.height);
                    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                }else
                {
                    glViewport(0, 0, (int)CVPixelBufferGetWidth(destinationPixelBuffer), (int)CVPixelBufferGetHeight(destinationPixelBuffer));
                    glBlendFunc(GL_SRC_ALPHA,GL_ONE);
                }

                glVertexAttribPointer(model.glPositionSlot, 3, GL_FLOAT, 0, 0,quadVertexData);
                glEnableVertexAttribArray(model.glPositionSlot);
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//                if(model.type == kMediaType_Text)
//                {
//                    if (textFromImageDataProvider!=NULL) {
//                        CFRelease(textFromImageDataProvider);
//                        textFromImageDataProvider = NULL;
//                    }
//                }else
//                {
//                    if (dataFromImageDataProvider!=NULL) {
//                        CFRelease(dataFromImageDataProvider);
//                        dataFromImageDataProvider = NULL;
//                    }
//                }
//            }
        }
    }
    }
bail:
    if(foregroundTexture !=NULL){
        CFRelease(foregroundTexture);
        foregroundTexture =NULL;
    }
    if(destTexture!=NULL){
        CFRelease(destTexture);
        destTexture = NULL;
    }
    CVOpenGLESTextureCacheFlush(self.videoTextureCache, 0);
    [EAGLContext setCurrentContext:nil];
}

- (void)renderObjectWithPixel:(CVPixelBufferRef)pixelBuffer
{
    destTexture = [self bgraTextureForPixelBuffer:pixelBuffer];
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture), 0);
}

- (void)renderWithTime:(CMTime)compositionTime
{
    if (CMTimeGetSeconds(compositionTime)<1) {
        [self setFloat:1.0 forUniformName:@"brightness"];
    }
    if (CMTimeGetSeconds(self.videoCompositionDuration)-CMTimeGetSeconds(compositionTime)<kTailDuration) {
        CGFloat diff = CMTimeGetSeconds(self.videoCompositionDuration)-CMTimeGetSeconds(compositionTime);
        NSLog(@"diff = %f",diff);
        CGFloat brigness = -(0.3f/kTailDuration)*(kTailDuration-diff)+1;
        [self setFloat:brigness forUniformName:@"brightness"];
    }
    glVertexAttribPointer(filterPositionAttribute, 3, GL_FLOAT, 0, 0,quadVertexData);
    glEnableVertexAttribArray(filterPositionAttribute);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)dealloc
{
    if(foregroundTexture !=NULL){
        CFRelease(foregroundTexture);
        foregroundTexture =NULL;
    }
    if(destTexture!=NULL){
        CFRelease(destTexture);
        destTexture = NULL;
    }
    for (int index = 0 ; index < programeSlots.count; index++) {
        GLModel * model = programeSlots[index];
        if (model.textFromImageDataProvider) {
            CFRelease(model.textFromImageDataProvider);
            model.textFromImageDataProvider = NULL;
        }
    }
    
}
@end
