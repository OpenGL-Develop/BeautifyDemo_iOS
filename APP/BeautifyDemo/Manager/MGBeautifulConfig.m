//
//  MGBeautifulConfig.m
//  FaceppDemo
//
//  Created by 张英堂 on 2017/1/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGBeautifulConfig.h"
#import "SystemUtils.h"

@interface MGBeautifulConfig ()


@end

@implementation MGBeautifulConfig

+ (instancetype)defaultConfig{
    MGBeautifulConfig *config = [[MGBeautifulConfig alloc] init];
    config.brightness = 6;
    config.denoiseLevel = 6;
    config.pinkAmount = 6;
    
    config.shrinkAmount = 6;
    config.eyeLevel = 6;
    
    return config;
}



@end
