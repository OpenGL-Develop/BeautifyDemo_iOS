//
//  segmentModel.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/27.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "BaseModel.h"

@interface segmentModel : BaseModel

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) NSInteger maxValue;


+ (instancetype)ModelWithTitle:(NSString *)title
                     maxValue:(NSInteger )maxValue
                selectedIndex:(NSInteger )selectedIndex;


@end

