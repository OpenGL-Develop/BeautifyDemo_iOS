//
//  MGDebugMessageView.h
//  FaceppDemo
//
//  Created by Li Bo on 2017/3/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGBeautifulConfig.h"

@interface MGDebugMessageView : UIView

@property (nonatomic, strong) MGBeautifulConfig *config;

@property (nonatomic, copy) NSString *resolution;
@property (nonatomic, copy) NSString *fps;
@property (nonatomic, copy) NSString *cpu;
@property (nonatomic, copy) NSString *memory;
@property (nonatomic, copy) NSString *totalTime;
@property (nonatomic, copy) NSString *tracking;
@property (nonatomic, copy) NSString *beautity;
@property (nonatomic, copy) NSString *sticker;


@property (nonatomic, copy) NSString *BGRA;
@property (nonatomic, copy) NSString *SDK;


/**
 更新界面
 */
- (void)updateDebugMessage;


@end
