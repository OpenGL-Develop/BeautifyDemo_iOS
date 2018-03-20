//
//  ItemModel.h
//  FaceppDemo
//
//  Created by 张英堂 on 2017/3/16.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModel.h"

typedef NS_ENUM(NSInteger, ImageType) {
    ITEMTYPETEXTIMAGEFILL,  // 缩略预览图 需要 fill
    ITEMTYPETEXTIMAGEFIT,   // 缩略预览图 需要 fit
};



typedef NS_ENUM(NSInteger, DownStatus) {
    Downing = 0,
    DownSuccess = 1,
    DownError,
    DownNot,
};

@interface MGItemModel : BaseModel


+ (instancetype)ItemModelWithDic:(NSDictionary *)dic needCheck:(BOOL)check;
+ (instancetype)ItemModelWithType:(ImageType)type;
+ (instancetype)cancelItemModel;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *selectedImageName;

@property (nonatomic, copy) NSString *zipName;
@property (nonatomic, copy) NSString *fileterName;


@property (nonatomic, assign) ImageType itemType;
@property (nonatomic, assign) DownStatus status;

@property (nonatomic, assign) BOOL isCancelModel;

@end
