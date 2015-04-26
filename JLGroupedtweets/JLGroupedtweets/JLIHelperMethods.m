//
//  JLIHelperMethods.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-10.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "JLIHelperMethods.h"

@implementation JLIHelperMethods

- (id)init
{
    //Don't allow init to initialize any memory state
    return nil;
}

+ (NSDate *)formatTwitterDateFromString:(NSString *)date {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [df setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    return [df dateFromString:date];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToAspectFitSize:(CGSize)size {
    //calculate rect
    CGFloat aspect = image.size.width / image.size.height;
    if (size.width / aspect <= size.height)
    {
        return [self imageWithImage:image scaledToSize:CGSizeMake(size.width, size.width / aspect)];
    }
    else
    {
        return [self imageWithImage:image scaledToSize:CGSizeMake(size.height * aspect, size.height)];
    }
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    // UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
