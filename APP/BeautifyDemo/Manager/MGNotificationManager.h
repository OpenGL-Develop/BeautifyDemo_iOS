//
//  MGNotificationManager.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/10/17.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MGNotificationManager : NSObject

+ (instancetype)sharedManager;


- (void)addAPPToBackNoti:(id)sender action:(SEL)action;
- (void)addAPPToActiveNoti:(id)sender action:(SEL)action;
- (void)removeAllObserver:(id)sender;

@end
