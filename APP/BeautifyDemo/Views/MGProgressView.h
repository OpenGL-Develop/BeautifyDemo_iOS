//
//  MGProgressView.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBarView.h"

@class MGBeautyModel;

@interface MGProgressView : BaseBarView

- (instancetype)initWithFrame:(CGRect)frame
                       Models:(MGBeautyModel *)models;




@end
