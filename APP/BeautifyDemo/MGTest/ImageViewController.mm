//
//  ImageViewController.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/4/17.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "ImageViewController.h"
#import "GLESUtils.h"
#import "SystemUtils.h"

#import "MG_Beautify.h"
#import "MG_Sticker.h"
#import "MG_Detector.h"
#import "MG_Detect_EXT.h"
#import "MGOpenGLConfig.h"

@interface ImageViewController ()
{
    NSString *_imageName;
}
@property (assign, nonatomic) MG_BEAUTIFY_HANDLE beautifyHandle;
@property (assign, nonatomic) MG_STICKER_HANDLE stickHandle;

@property (assign, nonatomic) MG_FACE_ALGORITHM_HANDLE detectHandle;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    _imageName = @"IMG_0246.jpg";
    _imageName = @"test_01.png";


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _imageName = nil;
    [self.imageView1 setImage:nil];
    [self.imageView2 setImage:nil];
    
    mg_beautify.ReleaseHandle(self.beautifyHandle);
    mg_detector.Release(self.detectHandle);
}

- (IBAction)detectImage:(id)sender{
    UIImage *sourceImage = [UIImage imageNamed:_imageName];
    [self.imageView1 setImage:sourceImage];
    
    if (self.beautifyHandle == NULL) {
        NSLog(@"请手动初始化！");
        return;
    }
    
    unsigned char* bitMap = [self getImageRGBAData:sourceImage];
    
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_ENLARGE_EYE, 6);
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_SHRINK_FACE, 6);
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_BRIGHTNESS, 6);
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_DENOISE, 6);
    mg_beautify.SetParamProperty(_beautifyHandle, MG_BEAUTIFY_PINK, 6);
    
    GLuint srcText = [GLESUtils generateRenderTextureWidth:sourceImage.size.width height:sourceImage.size.height pixels:bitMap];
    GLuint dstText = [GLESUtils generateRenderTextureWidth:sourceImage.size.width height:sourceImage.size.height pixels:NULL];
    
    int faceCount = 0;
    MG_FACE faceArray[KMGDETECTMAXFACE];
    
    mg_detector.DetectFace(_detectHandle, sourceImage.size.width, sourceImage.size.height,
                           (unsigned char*)bitMap, faceArray, &faceCount);

    if (faceCount > KMGDETECTMAXFACE) {
        faceCount = KMGDETECTMAXFACE;
    }
    NSLog(@"人脸数量:%d", faceCount);

//    mg_beautify.ProcessTexture(_beautifyHandle, srcText, dstText, faceArray, faceCount);
    
    mg_sticker.ProcessTexture(_stickHandle, srcText, dstText, faceArray, faceCount);
    
    const int w = sourceImage.size.width;
    const int h = sourceImage.size.height;
    GLubyte* buffer = (GLubyte *) calloc(w*h*4, sizeof(GLubyte));
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
    UIImage *saveImage = [UIImage imageWithCGImage:cgImage];
    
    UIImageWriteToSavedPhotosAlbum(saveImage, nil, nil, nil);
    
    [self.imageView2 setImage:saveImage];
    
    glDeleteTextures(1, &dstText);
    glDeleteTextures(1, &srcText);
    
    
    CGContextRelease(bitmapContext);
    CGImageRelease(cgImage);
    free(buffer);
    free(bitMap);
}

- (IBAction)initSDK:(id)sender{
    
    UIImage *sourceImage = [UIImage imageNamed:_imageName];
    CGSize size = sourceImage.size;
    
    EAGLContext *oglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:oglContext];
    
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
                mg_detector.SetNormalConfig(self.detectHandle);
            }
        }else{
            NSLog(@"[mg_detector CreateApiHandle] 初始化失败，无法读取 modelData");
        }
        modelData = nil;
        modelPath = nil;
    }
    
    if (NULL == self.beautifyHandle) {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGBEAUTIFYMODELNAME ofType:@""];
        NSData *model = [NSData dataWithContentsOfFile:modelPath];
        unsigned char* sourceModel = ( unsigned char*)[model bytes];
        int sourceModelSize = (int)[model length];
        
        MG_RETCODE code = mg_beautify.CreateHandle((const unsigned char*)sourceModel,
                                                   sourceModelSize,
                                                   size.width, size.height, rotation, &_beautifyHandle);
        if (code != MG_RETCODE_OK) {
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
    
    if (NULL == self.stickHandle) {
        NSString *zipPath = [[NSBundle mainBundle] pathForResource:@"bellCat" ofType:@"zip"];
        const char *cPath = [zipPath cStringUsingEncoding:NSUTF8StringEncoding];
        
        self.stickHandle = mg_sticker.CreateHandle(self.beautifyHandle);
        mg_sticker.ChangePackage(self.stickHandle, cPath, NULL);
    }
    
    UIButton *button = sender;
    if (self.detectHandle && self.beautifyHandle) {
        [button setBackgroundColor:[UIColor greenColor]];
        [button setUserInteractionEnabled:NO];
    }else{
        [button setBackgroundColor:[UIColor redColor]];
    }
}

- (unsigned char*)getImageRGBAData:(UIImage *)image{
    
    if (image == nil){
        NSLog(@"*********Error 图片缺失，%@", image);
        return NULL;
    }
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    int width = (int)CGImageGetWidth(image.CGImage);
    int height = (int)CGImageGetHeight(image.CGImage);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
        
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
