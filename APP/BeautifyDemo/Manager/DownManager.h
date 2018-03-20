//
//  DownManager.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/5/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DownManager : NSObject


- (NSURLSessionTask *)downStickerList:(void (^)(NSInteger netCode, id responseObject))finish;

- (NSURLSessionTask *)downStickerZIP:(NSString *)name
                              finish:(void (^)(NSInteger netCode, id responseObject))finish;


@end
