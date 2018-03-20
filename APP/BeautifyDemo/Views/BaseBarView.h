//
//  BaseBarView.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/4/18.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseModel;
@class MGBeautyModel;


@protocol MGBaseBarDelegate;

@interface BaseBarView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                       Models:(MGBeautyModel *)models
                    direction:(UICollectionViewScrollDirection)direction;

@property (nonatomic, weak) id<MGBaseBarDelegate>delegate;

@end



@protocol MGBaseBarDelegate <NSObject>

@required
- (void)MGBottomBarSelected:(BaseModel *)model;



@end
