//
//  JLITweetManager.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-03-31.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JLITweetManagerDelegate <NSObject>

@required

-(void)managedObjectContextReady;

@optional

-(void)timelineFetched:(NSDictionary *)timeline;

@end

@interface JLITweetManager : NSObject

@property (nonatomic, weak) id<JLITweetManagerDelegate> delegate;


@property (nonatomic) NSMutableDictionary *tweetsByAuthor;

-(void)fetchTimeline;
-(void)openManagedDocument;

@end
