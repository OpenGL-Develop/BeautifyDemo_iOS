//
//  DownManager.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/5/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "DownManager.h"
#import "FileCacheManager.h"

@interface DownManager ()

@property (nonatomic, strong) NSURLSession *netManager;
@property (nonatomic, copy) NSString *baseStickURL;

@end

@implementation DownManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.netManager = [NSURLSession sharedSession];
        self.baseStickURL = @"https://facepp-content.oss-cn-hangzhou.aliyuncs.com/DownApp/stickerZIP";
    }
    return self;
}


- (NSURLSessionTask *)downStickerList:(void (^)(NSInteger netCode, id responseObject))finish{
    
    NSString *stickerURL = @"https://facepp-content.oss-cn-hangzhou.aliyuncs.com/DownApp/stickerData.json";

    NSURLSessionDataTask *task = [self.netManager dataTaskWithURL:[NSURL URLWithString:stickerURL]
                                                             completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                 NSInteger netCode = [(NSHTTPURLResponse *)response statusCode];
                                                                                                                                  
                                                                 if (!error && netCode == 200 ) {
                                                                     
                                                                     if (finish) {
                                                                         finish(netCode, data);
                                                                     }
                                                                 }else{
                                                                     if (finish) {
                                                                         finish(netCode, nil);
                                                                     }
                                                                 }
                                                             }];
    [task resume];
    
    return task;
}

- (NSURLSessionTask *)downStickerZIP:(NSString *)name finish:(void (^)(NSInteger netCode, id responseObject))finish{
    NSString *stickerURL = [self.baseStickURL stringByAppendingPathComponent:name];

    NSURLSessionTask *task = [self.netManager downloadTaskWithURL:[NSURL URLWithString:stickerURL]
                                                completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            
                                                    
                                                    NSInteger netCode = [(NSHTTPURLResponse *)response statusCode];
                                                    
                                                    if (!error && netCode == 200 ) {
                                                        
                                                        if (finish) {
                                                            finish(netCode, location);
                                                        }
                                                    }else{
                                                        if (finish) {
                                                            finish(netCode, nil);
                                                        }
                                                    }
                                                }];
    [task resume];
    
    return task;
}



@end
