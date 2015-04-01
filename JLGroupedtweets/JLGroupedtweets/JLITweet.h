//
//  JLITweet.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-03-31.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLITweet : NSObject

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *author;

-(instancetype)initWithAuthor:(NSString *)author text:(NSString *)text;

@end
