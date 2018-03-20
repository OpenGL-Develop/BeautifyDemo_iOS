//
//  ViewFactory.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/28.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGBeautyModel.h"

#import "BaseBarView.h"
#import "MGProgressView.h"
#import "MGBottomItemView.h"


@interface ViewFactory : NSObject

+ (BaseBarView *)barViewWithModel:(MGBeautyModel *)model rect:(CGRect)rect;


@end
