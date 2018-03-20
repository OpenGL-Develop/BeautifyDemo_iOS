//
//  MGDebugView.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/3/23.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGDebugMessageView.h"

#define KLABELHEIGHT    20
#define KLABELCOUNT     8
#define KLABELWIDTH     75

@interface MGDebugMessageView ()

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation MGDebugMessageView


- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.4;
        self.userInteractionEnabled = NO;
        [self setFrame:CGRectMake(0, 0, KLABELWIDTH*2, KLABELHEIGHT*KLABELCOUNT+20)];

        _array = [NSMutableArray array];
        [self addSubviws];
    }
    return self;
}

- (void)updateDebugMessage{
    self.tracking = self.config.tracking;
    self.beautity = self.config.beautity;
    self.sticker = self.config.sticker;
    self.totalTime = self.config.totalTime;
}

- (void)addSubviws{
    for (int i=0; i<KLABELCOUNT; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, i*KLABELHEIGHT+10, KLABELWIDTH, KLABELHEIGHT)];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        switch (i) {
            case 0:
                label.text = @"Resolution:";
                break;
            case 1:
                label.text = @"FPS:";
                break;
            case 2:
                label.text = @"CPU:";
                break;
            case 3:
                label.text = @"Memory:";
                break;
            case 4:
                label.text = @"Total Time:";
                break;
            case 5:
                label.text = @"Tracking:";
                break;
            case 6:
                label.text = @"Beautity:";
                break;
            case 7:
                label.text = @"Sticker:";
                break;
                
            default:
                break;
        }
        [self addSubview:label];
        
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(KLABELWIDTH+5, i*KLABELHEIGHT+10, KLABELWIDTH-5, KLABELHEIGHT)];
        valueLabel.textAlignment = NSTextAlignmentLeft;
        valueLabel.textColor = [UIColor whiteColor];
        valueLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:valueLabel];
        [_array addObject:valueLabel];
    }
}

- (void)setResolution:(NSString *)resolution{
    [self setLabelIndex:0 text:resolution];
}

- (void)setFps:(NSString *)fps{
    [self setLabelIndex:1 text:fps];
}

- (void)setCpu:(NSString *)cpu{
    [self setLabelIndex:2 text:cpu];
}

- (void)setMemory:(NSString *)memory{
    [self setLabelIndex:3 text:memory];
}

- (void)setTotalTime:(NSString *)totalTime{
    [self setLabelIndex:4 text:totalTime];
}

- (void)setTracking:(NSString *)tracking{
    [self setLabelIndex:5 text:tracking];
}

- (void)setBeautity:(NSString *)beautity{
    [self setLabelIndex:6 text:beautity];
}

- (void)setSticker:(NSString *)sticker{
    [self setLabelIndex:7 text:sticker];
}


- (void)setLabelIndex:(NSInteger)index text:(NSString *)text{
    if (_array.count > index) {
        UILabel *label = _array[index];
        if ([text isKindOfClass:[NSString class]] && text.length > 0) {
            label.text = text;
        } else {
            label.text = @"0.0ms";
        }
    }
}



@end
