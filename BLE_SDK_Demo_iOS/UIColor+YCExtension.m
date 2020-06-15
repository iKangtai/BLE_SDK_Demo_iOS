//
//  UIColor+YCExtension.m
//  YCUtility
//
//  Created by mac on 2018/7/5.
//  Copyright © 2018年 北京爱康泰科技有限责任公司. All rights reserved.
//

#define RGBA(R,G,B,A) ((UIColor*)[UIColor colorWithRed:(R/255.0) green:(G/255.0) blue:(B/255.0) alpha:(A)])

#import "UIColor+YCExtension.h"

@implementation UIColor(YCExtension)

+ (UIColor *)colorWithHex:(unsigned long)hexColor {
    return RGBA((float)((hexColor & 0xFF0000) >> 16),
                (float)((hexColor & 0xFF00) >> 8),
                (float)(hexColor & 0xFF), 1);
}

+ (UIColor *)colorWithHex:(unsigned long)hexColor alpha:(CGFloat)alpha {
    return RGBA((float)((hexColor & 0xFF0000) >> 16),
                (float)((hexColor & 0xFF00) >> 8),
                (float)(hexColor & 0xFF), alpha);
}

@end
