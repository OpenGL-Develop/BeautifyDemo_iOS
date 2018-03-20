//
//  TYtMacro.h
//

#ifndef text_TYtMacro_h
#define text_TYtMacro_h

    #import "EXTScope.h"

    //屏幕宽度 （区别于viewcontroller.view.fream）
    #define WIN_WIDTH  [UIScreen mainScreen].bounds.size.width
    //屏幕高度 （区别于viewcontroller.view.fream）
    #define WIN_HEIGHT [UIScreen mainScreen].bounds.size.height

    //IOS版本
    #define IOSSysVersion [[UIDevice currentDevice] systemVersion].floatValue

    // rgb颜色转换（16进制->10进制）
    #define YTColorWithHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
    // color
    #define YTColorWithRGB(R, G, B, A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]

#endif
