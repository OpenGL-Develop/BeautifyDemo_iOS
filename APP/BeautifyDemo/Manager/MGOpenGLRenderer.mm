

#import "MGOpenGLRenderer.h"
#import "GLESUtils.h"
#import "SystemUtils.h"

#import "MG_Beautify.h"
#import "MG_Sticker.h"
#import "MG_Detector.h"
#import "MG_Detect_EXT.h"

@interface MGOpenGLRenderer ()
{
    EAGLContext *_oglContext;
    CVOpenGLESTextureCacheRef _textureCache;
    CVOpenGLESTextureCacheRef _renderTextureCache;
    CVPixelBufferPoolRef _bufferPool;
    CFDictionaryRef _bufferPoolAuxAttributes;
    
    dispatch_queue_t _detectQueue;
    
    unsigned char *_tempBGRData;
    float *_tempSourceData;
    
    GLuint _stickerTexture;
    
    CMVideoDimensions _dstDimensions;
}

@property (assign, nonatomic) MG_BEAUTIFY_HANDLE beautifyHandle;
@property (assign, nonatomic) MG_STICKER_HANDLE stickerHandle;
@property (assign, nonatomic) MG_FACE_ALGORITHM_HANDLE detectHandle;

@property (assign, nonatomic, readonly) GLfloat videoFrameW;
@property (assign, nonatomic, readonly) GLfloat videoFrameH;


@property (copy, nonatomic) NSString *stickPath;

@end

@implementation MGOpenGLRenderer

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        _oglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if ( ! _oglContext ) {
            NSLog( @"[MGOpenGLRenderer init] Problem with OpenGL context." );
            return nil;
        }
        
        self.beautifyHandle = NULL;
        self.stickerHandle = NULL;
        self.detectHandle = NULL;
        
        _tempSourceData = NULL;
        _tempBGRData = NULL;
        
        _stickerTexture = 0;
    }
    return self;
}

#pragma mark - 内存释放 reset
- (void)dealloc
{
    [self deleteBuffers];
    _oglContext = nil;
    
    if (self.beautifyHandle != NULL) {
        mg_beautify.ReleaseHandle(self.beautifyHandle);
    }
    if (self.stickerHandle != NULL) {
        mg_sticker.ReleaseHandle(self.stickerHandle);
    }
    if (self.detectHandle != NULL) {
        mg_detector.Release(self.detectHandle);
    }
}

- (void)deleteBuffers
{
    EAGLContext *oldContext = [EAGLContext currentContext];
    if ( oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
            return;
        }
    }
    if ( _textureCache ) {
        CFRelease( _textureCache );
        _textureCache = 0;
    }
    if ( _renderTextureCache ) {
        CFRelease( _renderTextureCache );
        _renderTextureCache = 0;
    }
    if ( _bufferPool ) {
        CFRelease( _bufferPool );
        _bufferPool = NULL;
    }
    if ( _bufferPoolAuxAttributes ) {
        CFRelease( _bufferPoolAuxAttributes );
        _bufferPoolAuxAttributes = NULL;
    }
    if ( oldContext != _oglContext ) {
        [EAGLContext setCurrentContext:oldContext];
    }
}

#pragma mark - 处理视频流 每一帧数据
- (void)openglBindToVideoFrame:(CVOpenGLESTextureRef)textureRef ActiveTexture:(GLenum)texture{
    glActiveTexture(texture);
    glBindTexture(CVOpenGLESTextureGetTarget(textureRef), CVOpenGLESTextureGetName(textureRef));
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (BOOL)checkPixelBuffer:(CVPixelBufferRef)pixelBuffer{
    
    NSMutableString *tempError = [NSMutableString string];
    
    if ( pixelBuffer == NULL ) {
        [tempError appendString:@"\n NULL pixel buffer"];
    }
    
//    const CMVideoDimensions srcDimensions = {(int32_t)CVPixelBufferGetWidth(pixelBuffer), (int32_t)CVPixelBufferGetHeight(pixelBuffer)};
//    const CMVideoDimensions dstDimensions = _dstDimensions;
    
//    if ( srcDimensions.width != dstDimensions.width || srcDimensions.height != dstDimensions.height) {
//        [tempError appendString:@"\n Invalid pixel buffer dimensions"];
//    }
    
    EAGLContext *oldContext = [EAGLContext currentContext];
    if ( oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            [tempError appendString:@"\n Problem with OpenGL context"];
        }
    }
    if (tempError.length > 0) {
        //        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:tempError userInfo:nil];
        return YES;
    }
    return NO;
}

- (void)createTextureCacheFromImage:(CVPixelBufferRef )pixelBuffer
                             target:(CVOpenGLESTextureRef *)textureRef
                    textureCacheRef:(CVOpenGLESTextureCacheRef)textureCacheRef
                        textureSize:(CGSize)outSize
                              error:(NSError **)error{
    CVReturn err = noErr;
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       textureCacheRef,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       outSize.width, outSize.height,
                                                       GL_BGRA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       textureRef);
    
    if (! textureRef || err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:err
                                 userInfo:@{@"message":@"Error at CVOpenGLESTextureCacheCreateTextureFromImage"}];
    }
}

- (void)createPixelBufferWithAuxAttributes:(CVOpenGLESTextureRef *)textureRef error:(NSError **)error{
    CVReturn err = noErr;
    err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, _bufferPool, _bufferPoolAuxAttributes, textureRef);
    if (err == kCVReturnWouldExceedAllocationThreshold) {
        // Flush the texture cache to potentially release the retained buffers and try again to create a pixel buffer
        CVOpenGLESTextureCacheFlush(_renderTextureCache, 0);
        err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, _bufferPool, _bufferPoolAuxAttributes, textureRef);
    }
    if (err) {
        if (err == kCVReturnWouldExceedAllocationThreshold) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:err userInfo:@{@"message":@"Pool is out of buffers, dropping frame"}];
            NSLog( @"Pool is out of buffers, dropping frame" );
        }else{
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:err userInfo:@{@"message":@"Error at CVPixelBufferPoolCreatePixelBuffer"}];
        }
    }
}

#pragma mark - 添加 Renderer 特效
- (CVPixelBufferRef)rendered:(CVPixelBufferRef)pixelBuffer
                      config:(MGBeautifulConfig*)config{
    
    if (self.beautifyHandle == NULL || YES == config.closeALL)
        return pixelBuffer;
    
    if ([self checkPixelBuffer:pixelBuffer]) return nil;
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void* baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    int iWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int iHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    int iWidthDetect = iWidth;
    
    bool planar = CVPixelBufferIsPlanar(pixelBuffer);
    if (NO == planar) {
        size_t pow = CVPixelBufferGetBytesPerRow(pixelBuffer);
        iWidthDetect = iWidth + (pow/4.0-iWidth);
    }
    
    NSError *tempError = nil;
    CVOpenGLESTextureRef srcTexture = NULL, dstTexture = NULL;
    CVPixelBufferRef dstPixelBuffer = NULL;
    
    [self createTextureCacheFromImage:pixelBuffer target:&srcTexture
                      textureCacheRef:_textureCache
                          textureSize:CGSizeMake(iWidth, iHeight)
                                error:&tempError];
    
    [self createPixelBufferWithAuxAttributes:&dstPixelBuffer error:&tempError];
    [self createTextureCacheFromImage:dstPixelBuffer target:&dstTexture
                      textureCacheRef:_renderTextureCache
                          textureSize:CGSizeMake(_dstDimensions.width, _dstDimensions.height)
                                error:&tempError];
    
    if (tempError) {
        NSLog(@"rendered error: %@", tempError);
        return pixelBuffer;
    }
    
    [self openglBindToVideoFrame:dstTexture ActiveTexture:GL_TEXTURE0];
    [self openglBindToVideoFrame:srcTexture ActiveTexture:GL_TEXTURE1];
    
    GLuint srcTex = CVOpenGLESTextureGetName(srcTexture);
    GLuint dstTex = CVOpenGLESTextureGetName(dstTexture);
    
    MG_RETCODE retCode = MG_RETCODE_OK;
    retCode = [self startBeautify:baseAddress
                      tempTexture:srcTex sourceTexture:dstTex
                           config:config
                            width:iWidthDetect heigh:iHeight dstWidth:iWidth];
    
    if (retCode != MG_RETCODE_OK) {
        NSLog(@"pixelbuffer 渲染失败！");
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    glBindTexture(CVOpenGLESTextureGetTarget(srcTexture), 0);
    glBindTexture(CVOpenGLESTextureGetTarget(dstTexture), 0);
    
    glFlush();
    
    if (srcTexture) CFRelease(srcTexture);
    if (dstTexture) CFRelease(dstTexture);
    
    return dstPixelBuffer;
}

- (MG_RETCODE)startBeautify:(void *)baseAddress
                tempTexture:(GLuint)tempTexture sourceTexture:(GLuint)sourceTexture
                     config:(MGBeautifulConfig*)config
                      width:(int)iWidth heigh:(int)iHeight
                   dstWidth:(int)dstWidth
{
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_ENLARGE_EYE, config.eyeLevel);
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_SHRINK_FACE, config.shrinkAmount);
    
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_BRIGHTNESS, config.brightness);
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_DENOISE, config.denoiseLevel);
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_PINK, config.pinkAmount);

    double t1 = 0.0, t2 = 0.0, t3 = 0.0, t4 = 0.0;
    t1 = CACurrentMediaTime()*1000;
    
    MG_RETCODE retCode = MG_RETCODE_OK;
    
    /** 检测人脸, 在不开启贴纸，或者 美型的情况下，关闭人脸检测*/
    int faceCount = 0;
    MG_FACE faceArray[KMGDETECTMAXFACE];
    
    if ((self.stickPath != nil || config.shrinkAmount != 0 || config.eyeLevel != 0) && self.detectHandle) {
        retCode = mg_detector.DetectFace(_detectHandle, iWidth, iHeight,
                                         (unsigned char*)baseAddress, faceArray, &faceCount);
    }
        
    if (retCode != MG_RETCODE_OK) {
        NSLog(@"error: 检测人脸失败， errorCode:%d", retCode);
    }
 
    t2 = CACurrentMediaTime()*1000;
    
    if (NULL != self.stickerHandle && self.stickPath != nil) {
        retCode = mg_beautify.ProcessTexture(_beautifyHandle, tempTexture, _stickerTexture, faceArray, faceCount);
        t3 = CACurrentMediaTime()*1000;
        retCode = mg_sticker.ProcessTexture(_stickerHandle, _stickerTexture, sourceTexture, faceArray, faceCount);
    } else {
        retCode = mg_beautify.ProcessTexture(_beautifyHandle, tempTexture, sourceTexture, faceArray, faceCount);

        t3 = CACurrentMediaTime()*1000;
    }
    
    t4 = CACurrentMediaTime()*1000;
    
    if ( retCode != MG_RETCODE_OK ) {
        NSLog(@"error: mg_beautify 失败， errorCode:%d", retCode);
    }
    
    NSString *debugMessage = [NSString stringWithFormat:@"detect：%.2f ms\nbeautify:%.2f ms\nsticker:%.2f ms\nCPU:%.2f%%\nMemory:%.0fMB", t2-t1, t3-t2, t4-t3, [SystemUtils getCpuUsage], [SystemUtils usedMemory]];
    [config setDebugMessage:debugMessage];
    
    config.sticker = [NSString stringWithFormat:@"%.2fms",t4-t3];
    config.beautity = [NSString stringWithFormat:@"%.2fms",t3-t2];
    config.tracking = [NSString stringWithFormat:@"%.2fms",t2-t1];
    config.totalTime = [NSString stringWithFormat:@"%.2fms",t4-t1];
    
    return retCode;
}

#pragma mark - 设置美颜相关参数
- (void)setDeteceQueue:(dispatch_queue_t)queue{
    @synchronized (self) {
        _detectQueue = queue;
        dispatch_async(_detectQueue, ^{
            [EAGLContext setCurrentContext:_oglContext];
        });
    }
}

- (void)resetDetectFace{
    int width = 10;
    int height = 10;
    unsigned char *baseAddress = (unsigned char *)malloc(width * height * 4 * sizeof(unsigned char));
    int faceCount = 0;
    MG_FACE faceArray[KMGDETECTMAXFACE];
    
    for (int i = 0; i < 10; i++) {
        mg_detector.DetectFace(_detectHandle, width, height,
                               (unsigned char*)baseAddress, faceArray, &faceCount);
    }
}

/**
 更新滤镜
 @param imageName 滤镜名称
 */
- (void)updateFilter:(NSString *)filterPath{
    dispatch_async(_detectQueue, ^{
        const char *cPath;
        if (nil != filterPath) {
            cPath = [filterPath cStringUsingEncoding:NSUTF8StringEncoding];
        }else{
            cPath = NULL;
        }
        
        if (NULL != cPath) {
            mg_beautify.SetFilter(self.beautifyHandle, cPath);
        }else{
            mg_beautify.RemoveFilter(self.beautifyHandle);
        }
    });
}

- (void)updateSticke:(NSString *)stickePath{
    dispatch_async(_detectQueue, ^{
        
        const char *outpackage = nil;
        BOOL hasStick = [[NSFileManager defaultManager] fileExistsAtPath:stickePath];
        
        if (YES == hasStick) {
            if (NO == [self.stickPath isEqualToString:stickePath]) {
                self.stickPath = stickePath;
                const char *cPath = [self.stickPath cStringUsingEncoding:NSUTF8StringEncoding];

                mg_sticker.ChangePackage(self.stickerHandle, cPath, &outpackage);
                
                NSLog(@"zip savepath: %s", outpackage);
            }
        }else{
            self.stickPath = nil;
            mg_sticker.DisablePackage(self.stickerHandle);
        }
    });
}

- (void)prepareStickerZip:(NSString *)stickePath{
    BOOL hasStick = [[NSFileManager defaultManager] fileExistsAtPath:stickePath];
    if (YES == hasStick) {
        const char *cPath = [stickePath cStringUsingEncoding:NSUTF8StringEncoding];
        mg_sticker.PreparePackage(self.stickerHandle, cPath);
    }
}

#pragma mark - 初始化 美颜人脸 相关 SDK
/**
 设置视频图像大小，初始化或者重置 handle
 @param size 视频大小
 */
- (void)initSDKHandleWithVideoSize:(CGSize)size device:(AVCaptureDevicePosition)device{
    @synchronized (self) {
        [EAGLContext setCurrentContext:_oglContext];
        
        float needOverturn = (device == AVCaptureDevicePositionFront ? 1.0 : 0.0);

        MG_ROTATION rotation = MG_ROTATION_0;
        /** 人脸识别SDK */
        if (NULL == self.detectHandle) {
            NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGDETECTMODELNAME ofType:@""];
            NSData *modelData = [NSData dataWithContentsOfFile:modelPath];
            
            if (modelData != nil) {
                const void *modelBytes = modelData.bytes;
                MG_RETCODE initCode = mg_detector.CreateHandle((unsigned char *)modelBytes, (int)modelData.length, &_detectHandle);
                if (initCode != MG_RETCODE_OK) {
                    NSLog(@"[mg_detector CreateApiHandle] 初始化失败，modelData 与 SDK 不匹配 errorCode:%zi", initCode);
                } else {
                    MG_FPP_APICONFIG config;
                    mg_detector.GetConfig(self.detectHandle, &config);
                    config.rotation = rotation;
                    config.interval = 20;
                    config.min_face_size = 100;
                    mg_detector.SetConfig(self.detectHandle, config);
                }
            }else{
                NSLog(@"[mg_detector CreateApiHandle] 初始化失败，无法读取 modelData");
            }
        }
        /** 美颜CG SDK */
        if (NULL == self.beautifyHandle) {
            NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGBEAUTIFYMODELNAME ofType:@""];
            NSData *model = [NSData dataWithContentsOfFile:modelPath];
            unsigned char* sourceModel = (unsigned char*)[model bytes];
            int sourceModelSize = (int)[model length];
            
            MG_RETCODE code = mg_beautify.CreateHandle((const unsigned char*)sourceModel,
                                                       sourceModelSize,
                                                       size.width, size.height, rotation, &_beautifyHandle);
            
            if (code != MG_RETCODE_OK) {
                mg_beautify.UseFastFilter(_beautifyHandle, true);
                NSLog(@"MG_BEAUTIFY_HANDLE CreateHandle 失败...");
            }else{
                NSLog(@"MG_BEAUTIFY_HANDLE CreateHandle 成功！！！");
            }

        }else{
            MG_RETCODE code = mg_beautify.ResetHandle(self.beautifyHandle, size.width, size.height, rotation);
            if (code != MG_RETCODE_OK) {
                NSLog(@"MG_BEAUTIFY_HANDLE MGB_ResetHandle 失败...");
            }else{
                NSLog(@"MG_BEAUTIFY_HANDLE MGB_ResetHandle 成功！！！");
            }
        }
        
        /** 贴纸CG SDK */
        if (self.stickerHandle == NULL) {
            self.stickerHandle = mg_sticker.CreateHandle(self.beautifyHandle);
            if (NULL == self.stickerHandle) {
                NSLog(@"MG_STICKER_HANDLE CreateHandle 失败...");
            }else{
                NSLog(@"MG_STICKER_HANDLE CreateHandle 成功！！！");
            }
        }
        if (self.stickerHandle) {
            mg_sticker.SetParamProperty(self.stickerHandle, MG_STICKER_OVERTURN, needOverturn);
            
            [GLESUtils MGDeleteTexture:&_stickerTexture];
            _stickerTexture = [GLESUtils generateRenderTextureWidth:size.width height:size.height pixels:NULL];
        }
    }
}


#pragma mark - 初始化视频流缓存，设置视频流输出
- (void)prepareForInputSampleBuffer:(CMSampleBufferRef)sampleBuffer devicePosition:(AVCaptureDevicePosition)devicePosition
{
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    
    [self deleteBuffers];
    if ( ! [self initializeBuffersWithOutputDimensions:dimensions devicePosition:devicePosition] ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem preparing renderer." userInfo:nil];
    }
}

- (void)setUpOutSampleBuffer:(CGSize)outSize
              devicePosition:(AVCaptureDevicePosition)devicePosition{
    [EAGLContext setCurrentContext:_oglContext];

    CMVideoDimensions dimensions;
    dimensions.width = outSize.width;
    dimensions.height = outSize.height;
    
    [self deleteBuffers];
    if ( ! [self initializeBuffersWithOutputDimensions:dimensions devicePosition:devicePosition] ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem preparing renderer." userInfo:nil];
    }
}

- (BOOL)initializeBuffersWithOutputDimensions:(CMVideoDimensions)outputDimensions
                               devicePosition:(AVCaptureDevicePosition)device
{
    int clientRetainedBufferCountHint = 6;
    BOOL success = YES;
    EAGLContext *oldContext = [EAGLContext currentContext];
    if ( oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
            return NO;
        }
    }
    
    glDisable( GL_DEPTH_TEST );
    
    CVReturn err = CVOpenGLESTextureCacheCreate( kCFAllocatorDefault, NULL, _oglContext, NULL, &_textureCache );
    if ( err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreate %d", err );
        success = NO;
        return success;
    }
    
    err = CVOpenGLESTextureCacheCreate( kCFAllocatorDefault, NULL, _oglContext, NULL, &_renderTextureCache );
    if ( err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreate %d", err );
        success = NO;
        return success;
    }
    
    _videoFrameW = outputDimensions.width;
    _videoFrameH = outputDimensions.height;
    
    [self initSDKHandleWithVideoSize:CGSizeMake(_videoFrameW, _videoFrameH) device:device];
    
    int32_t maxRetainedBufferCount = (int32_t)clientRetainedBufferCountHint;
    _bufferPool = [GLESUtils createPixelBufferPool:_videoFrameW
                                             hight:_videoFrameH
                                       pixelFormat:kCVPixelFormatType_32BGRA
                                    maxBufferCount:maxRetainedBufferCount];
    if (! _bufferPool) {
        NSLog( @"Problem initializing a buffer pool." );
        success = NO;
        return success;
    }
    
    _bufferPoolAuxAttributes = [GLESUtils createPixelBufferPoolAuxAttributes:(int32_t)maxRetainedBufferCount];
    [GLESUtils preallocatePixelBuffersInPool:_bufferPool auxAttributes:_bufferPoolAuxAttributes];
    
    CMFormatDescriptionRef outputFormatDescription = NULL;
    CVPixelBufferRef testPixelBuffer = NULL;
    CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, _bufferPool, _bufferPoolAuxAttributes, &testPixelBuffer);
    if (! testPixelBuffer) {
        NSLog( @"Problem creating a pixel buffer." );
        success = NO;
        goto bail;
    }
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, testPixelBuffer, &outputFormatDescription);
    _dstDimensions = outputDimensions;

    CFRelease(testPixelBuffer);
    
bail:
    if ( ! success ) {
        [self deleteBuffers];
    }
    if ( oldContext != _oglContext ) {
        [EAGLContext setCurrentContext:oldContext];
    }
    return success;
}

@end
