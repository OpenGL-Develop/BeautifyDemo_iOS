//
//  FileCacheManager.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/9.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface FileCacheManager : NSObject

+ (void)changeFolderName:(NSString *)folderPath
              beforeName:(NSString *)beforePath;

+ (NSString *)saveDownTemp:(NSURL *)location
                   zipName:(NSString *)name;


+ (NSString *)checkZIP:(NSString *)name;


+ (NSString *)sourcePath:(NSString *)name type:(NSString *)type;


@end
