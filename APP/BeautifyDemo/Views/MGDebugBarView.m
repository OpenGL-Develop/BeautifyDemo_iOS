//
//  DebugBarView.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/9.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGDebugBarView.h"

@interface MGDebugBarView ()

@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *specialBtn;
@property (nonatomic, strong) UIButton *debugBtn;
@property (nonatomic, strong) UIButton *resolutionBtn;

@end

@implementation MGDebugBarView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat btnWidth = 35.;
        CGFloat btnHeight = btnWidth;
        CGFloat MaxWidht = CGRectGetWidth(frame);
        CGFloat offset = 5;
        
        //翻转相机按钮
        UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cameraBtn setFrame:CGRectMake(MaxWidht-btnWidth-offset-10, 0, btnWidth, btnHeight)];
        [cameraBtn setImage:[UIImage imageNamed:@"img_btn_front"] forState:UIControlStateNormal];
        [cameraBtn setImage:[UIImage imageNamed:@"img_btn_back"] forState:UIControlStateSelected];
        [cameraBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:cameraBtn];
        
        //是否美颜按钮
        UIButton *specialBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [specialBtn setFrame:CGRectMake(CGRectGetMinX(cameraBtn.frame)-offset-btnWidth, 0, btnWidth, btnHeight)];
        [specialBtn setImage:[UIImage imageNamed:@"img_btn_open_select"] forState:UIControlStateNormal];
        [specialBtn setImage:[UIImage imageNamed:@"img_btn_open_unSelect"] forState:UIControlStateSelected];
        [specialBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:specialBtn];
        
        //是否显示debug信息按钮
        UIButton *debugBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [debugBtn setFrame:CGRectMake(CGRectGetMinX(specialBtn.frame)-offset-btnWidth, 0, btnWidth, btnHeight)];
        [debugBtn setImage:[UIImage imageNamed:@"img_debug_open"] forState:UIControlStateNormal];
        [debugBtn setImage:[UIImage imageNamed:@"img_debug_close"] forState:UIControlStateSelected];
        [debugBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:debugBtn];
        
        //分辨率切换按钮
        UIButton *resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resolutionBtn setFrame:CGRectMake(CGRectGetMinX(debugBtn.frame)-offset*1.4-75, 4, 75, btnHeight-8)];
        [resolutionBtn setBackgroundColor:[UIColor whiteColor]];
        [resolutionBtn setTitle:@"1280x720" forState:UIControlStateNormal];
        [resolutionBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [resolutionBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [resolutionBtn.layer setCornerRadius:5.0];
        [self addSubview:resolutionBtn];
        
        self.cameraBtn = cameraBtn;
        self.specialBtn = specialBtn;
        self.debugBtn = debugBtn;
        self.resolutionBtn = resolutionBtn;
    }
    return self;
}

- (void)addTarget:(id)sender action:(SEL)action debugType:(DebugType)type{
    UIButton *tempBTN;
    switch (type) {
        case DebugCameraRatio:
            tempBTN = self.resolutionBtn;
            break;
        case DebugCameraReversal:
            tempBTN = self.cameraBtn;
            break;
        case DebugCG:
            tempBTN = self.specialBtn;
            break;
        case DebugMessage:
            tempBTN = self.debugBtn;
            break;
        default:
            break;
    }
    if (tempBTN) {
        [tempBTN addTarget:sender action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
