//
//  MGCancelView.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/10/19.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGCancelView.h"

@implementation MGCancelView

- (instancetype)initWithWeightView:(BaseBarView *)weightView{
    self = [super init];
    if (self) {
        CGRect wFrame = weightView.frame;
        CGFloat offSet = 60;
        
        wFrame.origin.y -= offSet;
        wFrame.size.height += offSet;
        
        [self setFrame:wFrame];
        
        wFrame = weightView.frame;
        wFrame.origin.y = offSet;
        
        [weightView setFrame:wFrame];
        [self addSubview:weightView];
        
        [self.cancelView setFrame:CGRectMake(wFrame.size.width-offSet, 0, offSet, offSet)];
        [self addSubview:self.cancelView];
        self.weightView = weightView;
    }
    return self;
}

- (UIButton *)cancelView{
    if (!_cancelView) {
        _cancelView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelView.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_cancelView setImage:[UIImage imageNamed:@"img_close.png"] forState:UIControlStateNormal];
        [_cancelView setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    return _cancelView;
}
- (void)addCancelTarget:(nullable id)target action:(SEL)action{
    [self.cancelView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
@end
