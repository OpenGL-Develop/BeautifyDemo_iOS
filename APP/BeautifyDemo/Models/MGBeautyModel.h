//
//  MGBeautyModel.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/4/18.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseModel.h"

#define KBASEVIEWHEIGHT  WIN_WIDTH/5.0+20

@class MGItemModel;
@class CancelModel;

@interface MGBeautyModel : BaseModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *iconName;

@property (nonatomic, strong) NSMutableArray *dataArray;


@property (nonatomic, assign) NSInteger value1;
@property (nonatomic, assign) NSInteger value2;
@property (nonatomic, assign) NSInteger value3;


@property (nonatomic, assign) CGFloat heightNum;


@end
