//
//  UIColorExtentions.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-03.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "UIColorExtentions.h"

@implementation UIColor(UIColorExtentions)

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

@end
