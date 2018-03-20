//
//  LeakViewController.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/7/11.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "LeakViewController.h"
#import "GLESUtils.h"
#import "SystemUtils.h"

#import "MG_Beautify.h"
#import "MG_Detector.h"
#import "MGOpenGLConfig.h"

@interface LeakViewController ()

@property (weak, nonatomic) IBOutlet UILabel *startMView;
@property (weak, nonatomic) IBOutlet UILabel *nowMView;
@end

@implementation LeakViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    float memory = [SystemUtils usedMemory];
    [self.startMView setText:[NSString stringWithFormat:@"%.2fMB", memory]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)faceppSDKAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setUserInteractionEnabled:NO];
    [self updateNowMemoryView];
    
    for (int i = 0; i < 100; i++) {
        @autoreleasepool {
            
            NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGDETECTMODELNAME ofType:@""];
            NSData *modelData = [NSData dataWithContentsOfFile:modelPath];
            MG_FACE_ALGORITHM_HANDLE detectHandle = NULL;
            
            if (modelData != nil) {
                const void *modelBytes = modelData.bytes;
                MG_RETCODE initCode = mg_detector.CreateHandle((unsigned char *)modelBytes, (int)modelData.length, &detectHandle);
                if (initCode != MG_RETCODE_OK) {
                    NSLog(@"[mg_detector CreateApiHandle] 初始化失败，modelData 与 SDK 不匹配 errorCode:%zi", initCode);
                } else {
                    MG_FPP_APICONFIG config;
                    mg_detector.GetConfig(detectHandle, &config);
                    config.rotation = MG_ROTATION_0;
                    config.detection_mode = MG_FPP_DETECTIONMODE_TRACKING_ROBUST;
                    config.min_face_size = 150;
                    config.interval = 60;
                    mg_detector.SetConfig(detectHandle, config);
                }
            }
            if (detectHandle != NULL) {
                mg_detector.Release(detectHandle);
            }
        }
    }
    
    [self updateNowMemoryView];
    [button setUserInteractionEnabled:YES];
}

- (IBAction)beautySDKAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setUserInteractionEnabled:NO];
    [self updateNowMemoryView];
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    for (int i = 0; i < 100; i++) {
        @autoreleasepool {
            MG_BEAUTIFY_HANDLE beautifyHandle = NULL;
            NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGBEAUTIFYMODELNAME ofType:@""];
            NSData *model = [NSData dataWithContentsOfFile:modelPath];
            unsigned char* sourceModel = ( unsigned char*)[model bytes];
            int sourceModelSize = (int)[model length];
            
            MG_RETCODE code = mg_beautify.CreateHandle((const unsigned char*)sourceModel,
                                                       sourceModelSize,
                                                       900, 900, MG_ROTATION_0, &beautifyHandle);
            if (code != MG_RETCODE_OK) {
                NSLog(@"MG_BEAUTIFY_HANDLE CreateHandle 失败...");
            }else{
                NSLog(@"MG_BEAUTIFY_HANDLE CreateHandle 成功！！！");
            }
            
            if (beautifyHandle != NULL) {
                mg_beautify.ReleaseHandle(beautifyHandle);
            }
        }
    }
    
    [self updateNowMemoryView];
    [button setUserInteractionEnabled:YES];
}

- (void)updateNowMemoryView{
    float memory = [SystemUtils usedMemory];
    [self.nowMView setText:[NSString stringWithFormat:@"%.2fMB", memory]];
    [self.view setNeedsDisplay];
}

@end
