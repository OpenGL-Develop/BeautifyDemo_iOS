//
//  MGItemModel.m
//  FaceppDemo
//
//  Created by 张英堂 on 2017/3/16.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGItemModel.h"
#import "FileCacheManager.h"

@implementation MGItemModel

+ (instancetype)ItemModelWithDic:(NSDictionary *)dic needCheck:(BOOL)check{
    MGItemModel *model = [[MGItemModel alloc] init];
    
    model.title = dic[@"title_chinese"];
    model.selectedImageName = dic[@"sample"];
    
    model.fileterName = dic[@"filter"];
    model.zipName = dic[@"zipName"];
    
    if (model.fileterName == nil) {
        model.fileterName = @"";
    }
    if (model.zipName == nil) {
        model.zipName = @"";
    }
    
    if (check) {
        NSString *zipLocationPath = [FileCacheManager checkZIP:model.zipName];
        if (zipLocationPath != nil) {
            model.status = DownSuccess;
        }else{
            model.status = DownNot;
        }
    }else{
        model.status = DownSuccess;
    }
    
    return model;
}

+ (instancetype)ItemModelWithType:(ImageType)type{
    MGItemModel *model = [[MGItemModel alloc] init];
    model.selected = NO;
    model.status = DownSuccess;
    model.itemType = type;
    
    return model;
}

+ (instancetype)cancelItemModel{
    MGItemModel *model = [[MGItemModel alloc] init];
    model.selected = YES;
    model.status = DownSuccess;
    model.isCancelModel = YES;
    model.title = @"取消";
    model.selectedImageName = @"img_logo_cancel.png";
    model.itemType = ITEMTYPETEXTIMAGEFIT;
    
    return model;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.status =  DownSuccess;
        self.selected = NO;
        self.isCancelModel = NO;
    }
    return self;
}


@end
