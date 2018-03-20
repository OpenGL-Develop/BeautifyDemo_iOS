//
//  DeviceAuthManager.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "DeviceAuthManager.h"

@implementation DeviceAuthManager

+ (void)checkAuthorization:(void(^)(BOOL success))block{
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        {
            if (block) {
                block(NO);
            }
        }
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         
                                         if (granted) {
                                             if (block) {
                                                 block(YES);
                                             }
                                         } else {
                                             if (block) {
                                                 block(NO);
                                             }
                                         }
                                     }];
        }
            break;
        default:
        {
            if (block) {
                block(YES);
            }
        }
            break;
    }
    
}

@end
