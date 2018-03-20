//
//  ViewFactory.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/28.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "ViewFactory.h"

@implementation ViewFactory

+ (BaseBarView *)barViewWithModel:(MGBeautyModel *)model rect:(CGRect)rect{
    BaseBarView *baseView;

    switch (model.beautyType) {
        case MGBeautyTrans:
        case MGBeautyBeauty:
        {
            baseView = [[MGProgressView alloc] initWithFrame:rect
                                                      Models:model];
        }
            break;
            case MGBeautySitck:
        {
            baseView = [[MGBottomItemView alloc] initWithFrame:rect
                                                        Models:model
                                                     direction:UICollectionViewScrollDirectionVertical];
        }
            break;
        default:
        {
            baseView = [[MGBottomItemView alloc] initWithFrame:rect
                                                        Models:model
                                                     direction:UICollectionViewScrollDirectionHorizontal];
        }
            break;
    }
    return baseView;
}


@end
