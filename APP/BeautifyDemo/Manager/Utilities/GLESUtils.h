//
//  GLESUtils.h
//  Tutorial02
//
//  Created by kesalin on 12-11-25.
//  Copyright (c) 2012年 Created by kesalin@gmail.com on. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface GLESUtils : NSObject


+ (GLint)glueGetUniformLocation:(GLuint)program name:(const GLchar *)name;

+ (GLint)glueCreateProgram:(const GLchar *)vertSource
                fragSource:(const GLchar *)fragSource
              attribNameCt:(GLsizei)attribNameCt
               attribNames:(const GLchar **)attribNames
           attribLocations:(const GLint *)attribLocations
             uniformNameCt:(GLsizei )uniformNameCt
              uniformNames:(const GLchar **)uniformNames
          uniformLocations:(GLint *)uniformLocations
                   program:(GLuint *)program;



+ (GLuint)loadProgram:(NSString *)vertexShaderFilepath withFragmentShaderFilepath:(NSString *)fragmentShaderFilepath;
+ (const GLchar *)readFile:(NSString *)name;


+ (GLuint)programWithVertexShader:(NSString*)vsh fragmentShader:(NSString*)fsh;
+ (GLuint)shaderWithName:(NSString*)name type:(GLenum)type;


+ (CFDictionaryRef)createPixelBufferPoolAuxAttributes:(int32_t)maxBufferCount;
+ (void)preallocatePixelBuffersInPool:(CVPixelBufferPoolRef)pool auxAttributes:(CFDictionaryRef)auxAttributes;

+ (CVPixelBufferPoolRef)createPixelBufferPool:(int32_t)width
                                        hight:(int32_t)height
                                  pixelFormat:(FourCharCode)pixelFormat
                               maxBufferCount:(int32_t)maxBufferCount;

+ (GLuint)generateRenderTextureWidth:(float)width height:(float)height pixels:(void *)pixels;

+ (void)MGDeleteTexture:(GLuint *)texture;


@end
