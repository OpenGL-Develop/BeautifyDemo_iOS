//
//  MGBeautifulConfig.h
//  FaceppDemo
//
//  Created by 张英堂 on 2017/1/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MGBeautifulConfig : NSObject


+ (instancetype)defaultConfig;

/**
 关闭  磨皮，美白，大眼瘦脸 功能
 */
@property (nonatomic, assign) BOOL closeALL;

@property (nonatomic, assign) NSInteger denoiseLevel;
@property (nonatomic, assign) NSInteger brightness;
@property (nonatomic, assign) NSInteger pinkAmount;

@property (nonatomic, assign) NSInteger eyeLevel;
@property (nonatomic, assign) NSInteger shrinkAmount;



/**
 debug信息
 */
@property (nonatomic, copy) NSString *debugMessage;

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


@end


