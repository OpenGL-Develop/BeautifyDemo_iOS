//
//  BaseModel.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/4/18.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MGBeautyType) {
    MGBeautySitck,
    MGBeautyFilter,
    MGBeautyBeauty,
    MGBeautyTrans,
};


@interface BaseModel : NSObject

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) MGBeautyType beautyType;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
