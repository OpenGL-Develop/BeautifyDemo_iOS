//
//  ModelFactory.h
//  FaceppDemo
//
//  Created by 张英堂 on 2017/3/24.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MGBeautyModel.h"
#import "segmentModel.h"
#import "MGItemModel.h"

#define KSTICKERJSONNAME @"stickerData.json"
#define KFILTERJSONNAME @"filterData.json"


@interface ModelFactory : NSObject

+ (MGBeautyModel *)ModelWithType:(MGBeautyType)type;

+ (NSArray *)getData;

    
@end
