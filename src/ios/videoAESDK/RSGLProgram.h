//
//  RSGLProgram.h
//  saber
//
//  Created by 管伟东 on 15/11/24.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h> 
#import <GLKit/GLKit.h>
@interface RSGLProgram : NSObject
{
    NSMutableArray  *attributes;
    NSMutableArray  *uniforms;
    GLuint vertShader,fragShader;
}
@property (nonatomic)GLuint program;
@property(readwrite, nonatomic) BOOL initialized;
@property(readwrite, copy, nonatomic) NSString *vertexShaderLog;
@property(readwrite, copy, nonatomic) NSString *fragmentShaderLog;
@property(readwrite, copy, nonatomic) NSString *programLog;
@property (nonatomic)EAGLContext * currentContext ; 
- (id)initWithVertexShaderString:(NSString *)vShaderString
            fragmentShaderString:(NSString *)fShaderString;
- (id)initWithVertexShaderString:(NSString *)vShaderString
          fragmentShaderFilename:(NSString *)fShaderFilename;
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename;
- (GLuint )compileVShaderString:(NSString *)vShaderString withFShaderString:(NSString *)fShaderString;
- (void)addAttribute:(NSString *)attributeName;
- (GLuint)attributeIndex:(NSString *)attributeName;
- (GLuint)uniformIndex:(NSString *)uniformName;
- (BOOL)link;
- (void)use;
- (void)useWithPrograme:(GLuint)programe;
- (void)validate; 

@end
