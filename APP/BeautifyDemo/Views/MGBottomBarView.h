//
//  MGBottomBarView.h
//  FaceppDemo
//
//  Created by Li Bo on 2017/3/22.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGBeautyModel.h"

typedef void(^MGBottomBarSelectAtIndexPath)(MGBeautyModel *listModel);


@interface MGBottomBarView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                       Models:(NSArray *)models
                 selectHandler:(MGBottomBarSelectAtIndexPath)selectHandler;

- (void)closeTouch:(BOOL)close;


@end


