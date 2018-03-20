//
//  MGItemCell.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/4/18.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGItemCell.h"
#import "MGItemModel.h"

static NSString *animationKey = @"com.megvii.roll";

@interface MGItemCell ()

@property (weak, nonatomic) IBOutlet UIImageView *downView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end

@implementation MGItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.iconView setClipsToBounds:YES];
    [self setClipsToBounds:YES];
}

- (void)setDateModel:(BaseModel *)dateModel{
    [super setDateModel:dateModel];
    
    if ([dateModel isKindOfClass:[MGItemModel class]]) {
        MGItemModel *model = (MGItemModel *)dateModel;

        self.iconView.image = [UIImage imageNamed:model.selectedImageName];
        if (model.selected) {
            [self addBoder];
        }else{
            [self removeBoder];
        }
        
        switch (model.itemType) {
            case ITEMTYPETEXTIMAGEFILL:
                [self.iconView setContentMode:UIViewContentModeScaleAspectFill];
                break;
            case ITEMTYPETEXTIMAGEFIT:
                [self.iconView setContentMode:UIViewContentModeScaleAspectFit];
                break;
            default:
                break;
        }
        switch (model.status) {
            case Downing:
            {
                [self starRoll];
            }
                break;
            case DownError:
            case DownNot:
            {
                [self needDown];
            }
                break;
            default:
                [self stopRoll];
                break;
        }
    
    }else{
        NSLog(@"fuck 乱设置数据！");
    }
}

- (void)addBoder{
    self.iconView.layer.borderColor = [UIColor colorWithRed:27.0/225.0
                                                  green:221.0/225.0
                                                   blue:202.0/225.0
                                                  alpha:1].CGColor;
    self.iconView.layer.borderWidth = 1;
}

- (void)removeBoder{
    self.iconView.layer.borderWidth = 0;
}

- (void)stopRoll{
    [self.downView.layer removeAllAnimations];
    [self.downView setHidden:YES];
}

- (void)starRoll{
    [self.downView setImage:[UIImage imageNamed:@"icon_down_roll.png"]];
    
    if ([self.downView isHidden]) {
        [self.downView setHidden:NO];
    }
    
    if (![self.downView.layer animationForKey:animationKey] ) {
        [self.downView.layer addAnimation:[MGItemCell rollAnimation] forKey:animationKey];
    }
}

- (void)needDown{
    if ([self.downView isHidden]) {
        [self.downView setHidden:NO];
    }
    [self.downView setImage:[UIImage imageNamed:@"icon_down.png"]];
    [self.downView.layer removeAllAnimations];
}

+ (CAAnimation *)rollAnimation{
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
    animation.duration  = 2.0;
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    return animation;
}


@end
