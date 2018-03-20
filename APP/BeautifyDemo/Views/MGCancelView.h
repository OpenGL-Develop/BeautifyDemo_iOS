//
//  MGCancelView.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/10/19.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBarView.h"

@interface MGCancelView : UIView


- (instancetype _Nullable )initWithWeightView:(BaseBarView *_Nullable)weightView;

@property (nonatomic, assign) BOOL hideCancel;

@property (nonatomic, strong) UIButton * _Nullable cancelView;

@property (nonatomic, strong) BaseBarView * _Nullable weightView;

- (void)addCancelTarget:(nullable id)target action:(SEL _Nullable )action;

@end



