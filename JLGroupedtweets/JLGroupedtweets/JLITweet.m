//
//  JLITweet.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-03-31.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "JLITweet.h"


@implementation JLITweet

-(instancetype)initWithAuthor:(NSString *)author text:(NSString *)text {
    self = [super init];
    
    if (self) {
        _author = author;
        _text = text;
    }
    
    return self;
}



@end
