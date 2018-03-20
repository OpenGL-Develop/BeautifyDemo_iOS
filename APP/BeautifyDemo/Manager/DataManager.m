//
//  DataManager.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/5/26.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "DataManager.h"
#import "DownManager.h"
#import "FileCacheManager.h"

@interface DataManager ()

@property (nonatomic, strong) DownManager *downManager;

@end

@implementation DataManager

+ (instancetype)sharedManager{
    
    static DataManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downManager = [[DownManager alloc] init];
    }
    return self;
}

- (void)downStickerZIP:(MGItemModel *)model
                finish:(void(^)(MGItemModel *dstModel, NSString *dstPath, BOOL error))finish{

    if (model.zipName == nil) {
        if (finish) {
            finish(nil, nil, NO);
        }
        return;
    }
    NSString *zipLocationPath = [FileCacheManager checkZIP:model.zipName];
    
    if (zipLocationPath != nil) {
        if (finish) {
            finish(model, nil, NO);
        }
        return;
    }
    model.status = Downing;
    [self.downManager downStickerZIP:model.zipName
                              finish:^(NSInteger netCode, id responseObject) {
                                  
                                  if (netCode == 200 && [responseObject isKindOfClass:[NSURL class]]) {
                                   NSString *savePath = [FileCacheManager saveDownTemp:responseObject zipName:model.zipName];
                                      
                                      model.status = DownSuccess;

                                      if (finish) {
                                          finish(model, savePath, NO);
                                      }
                                  }else{
                                      model.status = DownError;

                                      if (finish) {
                                          finish(model, nil, YES);
                                      }
                                  }
                              }];
}

@end
