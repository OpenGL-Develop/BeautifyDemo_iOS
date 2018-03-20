//
//  DeviceAuthManager.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface DeviceAuthManager : NSObject


+ (void)checkAuthorization:(void(^)(BOOL success))block;

@end
