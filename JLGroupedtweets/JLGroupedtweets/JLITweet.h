//
//  JLITweet.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-10.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JLITweetAuthor;

@interface JLITweet : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * imgUrl;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) JLITweetAuthor *author;

@end
