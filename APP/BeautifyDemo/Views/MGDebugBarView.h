//
//  MGDebugBarView.h
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/6/9.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DebugType) {
    DebugCameraReversal,    // 翻转摄像头
    DebugCameraRatio,       // 摄像头分辨率
    DebugCG,                // 所有特效
    DebugMessage,           // debug信息
};

@interface MGDebugBarView : UIView

- (void)addTarget:(id)sender action:(SEL)action debugType:(DebugType)type;


@end

