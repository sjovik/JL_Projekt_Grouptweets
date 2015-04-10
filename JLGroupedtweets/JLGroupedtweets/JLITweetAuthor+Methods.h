//
//  JLITweetAuthor+Methods.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-10.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "JLITweetAuthor.h"

@interface JLITweetAuthor (Methods)

+(JLITweetAuthor *)authorFromTweet:(NSDictionary *)tweetData inManObjContext:(NSManagedObjectContext *)context;

@end
