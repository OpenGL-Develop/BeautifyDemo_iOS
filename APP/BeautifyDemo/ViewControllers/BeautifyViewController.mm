//
//  MarkVideoViewController.m
//  Test
//
//  Created by 张英堂 on 16/4/20.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "BeautifyViewController.h"
#import "MGOpenGLRenderer.h"
#import "SystemUtils.h"
#import "MGOpenGLView.h"
#import "MGCancelView.h"

#import "ViewFactory.h"
#import "ModelFactory.h"

#import "MGDebugMessageView.h"
#import "MGBottomBarView.h"
#import "MGDebugBarView.h"

#import "DataManager.h"
#import "FileCacheManager.h"
#import "DeviceAuthManager.h"

@interface BeautifyViewController ()<MGVideoDelegate, MGBaseBarDelegate>
{
    dispatch_queue_t _detectQueue;
}

@property (nonatomic, assign) BOOL hasVideoFormatDescription;

/** views */
@property (nonatomic, strong) MGDebugMessageView *debugView;

//
@property (nonatomic, strong) MGOpenGLView *previewView;
@property (nonatomic, strong) MGBottomBarView *bottomBarView;
@property (nonatomic, strong) MGCancelView *showView;

/** manager  */
//摄像头的初始化
@property (nonatomic, strong) MGVideoManager *videoManager;
//在摄像头中实现渲染或者动态贴纸更新
@property (nonatomic, strong) MGOpenGLRenderer *renderer;

//设置美白、磨皮和大眼相关功能
@property (nonatomic, strong) MGBeautifulConfig *beautifulConfig;
//加载贴纸 ZIP 文件内容
@property (nonatomic, strong) DataManager *dataManager;

/* models */
@property (nonatomic, strong) NSArray<MGBeautyModel *> *mainItems;

@end

@implementation BeautifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hashCode:nil];
    [self creatView];
    [self addNotifications];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.videoManager stopRunning];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkAuthorization];
}

#pragma mark - 权限检查
//检测作者的权限
- (void)checkAuthorization{
    @weakify(self)
    [DeviceAuthManager checkAuthorization:^(BOOL success) {
        @strongify(self)
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self startDetect];
            }else{
                [self showAVAuthorizationStatusDeniedAlert];
            }
        });
    }];
}

//提醒用户进行打开权限
- (void)showAVAuthorizationStatusDeniedAlert{
    [self alertView:@"提示" message:@"请在iPhone的“设置-隐私-相机”选项中，允许 Face++ 访问你的相机"
             cancel:@"确定" handler:^(UIAlertAction *action) {
                 NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                 [[UIApplication sharedApplication] openURL:url];
             }];
}

//开始初始化相机进行录制
- (void)startDetect{
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        [self.debugView.superview setHidden:NO];
        
        [self setUpCameraLayer];
        [self.videoManager startRunning];
    });
}

#pragma mark - 添加系统通知 app 进入后台时停止相机, 变为活动状态，重新启动相机
- (void)addNotifications{
    [[MGNotificationManager sharedManager] addAPPToBackNoti:self action:@selector(appEnterBackground:)];
    [[MGNotificationManager sharedManager] addAPPToBackNoti:self action:@selector(appBecomeActive:)];
}

- (void)appEnterBackground:(id)sender{
    [self.videoManager stopRunning];
}
- (void)appBecomeActive:(id)sender{
    if ([self.debugView.superview isHidden]) {
        [self checkAuthorization];
    } else {
        [self.videoManager startRunning];
    }
}

#pragma mark - Actions - 美颜贴纸事件
/**
 切换stiker
 @param zipName 贴纸 zip 名称
 */
- (void)updateSticker:(MGItemModel *)stickerModel{
    NSString *zipPath = [self downModelZip:stickerModel];
    if (zipPath) {
        [self.renderer updateSticke:zipPath];
    }
}

/**
 更新 滤镜功能
 @param imageName 滤镜名称
 */
- (void)updateFileter:(MGItemModel *)fileterModel{
    NSString *sourcePath = [FileCacheManager sourcePath:fileterModel.fileterName type:@"filter"];
    [self.renderer updateFilter:sourcePath];
}

//获取点击后 动态 贴纸 ZIP 包
- (NSString *)downModelZip:(MGItemModel *)model{
    if (model.status == DownSuccess) {
        NSString *returnString = [FileCacheManager checkZIP:model.zipName];
        if (!returnString)
            returnString = @"";
        
        return returnString;
    }
    @weakify(self)
    [self.dataManager downStickerZIP:model
                              finish:^(MGItemModel *tempModel, NSString *dstPath, BOOL error) {
                                  @strongify(self)
                                  
                                  if (!error) {
                                      dispatch_group_t group =  dispatch_group_create();
                                      dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          //准备贴图的具体位置
                                          [self.renderer prepareStickerZip:dstPath];
                                      });
                                      //创建好贴图位置后实现 选着按钮框的移动
                                      dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                                          if (self.showView && [self.showView.weightView isKindOfClass:[MGBottomItemView class]]) {
                                              MGBottomItemView *tempView = (MGBottomItemView *)self.showView.weightView;
                                              [tempView reloadCellWithIndex:tempModel.indexPath];
                                          } else {
                                              NSLog(@"error");
                                          }
                                      });
                                  }
                              }];
    return nil;
}

/**
 关闭人脸检测，美颜，贴纸功能
 @param sender sender
 */
- (void)specialBtnAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.beautifulConfig.closeALL = sender.selected;
}

/**
 切换分辨率
 @param sender
 切换当前显示的分辨率
 */
- (void)resolutionBtnAction:(UIButton *)sender{
    UIAlertAction *i1280x720 = [UIAlertAction actionWithTitle:@"1280x720" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resetResolution:AVCaptureSessionPresetiFrame1280x720];
        [sender setTitle:@"1280x720" forState:UIControlStateNormal];
    }];
    UIAlertAction *i960x540 = [UIAlertAction actionWithTitle:@"960x540" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resetResolution:AVCaptureSessionPresetiFrame960x540];
        [sender setTitle:@"960x540" forState:UIControlStateNormal];
    }];
    UIAlertAction *i640x480 = [UIAlertAction actionWithTitle:@"640x480" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resetResolution:AVCaptureSessionPreset640x480];
        [sender setTitle:@"640x480" forState:UIControlStateNormal];
    }];
    [self alertActionSheet:@"请选择分辨率" message:nil AlertAction:@[i1280x720, i960x540, i640x480] cancel:@"取消"];
}

/**
 更改相机分辨率
 @param resolution 分辨率
 */
- (void)resetResolution:(NSString *)resolution{
    //设置新的分辨率问题
    [self.videoManager stopRunning];
    
    [self.videoManager resetResolution:resolution];
    [self resetCameraSetting];
    
    [self.videoManager startRunning];
}

/**
 摄像头翻转
 @param sender sender
 */
- (void)cameraBtnAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    sender.userInteractionEnabled = NO;
    [self.videoManager stopRunning];
    
    //获取 dispatch_group 
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_notify(group, _detectQueue, ^{
        [self.renderer resetDetectFace];

        dispatch_sync(dispatch_get_main_queue(), ^{
            //前后置摄像头切换
            [self.videoManager toggleCamera];
            
            //重新设置 相机的设置
            [self resetCameraSetting];
            
            //开始录制
            [self.videoManager startRunning];
            sender.userInteractionEnabled = YES;
        });
    });
}

/**
 重置相机以及相关设置
 @param sender nil
 */
- (void)resetCameraSetting{
    [self.previewView reset];
    [self autoPreviewOrientation];
    self.hasVideoFormatDescription = NO;
}

/**
 是否显示debug信息
 @param sender
 */
- (void)debugBtnAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.debugView.hidden = sender.selected;
}

#pragma mark - Views 切换 -
- (void)showDetectView:(MGBeautyModel *)basemodel{
    CGRect rect = CGRectMake(0, MG_WIN_HEIGHT-basemodel.heightNum, MG_WIN_WIDTH, basemodel.heightNum);
    BaseBarView *baseView = [ViewFactory barViewWithModel:basemodel rect:rect];
    [baseView setDelegate:self];
    MGCancelView *cancelView = [[MGCancelView alloc] initWithWeightView:baseView];
    [cancelView addCancelTarget:self action:@selector(touchesEnded:withEvent:)];
    
    [self.view addSubview:cancelView];
    self.showView = cancelView;
    
    __block CGRect startFrame = cancelView.frame;
    CGFloat startY = startFrame.origin.y;
    startFrame.origin.y = MG_WIN_HEIGHT;
    [cancelView setFrame:startFrame];
    @weakify(self)
    [UIView animateWithDuration:KANIMATIONTIME
                     animations:^{
                         @strongify(self)
                         self.bottomBarView.alpha = 0;
                         startFrame.origin.y = startY;
                         [cancelView setFrame:startFrame];
                     } completion:^(BOOL finished) {
                         [self.bottomBarView closeTouch:NO];
                     }];
}

/**
 点击屏幕 显示控制台主页
 @param touches
 @param event
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.bottomBarView.alpha == 0) {
        @weakify(self)
        [UIView animateWithDuration:KANIMATIONTIME
                         animations:^{
                             @strongify(self)
                             
                             self.bottomBarView.alpha = 1;
                             CGRect frame = self.showView.frame;
                             frame.origin.y = MG_WIN_HEIGHT;
                             self.showView.frame = frame;
                         } completion:^(BOOL finished) {
                             @strongify(self)

                             [self.showView removeFromSuperview];
                             self.showView = nil;
                         }];
    }
}

#pragma mark - 创建 subViews -
- (void)creatView{
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;

    MGDebugBarView *debugBar = [[MGDebugBarView alloc] initWithFrame:CGRectMake(0, 20, MG_WIN_WIDTH, 35)];
    [debugBar addTarget:self action:@selector(specialBtnAction:) debugType:DebugCG];
    [debugBar addTarget:self action:@selector(debugBtnAction:) debugType:DebugMessage];
    [debugBar addTarget:self action:@selector(resolutionBtnAction:) debugType:DebugCameraRatio];
    [debugBar addTarget:self action:@selector(cameraBtnAction:) debugType:DebugCameraReversal];
    [self.view addSubview:debugBar];
    
    @weakify(self)
    CGRect bottomBarRect = CGRectMake(0, MG_WIN_HEIGHT*0.98-MG_WIN_WIDTH/4.0, MG_WIN_WIDTH, MG_WIN_WIDTH/4.0);
    self.bottomBarView = [[MGBottomBarView alloc] initWithFrame:bottomBarRect
                                                         Models:self.mainItems
                                                  selectHandler:^(MGBeautyModel *model) {
                                                      @strongify(self)
                                                      [self.bottomBarView closeTouch:YES];
                                                      [self showDetectView:model];
                                                  }];
    [self.view addSubview:self.bottomBarView];

    self.debugView = [[MGDebugMessageView alloc] init];
    [self.debugView setConfig:self.beautifulConfig];
    [self.view addSubview:self.debugView];
}

//加载图层预览
- (void)setUpCameraLayer{
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
        AVCaptureVideoOrientation currentOrientation = (AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation;
        //获取 3D 旋转布局情况
        CGAffineTransform transform =  [self.videoManager transformFromBufferOrientation:currentOrientation];
        self.previewView.transform = transform;
        
        CGRect bounds = CGRectZero;
        bounds.size = [self.view convertRect:self.view.bounds toView:self.previewView].size;
        self.previewView.bounds = bounds;
        self.previewView.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0, CGRectGetHeight(self.view.bounds)/2.0);
    }
}
#pragma mark - mgbottombarview delegate
- (void)MGBottomBarSelected:(BaseModel *)model{
    if ([model isKindOfClass:[MGBeautyModel class]]) {
        MGBeautyModel *listModel = (MGBeautyModel *)model;
        switch (listModel.beautyType) {
            case MGBeautyTrans:
                self.beautifulConfig.eyeLevel = MAX(listModel.value1, 0)*2;
                self.beautifulConfig.shrinkAmount = MAX(listModel.value2, 0)*2;
                break;
            case MGBeautyBeauty:
                self.beautifulConfig.denoiseLevel = MAX(listModel.value1, 0)*2;
                self.beautifulConfig.brightness = MAX(listModel.value2, 0)*2;
                self.beautifulConfig.pinkAmount = MAX(listModel.value3, 0)*2;
            default:
                break;
        }
    }else{
        MGItemModel *listModel = (MGItemModel *)model;
        switch (model.beautyType) {
            case MGBeautySitck:
                [self updateSticker:listModel];
                break;
            case MGBeautyFilter:
                [self updateFileter:listModel];
                break;
            default:
                break;
        }
    }
}

#pragma mark - video delegate

-(void)MGCaptureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    @synchronized(self) {
        if (![self setInputBuffer:sampleBuffer connection:connection]) {
            [self detectAndDisplaySampleBuffer:sampleBuffer];
        }
    }
}

- (void)MGCaptureOutput:(AVCaptureOutput *)captureOutput error:(NSError *)error{
    if (error.code == 101) {
        [self alertView:@"警告" message:@"错误的视频配置,该摄像头不支持该分辨率" cancel:@"完成" handler:nil];
    }
}

#pragma mark-

- (BOOL)setInputBuffer:(CMSampleBufferRef)sampleBuffer connection:(AVCaptureConnection *)connection{
    if (self.hasVideoFormatDescription == NO) {
        self.hasVideoFormatDescription = YES;
        
        [self.renderer prepareForInputSampleBuffer:sampleBuffer
                                    devicePosition:self.videoManager.devicePosition];
        return YES;
    }
    return NO;
}

/** 进入人脸检测并且美颜，贴图 */
- (void)detectAndDisplaySampleBuffer:(CMSampleBufferRef)sampleBuffer{
    @autoreleasepool {
        CMSampleBufferRef detectSampleBufferRef = NULL;
        CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &detectSampleBufferRef);
        
        @weakify(self)
        dispatch_sync(_detectQueue, ^{
            @strongify(self)
            
            CVPixelBufferRef sourcePixelBuffer = CMSampleBufferGetImageBuffer(detectSampleBufferRef);
            CVPixelBufferRef showBuffer = [self.renderer rendered:sourcePixelBuffer
                                                           config:self.beautifulConfig];
            [self.previewView displayPixelBuffer:showBuffer];
            
            if (showBuffer != sourcePixelBuffer)
                CVPixelBufferRelease(showBuffer);
            CFRelease(detectSampleBufferRef);
        
            dispatch_async(dispatch_get_main_queue(), ^{
                self.debugView.resolution = self.previewView.resolution;
                self.debugView.fps = self.previewView.fps;
                self.debugView.cpu = [NSString stringWithFormat:@"%.2f%%",[SystemUtils getCpuUsage]];
                self.debugView.memory = [NSString stringWithFormat:@"%.0fMB",[SystemUtils usedMemory]];
                
                [self.debugView updateDebugMessage];
            });
        });
    }
}

#pragma mark - hash code
- (void)hashCode:(id)sender{
    _detectQueue = dispatch_queue_create("com.megvii.detect", DISPATCH_QUEUE_SERIAL);
    
    AVCaptureDevicePosition device = AVCaptureDevicePositionFront;
    self.videoManager = [MGVideoManager videoPreset:AVCaptureSessionPreset1280x720
                                     devicePosition:device
                                        videoRecord:NO
                                         videoSound:NO];
    self.videoManager.videoDelegate = self;
    
    //获取首界面功能按钮
    self.mainItems = [ModelFactory getData];
    //美颜相关参数配置
    self.beautifulConfig = [MGBeautifulConfig defaultConfig];
    //
    self.dataManager = [DataManager sharedManager];

    //
    self.renderer = [[MGOpenGLRenderer alloc] init];
    [self.renderer setDeteceQueue:_detectQueue];
    
    //需要研究是贴纸是怎么样显示在具体界面上的。
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[MGNotificationManager sharedManager] removeAllObserver:self];
    self.renderer = nil;
    self.previewView = nil;
    self.videoManager = nil;
    self.bottomBarView = nil;
}

@end
