//
//  BaseViewController.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/10/17.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)dealloc{
    [[MGNotificationManager sharedManager] removeAllObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)alertView:(NSString *)title
          message:(NSString *)message
           cancel:(NSString *)cancelStr
          handler:(void (^ __nullable)(UIAlertAction *action))handler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleDefault handler:handler];
    
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertActionSheet:(NSString *_Nullable)title
                 message:(NSString *_Nullable)message
             AlertAction:(NSArray <UIAlertAction*>*_Nullable)AlertActions
                  cancel:(NSString *_Nullable)cancelStr{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:nil];
    
    [AlertActions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [alert addAction:obj];
    }];
    
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

// 隐藏电池栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
