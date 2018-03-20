 //
//  SystemUtils.h
//  FaceppDemo
//
//  Created by 张英堂 on 2017/1/6.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SystemUtils : NSObject

/** 获取CPU使用率 */
+ (float)getCpuUsage;

/** 获取当前设备可用内存(单位：MB）*/
+ (double)availableMemory;

/** 获取当前任务所占用的内存（单位：MB） */
+ (double)usedMemory;

@end
