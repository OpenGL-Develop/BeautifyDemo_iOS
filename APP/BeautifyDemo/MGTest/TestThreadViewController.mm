//
//  TestThreadViewController.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/22.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "TestThreadViewController.h"
#import "GLESUtils.h"
#import "SystemUtils.h"

#import "MG_Beautify.h"
#import "MG_Detector.h"
#import "MG_Detect_EXT.h"
#import "MGOpenGLConfig.h"
#import <GLKit/GLKit.h>
#import "MGOpenGLView.h"

@interface TestThreadViewController ()
{
    dispatch_queue_t _detectQueue;
    unsigned char* _tempBitData;
    NSString *_imageName;
    CGSize _tempSize;
    
    dispatch_queue_t _detectQueue2;
    unsigned char* _tempBitData2;
    NSString *_imageName2;
    CGSize _tempSize2;
}
@property (nonatomic, strong) EAGLContext *context;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSTimer *mainTimer;
@property (nonatomic, strong) NSTimer *mainTimer2;

@property (assign, nonatomic) MG_FACE_ALGORITHM_HANDLE detectHandle;
@property (assign, nonatomic) MG_FACE_ALGORITHM_HANDLE detectHandle2;
@property (assign, nonatomic) MG_BEAUTIFY_HANDLE beautifyHandle;


@end

@implementation TestThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    
    _detectQueue = dispatch_queue_create("com.megvii.detect", DISPATCH_QUEUE_SERIAL);
    _imageName = @"IMG_0246.jpg";
    self.mainTimer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(detectImage:) userInfo:nil repeats:YES];
    
    
    _detectQueue2 = dispatch_queue_create("com.megvii.detect", DISPATCH_QUEUE_SERIAL);
    _imageName2 = @"IMG_0246.jpg";
    self.mainTimer2 = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(detectImage2:) userInfo:nil repeats:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.mainTimer invalidate];
    [self.mainTimer2 invalidate];
}


-(void)dealloc{
    if (_tempBitData != NULL) {
        free(_tempBitData);
    }
    if (_tempBitData2 != NULL) {
        free(_tempBitData2);
    }
    self.mainTimer = nil;
    self.mainTimer2 = nil;
    
    mg_detector.Release(self.detectHandle);
    mg_detector.Release(self.detectHandle2);
    mg_beautify.ReleaseHandle(self.beautifyHandle);
}

- (void)detectImage2:(id)sender{
    
    dispatch_async(_detectQueue2, ^{
        [EAGLContext setCurrentContext:self.context];

        if (_detectHandle2 != nil) {
           
            mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_ENLARGE_EYE, 1);
            mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_SHRINK_FACE, 1);
            mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_BRIGHTNESS, 10);
            mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_DENOISE, 10);
            mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_PINK, 10);
            
            GLuint fbo = 0;
            glGenFramebuffers(1, &fbo);
            glBindFramebuffer(GL_FRAMEBUFFER, fbo);
            
            GLuint srcText = [GLESUtils generateRenderTextureWidth:_tempSize2.width height:_tempSize2.height
                                                            pixels:_tempBitData2];
            GLuint dstText = [GLESUtils generateRenderTextureWidth:_tempSize2.width height:_tempSize2.height
                                                            pixels:NULL];

            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, dstText, 0);

            int faceCount = 0;
            MG_FACE faceArray[KMGDETECTMAXFACE];
            
            mg_detector.DetectFace(_detectHandle2, _tempSize2.width, _tempSize2.height,
                                   (unsigned char*)_tempBitData2, faceArray, &faceCount);
            
            if (faceCount == 0 || faceCount > 1) {
                NSLog(@"人脸数量:%d __%@", faceCount,  [NSThread currentThread]);
            }
            
            mg_beautify.ProcessTexture(_beautifyHandle, srcText, dstText, faceArray, faceCount);
            glFinish();
            
            const int w = _tempSize2.width;
            const int h = _tempSize2.height;
            GLubyte* buffer = (GLubyte *)calloc(w*h*4, sizeof(GLubyte));
            glReadPixels(0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef bitmapContext = CGBitmapContextCreate(
                                                               buffer,
                                                               w,
                                                               h,
                                                               8, // bitsPerComponent
                                                               4*w, // bytesPerRow
                                                               colorSpace,
                                                               kCGImageAlphaNoneSkipLast);
            CFRelease(colorSpace);
            
            CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIImage *saveImage = [UIImage imageWithCGImage:cgImage];
                [self.imageView setImage:saveImage];
            });
            CGImageRelease(cgImage);
            CGContextRelease(bitmapContext);
            free(buffer);
            
            //    UIImageWriteToSavedPhotosAlbum(saveImage, nil, nil, nil);
            glDeleteTextures(1, &srcText);
            glDeleteTextures(1, &dstText);
            
            if (fbo != 0) {
                glDeleteFramebuffers(1, &fbo);
            }
        }else{
            
        }
    });
}

- (void)detectImage:(id)sender{
    
    dispatch_async(_detectQueue, ^{
        
        int faceCount = 0;
        MG_FACE faceArray[KMGDETECTMAXFACE];
        
        mg_detector.DetectFace(_detectHandle, _tempSize.width, _tempSize.height,
                               (unsigned char*)_tempBitData, faceArray, &faceCount);
        if (faceCount == 0 || faceCount > 1) {
            NSLog(@"error1!!! %d -%@", faceCount, [NSThread currentThread]);
        }
    });
}

- (IBAction)initSDK:(id)sender {
    UIImage *sourceImage = [UIImage imageNamed:_imageName];
    _tempSize = sourceImage.size;
    
    MG_ROTATION  rotation = MG_ROTATION_0;
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
                config.detection_mode = MG_FPP_DETECTIONMODE_TRACKING_ROBUST;
                config.min_face_size = 150;
                config.interval = 60;
                mg_detector.SetConfig(self.detectHandle, config);
            }
        }else{
            NSLog(@"[mg_detector CreateApiHandle] 初始化失败，无法读取 modelData");
        }
    }
    
    UIButton *button = sender;
    if (self.detectHandle) {
        [button setBackgroundColor:[UIColor greenColor]];
        [button setUserInteractionEnabled:NO];
    }else{
        [button setBackgroundColor:[UIColor redColor]];
    }
    
    _tempBitData = [self getImageRGBAData:sourceImage];
    
    [[NSRunLoop mainRunLoop] addTimer:self.mainTimer forMode:NSDefaultRunLoopMode];
    [self.mainTimer fire];
}

- (IBAction)initSDK2:(id)sender {
    dispatch_async(_detectQueue2, ^{
        [EAGLContext setCurrentContext:self.context];
        
        UIImage *sourceImage = [UIImage imageNamed:_imageName2];
        _tempSize2 = sourceImage.size;
        
        MG_ROTATION  rotation = MG_ROTATION_0;
        if (NULL == self.detectHandle2) {
            NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGDETECTMODELNAME ofType:@""];
            NSData *modelData = [NSData dataWithContentsOfFile:modelPath];
            
            if (modelData != nil) {
                const void *modelBytes = modelData.bytes;
                MG_RETCODE initCode = mg_detector.CreateHandle((unsigned char *)modelBytes, (int)modelData.length, &_detectHandle2);
                if (initCode != MG_RETCODE_OK) {
                    NSLog(@"[mg_detector CreateApiHandle2] 初始化失败，modelData 与 SDK 不匹配 errorCode:%zi", initCode);
                } else {
                    MG_FPP_APICONFIG config;
                    mg_detector.GetConfig(self.detectHandle2, &config);
                    config.rotation = rotation;
                    config.detection_mode = MG_FPP_DETECTIONMODE_NORMAL;
                    config.min_face_size = 100;
                    mg_detector.SetConfig(self.detectHandle2, config);
                }
            }else{
                NSLog(@"[mg_detector CreateApiHandle2] 初始化失败，无法读取 modelData");
            }
        }
        if (NULL == self.beautifyHandle) {
            NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGBEAUTIFYMODELNAME ofType:@""];
            NSData *model = [NSData dataWithContentsOfFile:modelPath];
            unsigned char* sourceModel = ( unsigned char*)[model bytes];
            int sourceModelSize = (int)[model length];
            
            MG_RETCODE code = mg_beautify.CreateHandle((const unsigned char*)sourceModel,
                                                       sourceModelSize,
                                                       _tempSize2.width, _tempSize2.height, rotation, &_beautifyHandle);
            if (code != MG_RETCODE_OK) {
                NSLog(@"MG_BEAUTIFY_HANDLE CreateHandle 失败... %d", code);
            }else{
                NSLog(@"MG_BEAUTIFY_HANDLE CreateHandle 成功！！！");
            }
        }else{
            MG_RETCODE code = mg_beautify.ResetHandle(self.beautifyHandle, _tempSize2.width, _tempSize2.height, rotation);
            if (code != MG_RETCODE_OK) {
                NSLog(@"MG_BEAUTIFY_HANDLE MGB_ResetHandle 失败...");
            }else{
                NSLog(@"MG_BEAUTIFY_HANDLE MGB_ResetHandle 成功！！！");
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIButton *button = sender;
            if (self.detectHandle2) {
                [button setBackgroundColor:[UIColor greenColor]];
                [button setUserInteractionEnabled:NO];
            }else{
                [button setBackgroundColor:[UIColor redColor]];
            }
        });
    
        _tempBitData2 = [self getImageRGBAData:sourceImage];
        
        [[NSRunLoop mainRunLoop] addTimer:self.mainTimer2 forMode:NSDefaultRunLoopMode];
        [self.mainTimer2 fire];
    });
}

- (unsigned char*)getImageRGBAData:(UIImage *)image{
    if (image == nil){
        NSLog(@"*********Error 图片缺失，%@", image);
        return NULL;
    }
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    int width = (int)CGImageGetWidth(image.CGImage);
    int height = (int)CGImageGetHeight(image.CGImage);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    unsigned char* bitmapData = (uint8_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //Create bitmap context
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);	// RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Error Bitmap context not created \n");
    }
    CGRect rect = CGRectMake(0, 0, width, height);
    
    
    CGContextDrawImage(context, rect, image.CGImage);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return bitmapData;
}


@end
