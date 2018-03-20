//
//  MGBottomBarView.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/3/22.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGBottomBarView.h"
#import <MGBaseKit/MGBaseKit.h>

#define KITEMSTARTTAG 100

@interface MGBottomBarView ()

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, copy) MGBottomBarSelectAtIndexPath selectHandler;

@property (nonatomic, assign) BOOL canTouch;

@end

@implementation MGBottomBarView

- (void)extracted {
    [self setExclusiveTouch:YES];
}

- (instancetype)initWithFrame:(CGRect)frame
                       Models:(NSArray *)models
                selectHandler:(MGBottomBarSelectAtIndexPath)selectHandler{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.models = models;
        [self setCollectionView];
        
        self.selectHandler = selectHandler;
        
        [self extracted];
        [self setCanTouch:YES];
    }
    return self;
}

- (void)setCollectionView{
    if (!self.models || self.models.count != 4) {
        return;
    }
    CGFloat leftOffset = 20;
    CGFloat cellwidth = (CGRectGetWidth(self.frame)-leftOffset*2)/ 4.0;

    for (int i = 0; i < 4; i++) {
        MGBeautyModel *model = self.models[i];
        UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(i*cellwidth+leftOffset, 0, cellwidth, cellwidth)];
        [item setImage:[UIImage imageNamed:model.iconName] forState:UIControlStateNormal];
        [item setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [item addTarget:self action:@selector(clickActon:) forControlEvents:UIControlEventTouchUpInside];
        [item setTag:KITEMSTARTTAG + i];
        [self addSubview:item];
    }
}

- (void)closeTouch:(BOOL)close{
    [self setCanTouch:!close];
}

- (void)clickActon:(UIButton *)sender {
    if (!self.canTouch) {
        return;
    }
    
    MGBeautyModel *model = self.models[sender.tag-KITEMSTARTTAG];
    
    if (_selectHandler) {
        _selectHandler(model);
    }
}



@end
