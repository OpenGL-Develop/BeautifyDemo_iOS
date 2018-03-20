//
//  MGProgressView.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGProgressView.h"
#import "MGBeautyModel.h"
#import "segmentModel.h"
#import "CCHStepSizeSlider.h"
#import "YTMacro.h"
#import "MGSliderHeader.h"

#define KSEGMENTTAGSTART 100

@interface MGProgressView ()

@property (nonatomic, strong) MGBeautyModel *listModel;

@end

@implementation MGProgressView

- (instancetype)initWithFrame:(CGRect)frame Models:(MGBeautyModel *)models
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = YTColorWithRGB(1, 1, 1, 0.5);
        
        self.listModel = models;
        
        [self creatView:frame];
    }
    return self;
}

- (void)creatView:(CGRect)frame{
    NSInteger numCount = [self.listModel.dataArray count];
    CGFloat titleHeight = 5.0;
    CGFloat secctionHeight = (frame.size.height-titleHeight*2) / numCount;
    
    for (int i = 0 ;i < numCount; i++) {
        segmentModel *model = self.listModel.dataArray[i];

        CGFloat headWidth = secctionHeight*0.75;
        CGRect headerRect = CGRectMake(0, i*secctionHeight+titleHeight, headWidth, secctionHeight);
        CGRect sliderRect = CGRectMake(headWidth, CGRectGetMinY(headerRect), CGRectGetWidth(frame)-headWidth, secctionHeight);

        MGSliderHeader *headerView = [[MGSliderHeader alloc] initWithFrame:headerRect];
        [headerView setImage:[UIImage imageNamed:model.title]];
        [self addSubview:headerView];
        
        CCHStepSizeSlider *slider = [self sliderWithRect:sliderRect];
        [slider setTag:KSEGMENTTAGSTART + i];
        [slider setIndex:model.selectedIndex];
        [self addSubview:slider];
        [self updateDefaultValue:i model:model];
    }
}

- (void)updateDefaultValue:(NSInteger)tag model:(segmentModel *)model{
    switch (tag) {
        case 0:
            [self.listModel setValue1:model.selectedIndex];
            break;
        case 1:
            [self.listModel setValue2:model.selectedIndex];
            break;
        case 2:
            [self.listModel setValue3:model.selectedIndex];
            break;
        default:
            break;
    }
}

- (CCHStepSizeSlider *)sliderWithRect:(CGRect)rect{
    CCHStepSizeSlider *maxSlider = [[CCHStepSizeSlider alloc] initWithFrame:rect];
    maxSlider.backgroundColor = [UIColor clearColor];
//    maxSlider.margin = 20;
    maxSlider.lineWidth = 1.5;
    maxSlider.stepWidth = 13;
    maxSlider.stepColor = [UIColor whiteColor];
    maxSlider.stepTouchRate = 3;
    maxSlider.thumbSize = CGSizeMake(17, 17);
    maxSlider.thumbColor = YTColorWithRGB(73, 154, 255, 1.0);
    maxSlider.thumbTouchRate = 3;
    maxSlider.lineColor = [UIColor whiteColor];
    maxSlider.minTrackImage = [UIImage imageNamed:@"img_logo_cancel.png"];
    maxSlider.continuous = NO;
    maxSlider.numberOfStep = 6;
    [maxSlider addTarget:self action:@selector(valueChangeAction:) forControlEvents:UIControlEventValueChanged];
    return maxSlider;
}

- (void)valueChangeAction:(CCHStepSizeSlider *)slider{
    NSInteger index = slider.tag-KSEGMENTTAGSTART;
    NSInteger value = slider.index;
    
    segmentModel *model = self.listModel.dataArray[index];
    model.selectedIndex = value;
    
    switch (index) {
        case 0:
            [self.listModel setValue1:value];
            break;
        case 1:
            [self.listModel setValue2:value];
            break;
        case 2:
            [self.listModel setValue3:value];
            break;
        default:
            break;
    }
    
    if (self.delegate) {
        [self.delegate MGBottomBarSelected:self.listModel];
    }
}



@end

