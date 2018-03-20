//
//  segmentModel.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/27.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "segmentModel.h"

@implementation segmentModel


+ (instancetype)ModelWithTitle:(NSString *)title
                     maxValue:(NSInteger)maxValue
                selectedIndex:(NSInteger)selectedIndex{
    segmentModel *model = [[segmentModel alloc] init];
    
    model.title = title;
    model.maxValue = maxValue;
    model.selectedIndex = selectedIndex;
    
    return model;
}

@end
