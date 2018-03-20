//
//  BaseViewController.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/10/17.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EXTScope.h"
#import "MGNotificationManager.h"

@interface BaseViewController : UIViewController


- (void)alertView:(NSString *_Nullable)title
          message:(NSString *_Nullable)message
           cancel:(NSString *_Nullable)cancelStr
          handler:(void (^ __nullable)(UIAlertAction * _Nullable action))handler;


- (void)alertActionSheet:(NSString *_Nullable)title
                 message:(NSString *_Nullable)message
             AlertAction:(NSArray <UIAlertAction*>*_Nullable)AlertActions
                  cancel:(NSString *_Nullable)cancelStr;


@end
