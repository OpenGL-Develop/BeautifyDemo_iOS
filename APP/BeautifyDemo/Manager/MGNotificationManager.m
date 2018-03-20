//
//  MGNotificationManager.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/10/17.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGNotificationManager.h"

@implementation MGNotificationManager

+ (instancetype)sharedManager{
    
    static MGNotificationManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MGNotificationManager alloc] init];
    });
    return manager;
}

- (void)addAPPToBackNoti:(id)sender action:(SEL)action{
    [[NSNotificationCenter defaultCenter] addObserver:sender
                                             selector:action
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)addAPPToActiveNoti:(id)sender action:(SEL)action{
    [[NSNotificationCenter defaultCenter] addObserver:sender
                                             selector:action
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeAllObserver:(id)sender{
    [[NSNotificationCenter defaultCenter] removeObserver:sender];
}

@end
