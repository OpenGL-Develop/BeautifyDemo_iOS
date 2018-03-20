//
//  MGFilterView.h
//  FaceppDemo
//
//  Created by Li Bo on 2017/3/22.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBarView.h"
#import "MGBeautyModel.h"


@interface MGBottomItemView : BaseBarView


- (void)reloadCellWithIndex:(NSIndexPath *)indexPath;

- (void)reloadAll;

@end
