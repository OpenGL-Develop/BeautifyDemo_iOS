//
//  FileCacheManager.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/9.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "FileCacheManager.h"

@implementation FileCacheManager

+ (NSString *)getDocumentMegviiPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *DocumentPath = [paths objectAtIndex:0];
    
    NSString *afterFolder = [DocumentPath stringByAppendingPathComponent:@"com.megvii.sticker/"];
    
    return afterFolder;
}

+ (void)changeFolderName:(NSString *)folderPath beforeName:(NSString *)beforePath{
    NSFileManager *fm = [NSFileManager defaultManager];

    [fm moveItemAtPath:beforePath
                toPath:folderPath
                 error:NULL];
    
    [fm removeItemAtPath:folderPath error:nil];
}

+ (NSString *)saveDownTemp:(NSURL *)location zipName:(NSString *)name{
    NSFileManager *fm = [NSFileManager defaultManager];

    NSData *data = [NSData dataWithContentsOfURL:location];
    
    NSString *afterFolder = [self getDocumentMegviiPath];
    
    [fm createDirectoryAtPath:afterFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *savePath = [afterFolder stringByAppendingPathComponent:name];

    [data writeToFile:savePath atomically:YES];
    
    return savePath;
}

//获取 ZIP 压缩包下载地址
+ (NSString *)checkZIP:(NSString *)name{
    if (!name) {
        return nil;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *afterFolder = [self getDocumentMegviiPath];
    NSString *savePath = [afterFolder stringByAppendingPathComponent:name];
    
    BOOL has = [fm fileExistsAtPath:savePath];
    if (has) {
        return savePath;
    }else{
        NSString *bundilePath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        return bundilePath;
    }
}

+ (NSString *)sourcePath:(NSString *)name type:(NSString *)type{
    if (name == nil) {
        return nil;
    }
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    
    return sourcePath;
}

@end
