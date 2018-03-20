//
//  MGSliderHeader.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/10/18.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGSliderHeader.h"


@implementation MGSliderHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.imageView];
        [self.imageView setFrame:CGRectMake(10, 5, frame.size.width-10, frame.size.height-10)];
    }
    return self;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setBackgroundColor:[UIColor clearColor]];

    }
    return _imageView;
}

- (void)setImage:(UIImage *)image{
    if (_image != image) {
        _image = image;
        
        [self.imageView setImage:image];
    }
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}

@end
