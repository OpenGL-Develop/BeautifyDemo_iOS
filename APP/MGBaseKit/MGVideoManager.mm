//
//  MGVideoManager.m
//  MGLivenessDetection
//
//  Created by 张英堂 on 16/3/31.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGVideoManager.h"
#import "MGMovieRecorder.h"

//屏幕宽度 （区别于viewcontroller.view.fream）
#define MG_WIN_WIDTH  [UIScreen mainScreen].bounds.size.width
//屏幕高度 （区别于viewcontroller.view.fream）
#define MG_WIN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MGVideoManager ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, MovieRecorderDelegate>
{
    AVCaptureConnection *_audioConnection;
    AVCaptureConnection *_videoConnection;
    NSDictionary *_audioCompressionSettings;
    AVCaptureDevice *_videoDevice;
    
    dispatch_queue_t _videoQueue;
}

@property(nonatomic, assign) CMFormatDescriptionRef outputAudioFormatDescription;
//@property(nonatomic, assign) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, copy) NSString *sessionPreset;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property(nonatomic, copy) NSString *tempVideoPath;

@property (nonatomic, strong) MGMovieRecorder *movieRecorder;

@property (nonatomic, assign) BOOL videoRecord;
@property (nonatomic, assign) BOOL videoSound;
@property (nonatomic, assign) BOOL startRecord;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;

@end

@implementation MGVideoManager

-(void)dealloc{
    self.movieRecorder = nil;
    _audioConnection = nil;
    _videoConnection = nil;
    self.videoDelegate = nil;
    self.sessionPreset = nil;
}

-(instancetype)initWithPreset:(NSString *)sessionPreset
               devicePosition:(AVCaptureDevicePosition)devicePosition
                  videoRecord:(BOOL)record
                   videoSound:(BOOL)sound{
    self = [super init];
    if (self) {
        self.sessionPreset = sessionPreset;
        _devicePosition = devicePosition;
        self.videoRecord = record;
        self.videoSound = sound;
        
        _startRecord = NO;
        _videoQueue = dispatch_queue_create("com.megvii.face.video", NULL);
    }
    return self;
}

+ (instancetype)videoPreset:(NSString *)sessionPreset
             devicePosition:(AVCaptureDevicePosition)devicePosition
                videoRecord:(BOOL)record
                 videoSound:(BOOL)sound{
    
    MGVideoManager *manager = [[MGVideoManager alloc] initWithPreset:sessionPreset
                                                      devicePosition:devicePosition
                                                         videoRecord:record
                                                          videoSound:sound];
    return manager;
}

#pragma mark - video 功能开关
- (void)stopRunning{
    if (self.videoSession) {
        [self.videoSession stopRunning];
    }
}

- (void)startRunning{
    [self initialSession];
    
    if (self.videoSession) {
        [self.videoSession startRunning];
    }
}
- (void)startRecording{
    [self startRunning];
    
    if (!self.videoRecord) {
        return;
    }
    _startRecord = YES;
}

- (NSString *)stopRceording{
    _startRecord = NO;
    
    if (self.movieRecorder) {
        if (self.movieRecorder.status == MovieRecorderStatusRecording) {
            [self.movieRecorder finishRecording];
        }
        self.movieRecorder = nil;
    }
    
    NSString *tempString = _tempVideoPath ? _tempVideoPath :@"no video!";
    return tempString;
}

#pragma mark - 初始化video配置
- (NSString *)sessionPreset{
    if (nil == _sessionPreset) {
        _sessionPreset = AVCaptureSessionPreset640x480;
    }
    return _sessionPreset;
}

-(AVCaptureVideoPreviewLayer *)videoPreviewLayer{
    if (nil == _videoPreviewLayer) {
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.videoSession];
        [_videoPreviewLayer setFrame:CGRectMake(0, 0, MG_WIN_WIDTH, MG_WIN_HEIGHT)];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _videoPreviewLayer;
}

-(AVCaptureVideoPreviewLayer *)videoPreview{
    return self.videoPreviewLayer;
}
-(BOOL)videoSound{
    if (_videoRecord && _videoSound) {
        return YES;
    }
    return NO;
}

//- (CMFormatDescriptionRef)formatDescription{
//    return self.outputVideoFormatDescription;
//}

- (dispatch_queue_t)getVideoQueue{
    return _videoQueue;
}

//初始化相机
- (void) initialSession
{
    if (self.videoSession == nil) {

        /* session */
        _videoSession = [[AVCaptureSession alloc] init];
        
        /* 摄像头 */
        _videoDevice = [self cameraWithPosition:self.devicePosition];
        [self setMaxVideoFrame:60 videoDevice:_videoDevice];
        
        /* input */
        NSError *DeviceError;
        _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&DeviceError];
        if (DeviceError) {
            [self videoError:DeviceError];
            return;
        }
        if ([self.videoSession canAddInput:self.videoInput]) {
            [self.videoSession addInput:self.videoInput];
        }
        
        /* output */
        _output = [[AVCaptureVideoDataOutput alloc] init];
        [_output setSampleBufferDelegate:self queue:_videoQueue];
        _output.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        _output.alwaysDiscardsLateVideoFrames = NO;
        
        if ([self.videoSession canAddOutput:_output]) {
            [self.videoSession addOutput:_output];
        }
        
        /* sessionPreset */
        //设置 录制的 分辨率
        if ([self.videoSession canSetSessionPreset:self.sessionPreset]) {
            [self.videoSession setSessionPreset: self.sessionPreset];
        }else{
            NSError *presetError = [NSError errorWithDomain:NSCocoaErrorDomain code:101 userInfo:@{@"sessionPreset":@"不支持的sessionPreset!"}];
            [self videoError:presetError];
            return;
        }
        
        //设置录制屏幕 横向 & 纵向 方式
        _videoConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
        [_videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//        [_videoConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
//        [_videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
//        [_videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        
        self.videoOrientation = _videoConnection.videoOrientation;

        /* 设置声音 */
        if (self.videoSound) {
            AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
            if ( [self.videoSession canAddInput:audioIn] ) {
                [self.videoSession addInput:audioIn];
            }
            
            AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
            dispatch_queue_t audioCaptureQueue = dispatch_queue_create("com.megvii.audio", DISPATCH_QUEUE_SERIAL );
            [audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
            
            if ( [self.videoSession canAddOutput:audioOut] ) {
                [self.videoSession addOutput:audioOut];
            }
            _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
            _output.alwaysDiscardsLateVideoFrames = YES;
            
            _audioCompressionSettings = [[audioOut recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie] copy];
        }
    }
}

//初始化录制记录
- (void)initVideoRecord:(CMFormatDescriptionRef)formatDescription{
    if (self.movieRecorder == nil) {
        
        NSString *moveName = [NSString stringWithFormat:@"%@.mov", [[NSDate date] description]];
        _tempVideoPath = [NSString pathWithComponents:@[NSTemporaryDirectory(), moveName]];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:_tempVideoPath];
        
        self.movieRecorder = [[MGMovieRecorder alloc] initWithURL:url];
        
        CGAffineTransform videoTransform = [self transformFromBufferOrientation:AVCaptureVideoOrientationPortrait];
        
        [self.movieRecorder addVideoTrackWithSourceFormatDescription:formatDescription
                                                           transform:videoTransform
                                                            settings:nil];
        
        dispatch_queue_t callbackQueue = dispatch_queue_create("com.megvii.recordercallback", DISPATCH_QUEUE_SERIAL);
        [self.movieRecorder setDelegate:self callbackQueue:callbackQueue];
        
        if (self.videoSound) {
            [self.movieRecorder addAudioTrackWithSourceFormatDescription:self.outputAudioFormatDescription settings:_audioCompressionSettings];
        }
    }
}

//前后摄像头
//通过 AVCaptureDevice 的 AVMediaTypeVideo 来获取摄像头硬件相关参数
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//前后摄像头的切换
- (void)toggleCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        AVCaptureDevice *tempDevice;
        if (position == AVCaptureDevicePositionBack) {
            tempDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }else if (position == AVCaptureDevicePositionFront) {
            tempDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }else {
            tempDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        
        newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:tempDevice error:&error];

        if (error) {
            return;
        }
        
        
        [self.videoSession beginConfiguration];
        [self.videoSession removeInput:self.videoInput];
        if ([self.videoSession canAddInput:newVideoInput]) {
            [self.videoSession addInput:newVideoInput];
            _videoInput = newVideoInput;
            _videoDevice = tempDevice;
            _devicePosition = _videoDevice.position;
        } else {
            [self.videoSession addInput:self.videoInput];
        }
        
        
        /* output */
        [self.videoSession removeOutput:_output];
        _output = [[AVCaptureVideoDataOutput alloc] init];
        [_output setSampleBufferDelegate:self queue:_videoQueue];
        _output.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        _output.alwaysDiscardsLateVideoFrames = NO;
        if ([self.videoSession canAddOutput:_output]) {
            [self.videoSession addOutput:_output];
        }
        
        /* sessionPreset */
        if ([self.videoSession canSetSessionPreset:self.sessionPreset]) {
            [self.videoSession setSessionPreset: self.sessionPreset];
        }else{
            NSError *presetError = [NSError errorWithDomain:NSCocoaErrorDomain code:101 userInfo:@{@"sessionPreset":@"不支持的sessionPreset!"}];
            [self videoError:presetError];
            return;
        }
        
        _videoConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
        [_videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//        self.videoOrientation = _videoConnection.videoOrientation;
        
        [self.videoSession commitConfiguration];

    }
}

//分辨率切换
- (void)resetResolution:(NSString *)resolution{
    [self.videoSession beginConfiguration];
    /* sessionPreset */
    if ([self.videoSession canSetSessionPreset:resolution]) {
        self.sessionPreset = resolution;
        [self.videoSession setSessionPreset:self.sessionPreset];
    }else{
        NSError *presetError = [NSError errorWithDomain:NSCocoaErrorDomain code:101 userInfo:@{@"sessionPreset":@"不支持的sessionPreset!"}];
        [self videoError:presetError];
        return;
    }
    
    [self.videoSession commitConfiguration];
}

// 设置 视频最大帧率
- (void)setMaxVideoFrame:(NSInteger)frame videoDevice:(AVCaptureDevice *)videoDevice{
    for(AVCaptureDeviceFormat *vFormat in [videoDevice formats])
    {
        CMFormatDescriptionRef description= vFormat.formatDescription;
        AVFrameRateRange *rateRange = (AVFrameRateRange*)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0];
        float maxrate = rateRange.maxFrameRate;
        
        if(maxrate >= frame && CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        {
            if (YES == [videoDevice lockForConfiguration:NULL])
            {
                //设置在录像时的帧率 20-60 帧/s
                videoDevice.activeFormat = vFormat;
                [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1,frame/3)];
                [videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1,frame)];
                [videoDevice unlockForConfiguration];
            }
        }
    }
}

//录像功能
- (void)appendVideoBuffer:(CMSampleBufferRef)pixelBuffer
{
    @synchronized(self){
        CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(pixelBuffer);
        
        if (_startRecord == YES) {
            if (self.movieRecorder == nil) {
                
                //初始话 record 记录
                [self initVideoRecord:formatDescription];
                [self.movieRecorder prepareToRecord];
            }
            //对当前帧进行 赋值
            [self.movieRecorder appendVideoSampleBuffer:pixelBuffer];
        }
    }
}

- (void)appendAudioBuffer:(CMSampleBufferRef)sampleBuffer{
    if (self.videoSound) {
        
        if (!self.outputAudioFormatDescription) {
            CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
            self.outputAudioFormatDescription = formatDescription;
        }
        
        if (!self.movieRecorder) {
            return;
        }
        @synchronized(self){
            [self.movieRecorder appendAudioSampleBuffer:sampleBuffer];
        }
    }
}

- (CGAffineTransform)transformFromBufferOrientation:(AVCaptureVideoOrientation)orientation
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGFloat orientationAngleOffset = MGAngleOffsetFromPortraitOrientationToOrientation(orientation);
    CGFloat videoOrientationAngleOffset = MGAngleOffsetFromPortraitOrientationToOrientation(self.videoOrientation);
    
    CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    transform = CGAffineTransformMakeRotation(angleOffset);
    //    transform = CGAffineTransformRotate(transform, -M_PI);
    
    if (_devicePosition == AVCaptureDevicePositionFront) {
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    return transform;
}

#pragma mark - delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    //创建内存释放池 防止在录制过程中内存过大
    @autoreleasepool {
        if (connection == _videoConnection)
        {
//            CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
//            if (self.outputVideoFormatDescription == nil) {
//                self.outputVideoFormatDescription = formatDescription;
//            }
            //传递采集到的数据传递给 BeautityVC 进行 视频每一帧的操作
            if (self.videoDelegate) {
                [self.videoDelegate MGCaptureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
            }
            
            if (self.videoRecord && _startRecord) {
                //实现视频输出
                [self appendVideoBuffer:sampleBuffer];
            }
        }else if (connection == _audioConnection){
            //实现音频文件输出
            [self appendAudioBuffer:sampleBuffer];
        }
    }
}

#pragma mark - recorder delegate
- (void)movieRecorder:(MGMovieRecorder *)recorder didFailWithError:(NSError *)error{
    NSLog(@"Recorder error:%@", error);
}
- (void)movieRecorderDidFinishPreparing:(MGMovieRecorder *)recorder{
    NSLog(@"Recorder Preparing");
}
-(void)movieRecorderDidFinishRecording:(MGMovieRecorder *)recorder{
    NSLog(@"Recorder finish");
}


#pragma mark - 视频流出错，抛出异常
- (void)videoError:(NSError *)error{
    if (self.videoDelegate && error) {
        [self.videoDelegate MGCaptureOutput:nil error:error];
    }
}

@end
