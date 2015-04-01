//
//  JLITweet.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-03-31.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "JLITweet.h"


@implementation JLITweet

-(instancetype)initWithAuthor:(NSString *)author text:(NSString *)text date:(NSString *)date {
    self = [super init];
    
    if (self) {
        _author = author;
        _text = text;
        _dateTime = [self formatDate:date];
    }
    
    return self;
}

-(NSDate *)formatDate:(NSString *)date {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [df setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    return [df dateFromString:date];
}

@end
