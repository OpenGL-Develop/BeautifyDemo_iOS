//
//  TestVideoViewController.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/7/12.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "TestVideoViewController.h"
#import "VideoBufferReader.h"
#import "MGOpenGLView.h"
#import "MGOpenGLRenderer.h"
#import "MGBeautifulConfig.h"
#import "EXTScope.h"

@interface TestVideoViewController ()<VideoBufferReaderDelegate>
{
    dispatch_queue_t _detectQueue;

}
@property (nonatomic, assign) BOOL hasVideoFormatDescription;

@property (nonatomic, strong) VideoBufferReader *videoReader;
@property (nonatomic, strong) MGOpenGLView *previewView;
@property (nonatomic, strong) MGOpenGLRenderer *renderer;

@property (nonatomic, strong) MGBeautifulConfig *beautifulConfig;

@end

@implementation TestVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self hasdCode];
    
    [self setUpCameraLayer];
}

- (IBAction)startRender:(id)sender {
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"IMG_1903" ofType:@"mov"];
    if (videoPath == nil) {
        return;
    }
    
    [self.renderer updateSticke:[[NSBundle mainBundle] pathForResource:@"airlineStewardess" ofType:@"zip"]];

    @weakify(self)
    dispatch_async(_detectQueue, ^{
        @strongify(self)
        
        AVAsset *dstSet = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
        NSError *error = nil;
        
        [self.videoReader startReadingAsset:dstSet error:error];
        
        if (error) {
            NSLog(@"%@",error);
        }
    });
}

//加载图层预览
- (void)setUpCameraLayer
{
    if (!self.previewView) {
        self.previewView = [[MGOpenGLView alloc] initWithFrame:CGRectZero];
        [self.view insertSubview:self.previewView atIndex:0];
        
        [self autoPreviewOrientation];
    }
}

/**
 设置 视频流显示的旋转角度 每次相机更改分辨率或者切换摄像头调用
 */
- (void)autoPreviewOrientation{
    if (self.previewView) {
        CGAffineTransform transform =  CGAffineTransformIdentity;
        self.previewView.transform = transform;
        
        CGRect bounds = CGRectZero;
        bounds.size = [self.view convertRect:self.view.bounds toView:self.previewView].size;
        self.previewView.bounds = bounds;
        self.previewView.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hasdCode{
    _detectQueue = dispatch_queue_create("com.megvii.detect", DISPATCH_QUEUE_SERIAL);
    
    self.videoReader = [[VideoBufferReader alloc] initWithDelegate:self];
    
    self.beautifulConfig = [MGBeautifulConfig defaultConfig];
    
    self.renderer = [[MGOpenGLRenderer alloc] init];
    [self.renderer setDeteceQueue:_detectQueue];
    [self.renderer setUpOutSampleBuffer:CGSizeMake(404, 720) devicePosition:AVCaptureDevicePositionFront];
}

#pragma mark-
/** 进入人脸检测并且美颜，贴图 */
- (void)detectAndDisplaySampleBuffer:(CMSampleBufferRef)sampleBuffer{
    @autoreleasepool {
        
        CVPixelBufferRef sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferRef showBuffer = [self.renderer rendered:sourcePixelBuffer
                                                       config:self.beautifulConfig];
        
        [self.previewView displayPixelBuffer:showBuffer];
        
        if (showBuffer != sourcePixelBuffer)
            CVPixelBufferRelease(showBuffer);
    }
}

#pragma mark -
- (void)bufferReader:(VideoBufferReader *)reader didFinishReadingAsset:(AVAsset *)asset{
    NSLog(@"didFinishReadingAsset %@", asset);
}

- (void)bufferReader:(VideoBufferReader *)reader didGetNextVideoSample:(CMSampleBufferRef)bufferRef{
    @synchronized(self) {
        [self detectAndDisplaySampleBuffer:bufferRef];
    }
}

- (void)bufferReader:(VideoBufferReader *)reader didGetErrorRedingSample:(NSError *)error{
    NSLog(@"decoding error %@", error);
}

@end
