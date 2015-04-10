//
//  JLITweetAuthor+Methods.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-10.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "JLITweetAuthor+Methods.h"

@implementation JLITweetAuthor (Methods)

+(JLITweetAuthor *)authorFromTweet:(NSDictionary *)tweetData inManObjContext:(NSManagedObjectContext *)context {
    
    JLITweetAuthor *author = nil;
    NSDictionary *authorJson = tweetData[@"user"];
    
    NSString *authorId = authorJson[@"id_str"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JLITweetAuthor"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", authorId];
    
    NSError *error;
    NSArray *match = [context executeFetchRequest:request error:&error];
    
    if(!match || error) {
        NSLog(@"Error: %@", error.localizedDescription);
    } else if ([match count]) {
        author = [match firstObject];
    } else {
        author = [NSEntityDescription insertNewObjectForEntityForName:@"JLITweerAuthor"
                                               inManagedObjectContext:context];
        
        author.id = authorId;
        author.name = authorJson[@"screen_name"];
        author.logoUrl = authorJson[@"profile_image_url_https"];
        author.color = authorJson[@"profile_background_color"];
    }
    
    return author;
}


@end
