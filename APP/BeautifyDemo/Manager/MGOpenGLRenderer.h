

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MGOpenGLConfig.h"
#import "MGBeautifulConfig.h"


@interface MGOpenGLRenderer : NSObject

@property (assign, nonatomic) BOOL canBudySeg;

/**
 设置输出参数
 @param sampleBuffer A CMSampleBuffer object containing the audio samples and additional information about them, such as their format and presentation time.
 
 */
- (void)prepareForInputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                     devicePosition:(AVCaptureDevicePosition)devicePosition;

- (void)setUpOutSampleBuffer:(CGSize)outSize
              devicePosition:(AVCaptureDevicePosition)devicePosition;

- (void)setDeteceQueue:(dispatch_queue_t)queue;


- (void)resetDetectFace;

/**
 渲染视频流图像

 @param pixelBuffer 视频流 pixelBuffer
 @param config config
 @return 渲染后的视频流图像，已经与原来的不同
 */
- (CVPixelBufferRef)rendered:(CVPixelBufferRef)pixelBuffer
                      config:(MGBeautifulConfig*)config;

/**
 更新贴纸
 
 @param stickePath 贴纸资源名称
 */
- (void)updateSticke:(NSString *)stickePath;


/**
 更新滤镜
 
 @param filterName 滤镜名称
 */
- (void)updateFilter:(NSString *)filterPath;


- (void)prepareStickerZip:(NSString *)stickePath;


@end
