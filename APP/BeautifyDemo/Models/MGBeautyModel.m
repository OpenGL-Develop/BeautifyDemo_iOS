//
//  BaseArrayModel.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/4/18.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGBeautyModel.h"
#import "YTMacro.h"

@implementation MGBeautyModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.heightNum = 1.0;
        self.value1 = 0;
    }
    return self;
}

- (void)setBeautyType:(MGBeautyType)beautyType{
    [super setBeautyType:beautyType];
    
    switch (beautyType) {
        case MGBeautyBeauty:
            self.heightNum = 1.8;
            break;
        case MGBeautyTrans:
            self.heightNum = 1.2;
            break;
        case MGBeautySitck:
            self.heightNum = 2.7;
            break;
        default:
            break;
    }
}


- (CGFloat)heightNum{
    return _heightNum * KBASEVIEWHEIGHT;
}

@end
