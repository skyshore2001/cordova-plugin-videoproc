//
//  RSGLProgram.m
//  saber
//
//  Created by 管伟东 on 15/11/24.
//  Copyright © 2015年 rootsports Inc. All rights reserved.
//

#import "RSGLProgram.h"
#pragma mark Function Pointer Definitions
typedef void (*GLInfoFunction)(GLuint program, GLenum pname, GLint* params);
typedef void (*GLLogFunction) (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog);
@interface RSGLProgram()

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
               string:(NSString *)shaderString;
@end
@implementation RSGLProgram
@synthesize initialized = _initialized;
- (id)initWithVertexShaderString:(NSString *)vShaderString
            fragmentShaderString:(NSString *)fShaderString;
{
    if ((self = [super init]))
    {
        _initialized = NO;
        
        attributes = [[NSMutableArray alloc] init];
        uniforms = [[NSMutableArray alloc] init];
        _currentContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_currentContext];
        _program = glCreateProgram();

        if (![self compileShader:&vertShader
                            type:GL_VERTEX_SHADER
                          string:vShaderString])
        {
            NSLog(@"Failed to compile vertex shader");
        }
        
        // Create and compile fragment shader
        if (![self compileShader:&fragShader
                            type:GL_FRAGMENT_SHADER
                          string:fShaderString])
        {
            NSLog(@"Failed to compile fragment shader");
        }
        
        glAttachShader(_program, vertShader);
        glAttachShader(_program, fragShader);
    }
    
    return self;
}
- (GLuint )compileVShaderString:(NSString *)vShaderString withFShaderString:(NSString *)fShaderString
{
    
    [EAGLContext setCurrentContext:_currentContext];
    GLuint programe2 = glCreateProgram();
    GLuint cVerShader = 0 ;
    GLuint cFragShader = 0;
    if (![self compileShader:&cVerShader type:GL_VERTEX_SHADER string:vShaderString]) {
        NSLog(@"Failed to compile vertex shader");
    }
    // Create and compile fragment shader
    if (![self compileShader:&cFragShader
                        type:GL_FRAGMENT_SHADER
                      string:fShaderString])
    {
        NSLog(@"Failed to compile fragment shader");
    }
    glAttachShader(programe2, cVerShader);
    glAttachShader(programe2, cFragShader);
    if([self linkWithProgram:programe2 withVshader:cVerShader withFShader:cFragShader])
        return programe2;
    return -1 ;
 
}
- (id)initWithVertexShaderString:(NSString *)vShaderString
          fragmentShaderFilename:(NSString *)fShaderFilename;
{
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:fShaderFilename ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if ((self = [self initWithVertexShaderString:vShaderString fragmentShaderString:fragmentShaderString]))
    {
    }
    
    return self;
}

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename;
{
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:vShaderFilename ofType:@"vsh"];
    NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:fShaderFilename ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if ((self = [self initWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString]))
    {
    }
    
    return self;
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
               string:(NSString *)shaderString
{
    GLint status;
    const GLchar *source;
    
    source =(GLchar *)[shaderString UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    
    if (status != GL_TRUE)
    {
        GLint logLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0)
        {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(*shader, logLength, &logLength, log);
            if (shader == &vertShader)
            {
                self.vertexShaderLog = [NSString stringWithFormat:@"%s", log];
            }
            else
            {
                self.fragmentShaderLog = [NSString stringWithFormat:@"%s", log];
            }
            
            free(log);
        }
    }
    return status == GL_TRUE;
}
#pragma mark -
- (void)addAttribute:(NSString *)attributeName
{
    if (![attributes containsObject:attributeName])
    {
        [attributes addObject:attributeName];
        glBindAttribLocation(_program,
                             (GLuint)[attributes indexOfObject:attributeName],
                             [attributeName UTF8String]);
    }
}

- (GLuint)attributeIndex:(NSString *)attributeName
{
    return (GLuint)[attributes indexOfObject:attributeName];
}
- (GLuint)uniformIndex:(NSString *)uniformName
{
    return glGetUniformLocation(_program, [uniformName UTF8String]);
}
#pragma mark -
- (BOOL)link
{
    GLint status;
    glLinkProgram(_program);
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
        return NO;
    if (vertShader){
        glDeleteShader(vertShader);
        vertShader = 0;
    }
    if (fragShader){
        glDeleteShader(fragShader);
        fragShader = 0;
    }
    self.initialized = YES;
    return YES;
}
- (BOOL)linkWithProgram:(GLuint)programe withVshader:(GLuint)cVshader withFShader:(GLuint)cFshader
{
    GLint status;
    glLinkProgram(programe);
    glGetProgramiv(programe, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
        return NO;
    if (cVshader)
    {
        glDeleteShader(cVshader);
        cVshader = 0;
    }
    if (cFshader)
    {
        glDeleteShader(cFshader);
        cFshader = 0;
    }
    return YES;
 
}

- (void)use
{
    glUseProgram(_program);
}
- (void)useWithPrograme:(GLuint)programe
{
    glUseProgram(programe);
}
#pragma mark -
- (void)validate;
{
    GLint logLength;
    
    glValidateProgram(_program);
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        self.programLog = [NSString stringWithFormat:@"%s", log];
        free(log);
    }
}

#pragma mark -
// START:dealloc
- (void)dealloc
{
//    if (vertShader)
//        glDeleteShader(vertShader);
//    
//    if (fragShader)
//        glDeleteShader(fragShader);
//    
//    if (_program)
//        glDeleteProgram(_program);
    
}
// END:dealloc
@end
