//
//  JLITweetAuthor.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-10.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JLITweetAuthor : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * logoUrl;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface JLITweetAuthor (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(NSManagedObject *)value;
- (void)removeTweetsObject:(NSManagedObject *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
