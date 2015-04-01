//
//  JLITweetManager.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-03-31.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JLITweetManagerDelegate <NSObject>

@optional

-(void)timelineFetched;

@end

@interface JLITweetManager : NSObject

@property (nonatomic, weak) id<JLITweetManagerDelegate> delegate;

@property (nonatomic) NSMutableArray *timelineTweets;

-(void)fetchTimeline;

@end
