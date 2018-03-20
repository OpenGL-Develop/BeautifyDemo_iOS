//
//  DataManager.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/5/26.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MGItemModel.h"
#import "MGBeautyModel.h"

@interface DataManager : NSObject

//创建单例
+ (instancetype)sharedManager;


//下载 动态贴纸的 ZIP 压缩包
- (void)downStickerZIP:(MGItemModel *)model
                finish:(void(^)(MGItemModel *dstModel, NSString *dstPath, BOOL error))finish;


@end
