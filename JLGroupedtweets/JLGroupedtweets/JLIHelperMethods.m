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

+(NSDate *)formatTwitterDateFromString:(NSString *)date {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [df setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    return [df dateFromString:date];
}




@end
