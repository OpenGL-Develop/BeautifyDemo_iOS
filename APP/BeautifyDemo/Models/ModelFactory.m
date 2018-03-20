//
//  ModelFactory.m
//  FaceppDemo
//
//  Created by 张英堂 on 2017/3/24.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "ModelFactory.h"
#import "MGItemModel.h"

@implementation ModelFactory

+ (NSArray *)getData{
    MGBeautyModel *stickerArr = [ModelFactory ModelWithType:MGBeautySitck];
    MGBeautyModel *filterArr = [ModelFactory ModelWithType:MGBeautyFilter];
    MGBeautyModel *beauytyArr = [ModelFactory ModelWithType:MGBeautyBeauty];
    MGBeautyModel *transArr = [ModelFactory ModelWithType:MGBeautyTrans];

    return @[stickerArr, filterArr, beauytyArr, transArr];
}

+ (MGBeautyModel *)ModelWithType:(MGBeautyType)type{
    MGBeautyModel *returnModel = [[MGBeautyModel alloc] init];
    returnModel.beautyType = type;
    
    switch (type) {
        case MGBeautyTrans:
        {
            returnModel.title = @"美型";
            returnModel.iconName = @"img_logo_trans.png";
            segmentModel *eyeModel = [segmentModel ModelWithTitle:@"icon_eye.png" maxValue:5 selectedIndex:3];
            segmentModel *faceModel = [segmentModel ModelWithTitle:@"icon_face.png" maxValue:5 selectedIndex:3];
            returnModel.dataArray = [NSMutableArray arrayWithArray:@[eyeModel, faceModel]];
        }
            break;
            
        case MGBeautyBeauty:
        {
            returnModel.title = @"美颜";
            returnModel.iconName = @"img_logo_beau.png";
            segmentModel *buffingModel = [segmentModel ModelWithTitle:@"icon_gauss.png" maxValue:5 selectedIndex:3];
            segmentModel *whiteModel = [segmentModel ModelWithTitle:@"icon_white.png" maxValue:5 selectedIndex:3];
            segmentModel *pinkModel = [segmentModel ModelWithTitle:@"icon_rosy" maxValue:5 selectedIndex:3];
            returnModel.dataArray = [NSMutableArray arrayWithArray:@[buffingModel, whiteModel, pinkModel]];
        }
            break;
        case MGBeautyFilter:
        {
            returnModel.title = @"滤镜";
            returnModel.iconName = @"img_logo_filter.png";
            returnModel.dataArray = [self getListArrayWithJsonName:KFILTERJSONNAME
                                                          itemType:ITEMTYPETEXTIMAGEFILL
                                                        beautyType:MGBeautyFilter                                     needCheck:NO];
        }
            break;
        case MGBeautySitck:
        {
            returnModel.title = @"贴纸";
            returnModel.iconName = @"img_logo_stick.png";
            returnModel.dataArray = [self getListArrayWithJsonName:KSTICKERJSONNAME
                                                          itemType:ITEMTYPETEXTIMAGEFIT
                                                        beautyType:MGBeautySitck
                                                         needCheck:YES];
        }
            break;
        default:
            break;
    }
    return returnModel;
}

+ (NSMutableArray *)getListArrayWithJsonName:(NSString *)jsonName
                                    itemType:(ImageType)type
                                  beautyType:(MGBeautyType)bType
                                   needCheck:(BOOL)check{
    
    NSMutableArray *dstArray = [NSMutableArray array];
    NSArray *arr = [ModelFactory getDicWithName:jsonName];
    
    for (NSDictionary *dict in arr) {
        @autoreleasepool {
            MGItemModel *model = [MGItemModel ItemModelWithDic:dict needCheck:check];
            [model setItemType:type];
            [model setBeautyType:bType];
            [dstArray addObject:model];
        }
    }
    MGItemModel *cmodel = [MGItemModel cancelItemModel];
    cmodel.beautyType = bType;
    [dstArray insertObject:cmodel atIndex:0];
    
    return dstArray;
}

+ (NSArray *)getDicWithName:(NSString *)name{
    NSString *filterPath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:filterPath];
    NSString *jsonStr = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    NSData *jsonDada = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonDada
                                                   options:NSJSONReadingMutableContainers
                                                     error:nil];
    return arr;
}

@end
