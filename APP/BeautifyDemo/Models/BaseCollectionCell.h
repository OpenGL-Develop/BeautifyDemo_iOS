//
//  BaseCollectionCell.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/4/18.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModel.h"

@interface BaseCollectionCell : UICollectionViewCell

@property (nonatomic, strong) BaseModel *dateModel;

//@property (nonatomic, assign) BOOL selected;

@end
