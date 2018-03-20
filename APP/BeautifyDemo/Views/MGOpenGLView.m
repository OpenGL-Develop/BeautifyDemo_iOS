/*
 File: OpenGLPixelBufferView.m
 Abstract: The OpenGL ES view
 Version: 2.1
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 */

#import "MGOpenGLView.h"
#import <OpenGLES/EAGL.h>
#import <QuartzCore/CAEAGLLayer.h>

#import "GLESUtils.h"

#if !defined(_STRINGIFY)
#define __STRINGIFY( _x )   # _x
#define _STRINGIFY( _x )   __STRINGIFY( _x )
#endif

enum {
    BASE_ATTRIB_VERTEX,
    BASE_ATTRIB_TEXTUREPOSITON,
    BASE_NUM_ATTRIBUTES
};

static const float basesquareVertices[] = {
    -1.0f, -1.0f, // bottom left
    1.0f, -1.0f, // bottom right
    -1.0f,  1.0f, // top left
    1.0f,  1.0f, // top right
};


@interface MGOpenGLView ()
{
    EAGLContext *_oglContext;
    CVOpenGLESTextureCacheRef _textureCache;
    GLint _width;
    GLint _height;
    
    GLuint _frameBufferHandle;
    GLuint _colorBufferHandle;
    
    GLuint _program;
    GLint _frame;
}
@property (nonatomic, strong) NSDate *oldFrameRateDate;
@end

@implementation MGOpenGLView

- (void)dealloc
{
    [self reset];
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        // On iOS8 and later we use the native scale of the screen as our content scale factor.
        // This allows us to render to the exact pixel resolution of the screen which avoids additional scaling and GPU rendering work.
        // For example the iPhone 6 Plus appears to UIKit as a 736 x 414 pt screen with a 3x scale factor (2208 x 1242 virtual pixels).
        // But the native pixel dimensions are actually 1920 x 1080.
        // Since we are streaming 1080p buffers from the camera we can render to the iPhone 6 Plus screen at 1:1 with no additional scaling if we set everything up correctly.
        // Using the native scale of the screen also allows us to render at full quality when using the display zoom feature on iPhone 6/6 Plus.
        
        // Only try to compile this code if we are using the 8.0 or later SDK.
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if ( [UIScreen instancesRespondToSelector:@selector(nativeScale)] )
        {
            self.contentScaleFactor = [UIScreen mainScreen].nativeScale;
        }
        else
#endif
        {
            self.contentScaleFactor = [UIScreen mainScreen].scale;
        }
        
        // Initialize OpenGL ES 2
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(NO),
                                         kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        
        _oglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        if ( ! _oglContext ) {
            NSLog( @"Problem with OpenGL context." );
            return nil;
        }
    }
    return self;
}

double radians(float degrees) {
    return ( degrees * M_PI ) / 180.0;
}

- (BOOL)initializeBuffers
{
    BOOL success = YES;
    
    glDisable( GL_DEPTH_TEST );
    
    glGenFramebuffers( 1, &_frameBufferHandle );
    glBindFramebuffer( GL_FRAMEBUFFER, _frameBufferHandle );
    
    glGenRenderbuffers( 1, &_colorBufferHandle );
    glBindRenderbuffer( GL_RENDERBUFFER, _colorBufferHandle );
    
    [_oglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    glGetRenderbufferParameteriv( GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width );
    glGetRenderbufferParameteriv( GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height );
    
    glFramebufferRenderbuffer( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle );
    if ( glCheckFramebufferStatus( GL_FRAMEBUFFER ) != GL_FRAMEBUFFER_COMPLETE ) {
        NSLog( @"Failure with framebuffer generation" );
        success = NO;
        goto bail;
    }
    
    //  Create a new CVOpenGLESTexture cache
    CVReturn err = CVOpenGLESTextureCacheCreate( kCFAllocatorDefault, NULL, _oglContext, NULL, &_textureCache );
    if ( err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreate %d", err );
        success = NO;
        goto bail;
    }
    
    [self setupVideoProgram];
    
    if (! _program) {
        NSLog( @"Error creating the program" );
        success = NO;
        goto bail;
    }
    _frame = [GLESUtils glueGetUniformLocation:_program name:"videoframe"];
    
bail:
    if (! success) {
        [self reset];
    }
    return success;
}

- (void)setupVideoProgram{
    //Load vertex and fragment shaders
    GLint attribLocation[BASE_NUM_ATTRIBUTES] = {
        BASE_ATTRIB_VERTEX, BASE_ATTRIB_TEXTUREPOSITON,
    };
    GLchar *attribName[BASE_NUM_ATTRIBUTES] = {
        "position", "texturecoordinate",
    };
    
    const GLchar *vertSrc = [GLESUtils readFile:@"BaseVideo.vsh"];
    const GLchar *fragSrc = [GLESUtils readFile:@"BaseVideo.fsh"];
    
    // shader program
    [GLESUtils glueCreateProgram:vertSrc
                      fragSource:fragSrc
                    attribNameCt:BASE_NUM_ATTRIBUTES
                     attribNames:(const GLchar **)&attribName[0]
                 attribLocations:attribLocation uniformNameCt:0
                    uniformNames:0 uniformLocations:0
                         program:&_program];
}

- (void)reset
{
    EAGLContext *oldContext = [EAGLContext currentContext];
    if ( oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
            return;
        }
    }
    if ( _frameBufferHandle ) {
        glDeleteFramebuffers( 1, &_frameBufferHandle );
        _frameBufferHandle = 0;
    }
    if ( _colorBufferHandle ) {
        glDeleteRenderbuffers( 1, &_colorBufferHandle );
        _colorBufferHandle = 0;
    }
    if ( _program ) {
        glDeleteProgram( _program );
        _program = 0;
    }
    if ( _textureCache ) {
        CFRelease( _textureCache );
        _textureCache = 0;
    }
    if ( oldContext != _oglContext ) {
        [EAGLContext setCurrentContext:oldContext];
    }
}


- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    @synchronized (self) {
//#if DEBUG
        // 帧率计算
        if (_oldFrameRateDate) {
            NSTimeInterval timeInterval = [[NSDate new] timeIntervalSinceDate:_oldFrameRateDate];
            if (timeInterval < 35.7 && timeInterval > 33) {
                timeInterval = 33.33;
            }
            int frameRate = 1000/(int)(timeInterval*1000);
//            NSLog(@"%f %d",(timeInterval*1000), frameRate);
            _debugStr = [NSString stringWithFormat:@"\nFPS: %d",frameRate];
            _fps = [NSString stringWithFormat:@"%d",frameRate];
        } else {
            _debugStr = @"";
        }
        
        // 分辨率
        NSString *resolution = [NSString stringWithFormat:@"\n分辨率：%dX%d",(int32_t)CVPixelBufferGetWidth(pixelBuffer),(int32_t)CVPixelBufferGetHeight(pixelBuffer)];
        _debugStr = [_debugStr stringByAppendingString:resolution];
        _resolution = [NSString stringWithFormat:@"%dX%d",(int32_t)CVPixelBufferGetWidth(pixelBuffer),(int32_t)CVPixelBufferGetHeight(pixelBuffer)];
        
        _oldFrameRateDate = [NSDate new];
//#else
//#endif
        
        if ( pixelBuffer == NULL ) {
//            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL pixel buffer" userInfo:nil];
            return;
        }
        
        EAGLContext *oldContext = [EAGLContext currentContext];
        if ( oldContext != _oglContext ) {
            if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
                return;
            }
        }
        
        if ( _frameBufferHandle == 0 ) {
            BOOL success = [self initializeBuffers];
            if ( ! success ) {
                CVPixelBufferRelease(pixelBuffer);
                NSLog( @"Problem initializing OpenGL buffers." );
                return;
            }
        }
        
        // Create a CVOpenGLESTexture from a CVPixelBufferRef
        size_t frameWidth = CVPixelBufferGetWidth( pixelBuffer );
        size_t frameHeight = CVPixelBufferGetHeight( pixelBuffer );
        CVOpenGLESTextureRef texture = NULL;
        CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage( kCFAllocatorDefault,
                                                                    _textureCache,
                                                                    pixelBuffer,
                                                                    NULL,
                                                                    GL_TEXTURE_2D,
                                                                    GL_RGBA,
                                                                    (GLsizei)frameWidth,
                                                                    (GLsizei)frameHeight,
                                                                    GL_BGRA,
                                                                    GL_UNSIGNED_BYTE,
                                                                    0,
                                                                    &texture );
        
        if ( ! texture || err ) {
            CVPixelBufferRelease(pixelBuffer);
            NSLog( @"CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err );
            return;
        }
        
        // Set the view port to the entire view
        glBindFramebuffer( GL_FRAMEBUFFER, _frameBufferHandle );
        glViewport( 0, 0, _width, _height );
        
        glUseProgram( _program );
        glActiveTexture( GL_TEXTURE0 );
        glBindTexture( CVOpenGLESTextureGetTarget( texture ), CVOpenGLESTextureGetName( texture ) );
        glUniform1i( _frame, 0 );
        
        // Set texture parameters
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        
        glVertexAttribPointer( BASE_ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, basesquareVertices );
        glEnableVertexAttribArray( BASE_ATTRIB_VERTEX );
        
        // Preserve aspect ratio; fill layer bounds
        CGSize textureSamplingSize;
        CGSize cropScaleAmount = CGSizeMake( self.bounds.size.width / (float)frameWidth, self.bounds.size.height / (float)frameHeight );
        if ( cropScaleAmount.height > cropScaleAmount.width ) {
            textureSamplingSize.width = self.bounds.size.width / ( frameWidth * cropScaleAmount.height );
            textureSamplingSize.height = 1.0;
        }
        else {
            textureSamplingSize.width = 1.0;
            textureSamplingSize.height = self.bounds.size.height / ( frameHeight * cropScaleAmount.width );
        }
        
        // Perform a vertical flip by swapping the top left and the bottom left coordinate.
        // CVPixelBuffers have a top left origin and OpenGL has a bottom left origin.
        GLfloat passThroughTextureVertices[] = {
            ( 1.0 - textureSamplingSize.width ) / 2.0, ( 1.0 + textureSamplingSize.height ) / 2.0, // top left
            ( 1.0 + textureSamplingSize.width ) / 2.0, ( 1.0 + textureSamplingSize.height ) / 2.0, // top right
            ( 1.0 - textureSamplingSize.width ) / 2.0, ( 1.0 - textureSamplingSize.height ) / 2.0, // bottom left
            ( 1.0 + textureSamplingSize.width ) / 2.0, ( 1.0 - textureSamplingSize.height ) / 2.0, // bottom right
        };
        
        glVertexAttribPointer( BASE_ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, passThroughTextureVertices );
        glEnableVertexAttribArray(BASE_ATTRIB_TEXTUREPOSITON );
        
        glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
        
        glBindRenderbuffer( GL_RENDERBUFFER, _colorBufferHandle );
        [_oglContext presentRenderbuffer:GL_RENDERBUFFER];
        
        glBindTexture( CVOpenGLESTextureGetTarget( texture ), 0 );
        glBindTexture( GL_TEXTURE_2D, 0 );
        CFRelease( texture );
        
        if (oldContext != _oglContext) {
            [EAGLContext setCurrentContext:oldContext];
        }
    }
}

- (void)flushPixelBufferCache
{
    if ( _textureCache ) {
        CVOpenGLESTextureCacheFlush(_textureCache, 0);
    }
}

@end
