//
//  JLITweetManager.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-03-31.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JLITweetAuthor.h"

@protocol JLITweetManagerDelegate <NSObject>

@required
-(void)twitterAccountReady;
-(void)managedObjectContextReady;

@optional
-(void)timelineFetched:(NSDictionary *)timeline;

@end

@interface JLITweetManager : NSObject<UIAlertViewDelegate>

@property (nonatomic, weak) id<JLITweetManagerDelegate> delegate;

-(void)fetchTimeline;
-(void)setTwitterAccount;
-(void)openManagedDocument;
-(void)saveForTesting;

@end
