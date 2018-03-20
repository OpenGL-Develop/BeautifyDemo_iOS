//
//  BeautifyDemoTests.m
//  BeautifyDemoTests
//
//  Created by 张英堂 on 2017/5/18.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MGOpenGLConfig.h"

#import "MG_Beautify.h"
#import "MG_Sticker.h"

#import "GLESUtils.h"

@interface BeautifyDemoTests : XCTestCase

@property (strong, nonatomic) UIImage *testImage;

@property (assign, nonatomic) MG_BEAUTIFY_HANDLE beautifyHandle;
@property (assign, nonatomic) MG_STICKER_HANDLE stickerHandle;

@end

@implementation BeautifyDemoTests

- (void)setUp {
    [super setUp];
    sleep(1);
    
    EAGLContext *oglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:oglContext];

    self.testImage = [UIImage imageNamed:@"IMG_0246.jpg"];
    CGSize size = self.testImage.size;
    
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGBEAUTIFYMODELNAME ofType:@""];
    NSData *model = [NSData dataWithContentsOfFile:modelPath];
    unsigned char* sourceModel = ( unsigned char*)[model bytes];
    int sourceModelSize = (int)[model length];
    
    MG_RETCODE code = mg_beautify.CreateHandle((const unsigned char*)sourceModel,
                                               sourceModelSize,
                                               size.width, size.height, MG_ROTATION_0, &_beautifyHandle);
    XCTAssertTrue(code == MG_RETCODE_OK, @"mg_beautify.CreateHandle error!");
    self.stickerHandle = nil;
    self.stickerHandle = mg_sticker.CreateHandle(self.beautifyHandle);
    XCTAssertTrue(self.stickerHandle != nil, @"mg_sticker.CreateHandle error!");
    
}

- (void)tearDown {
    [super tearDown];
    
    MG_RETCODE retcode = MG_RETCODE_OK;
    if (self.beautifyHandle) {
        retcode = mg_beautify.ReleaseHandle(self.beautifyHandle);
    }
    XCTAssertTrue(retcode == MG_RETCODE_OK, @"mg_beautify.ReleaseHandle error!");
    
    if (self.stickerHandle) {
        retcode = mg_sticker.ReleaseHandle(self.stickerHandle);
    }
    XCTAssertTrue(retcode == MG_RETCODE_OK, @"mg_sticker.ReleaseHandle error!");
}


- (void)testSetParamter{
    MG_RETCODE code = mg_beautify.SetParamProperty(self.beautifyHandle, MG_BEAUTIFY_ENLARGE_EYE, 10);
    XCTAssertTrue(code == MG_RETCODE_OK, @"mg_beautify.SetParamProperty error!");
    
    code = mg_beautify.SetParamProperty(self.beautifyHandle, MG_BEAUTIFY_SHRINK_FACE, 20);
    XCTAssertTrue(code == MG_RETCODE_OK, @"mg_beautify.SetParamProperty error!");
    
    code = mg_beautify.SetParamProperty(self.beautifyHandle, MG_BEAUTIFY_BRIGHTNESS, 10);
    XCTAssertTrue(code == MG_RETCODE_OK, @"mg_beautify.SetParamProperty error!");
    
    code = mg_beautify.SetParamProperty(self.beautifyHandle, MG_BEAUTIFY_DENOISE, 10);
    XCTAssertTrue(code == MG_RETCODE_OK, @"mg_beautify.SetParamProperty error!");
    
    code = mg_beautify.SetParamProperty(self.beautifyHandle, MG_BEAUTIFY_PINK, 10);
    XCTAssertTrue(code == MG_RETCODE_OK, @"mg_beautify.SetParamProperty error!");

    code = mg_sticker.SetParamProperty(self.stickerHandle, MG_STICKER_OVERTURN, 100);
    XCTAssertTrue(code == MG_RETCODE_OK, @"mg_sticker.SetParamProperty error!");
}

- (void)testProcess{
    
    unsigned char *bitmap = [BeautifyDemoTests getImageRGBAData:self.testImage];
    
    GLuint srcText = [GLESUtils generateRenderTextureWidth:self.testImage.size.width height:self.testImage.size.height pixels:bitmap];
    GLuint dstText = [GLESUtils generateRenderTextureWidth:self.testImage.size.width height:self.testImage.size.height pixels:NULL];
    
    int faceCount = 0;
    MG_FACE faceArray[1];
    MG_RETCODE code = mg_beautify.ProcessTexture(self.beautifyHandle, srcText, dstText, faceArray, faceCount);
    XCTAssertTrue(code == MG_RETCODE_OK, @"mg_beautify.ProcessTexture error!");
    
    code = mg_sticker.ProcessTexture(self.stickerHandle, srcText, dstText, faceArray, faceCount);
    XCTAssertTrue(code == MG_RETCODE_OK, @"mg_sticker.ProcessTexture error!");
    
    glDeleteTextures(1, &dstText);
    glDeleteTextures(1, &srcText);

    free(bitmap);
}

- (void)testOther{
    const char *beautifyVersion = mg_beautify.GetApiVersion();
    XCTAssertTrue(beautifyVersion != nil, @"mg_beautify.GetApiVersion error!");
    
    
    
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssertTrue and related functions to verify your tests produce the correct results.
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

+ (unsigned char*)getImageRGBAData:(UIImage *)image{
    if (image == nil){
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
