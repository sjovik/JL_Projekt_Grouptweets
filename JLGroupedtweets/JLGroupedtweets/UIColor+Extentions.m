//
//  UIColorExtentions.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-03.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "UIColor+Extentions.h"

@implementation UIColor(UIColorExtentions)


// from http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
// user http://stackoverflow.com/users/707320/darrinm
+(UIColor *)colorwithHexString:(NSString *)hexValue {
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexValue];
    // not needed for this app [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];

}


+(UIColor *)contrastingColor:(UIColor *)color {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    float threshold = 0.3;
    // Formula for computing Luminance out of R G B.
    // http://stackoverflow.com/questions/11867545/change-text-color-based-on-brightness-of-the-covered-background-area
    float bgDelta = ((red * 299)+(green * 587)+(blue * 114))/1000;
    return (bgDelta > threshold) ?
        [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.0]
        : [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0];
    
}


@end
