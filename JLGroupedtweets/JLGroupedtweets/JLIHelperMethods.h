//
//  JLIHelperMethods.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-10.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JLIHelperMethods : NSObject

+ (NSDate *)formatTwitterDateFromString:(NSString *)date;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToAspectFitSize:(CGSize)size;

@end
