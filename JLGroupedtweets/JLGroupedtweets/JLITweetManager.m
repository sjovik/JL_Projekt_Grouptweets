//
//  JLITweetManager.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-03-31.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "JLITweetManager.h"

#import "Social/Social.h"
#import "Accounts/Accounts.h"
#import "Twitter/Twitter.h"

#import "JLITweet.h"
#import "JLIHelperMethods.h"
#import "JLITweetAuthor+Methods.h"

@interface JLITweetManager()

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSArray *twitterData;
@end


@implementation JLITweetManager


#pragma mark CoreData

-(void)openManagedDocument {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *docPath = [[fileManager URLsForDirectory:NSDocumentDirectory
                                          inDomains:NSUserDomainMask] firstObject];
    NSURL *filePath = [docPath URLByAppendingPathComponent:@"JLITweetsByAuthorCD"];
    
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:filePath];
    
    BOOL fileExists = [fileManager fileExistsAtPath:[filePath path]];
    
    if (fileExists) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentReady:document];
            } else NSLog(@"Could not open file");
        }];
    } else {
        [document saveToURL:filePath
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  [self documentReady:document];
              } else NSLog(@"Could not save file");
          }];
    }
}

-(void)documentReady:(UIManagedDocument*) document {
    if (document.documentState == UIDocumentStateNormal) {
        self.managedObjectContext = document.managedObjectContext;
        [self.delegate managedObjectContextReady];
    }
}

-(void)writeCoreData {
    
    for (NSDictionary *tweetData in self.twitterData) {
        
        JLITweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:@"JLITweet"
                                                        inManagedObjectContext:self.managedObjectContext];
        
        assert(tweet);
        tweet.id = tweetData[@"id_str"];
        tweet.text = tweetData[@"text"];
        tweet.date = [JLIHelperMethods formatTwitterDateFromString:tweetData[@"created_at"]];
        tweet.author = [JLITweetAuthor authorFromTweet:tweetData[@"user"] inManObjContext:self.managedObjectContext];
        
//        JLITweet *tweet = [[JLITweet alloc] initWithAuthor:tweetData[@"user"][@"name"]
//                                                      text:tweetData[@"text"]
//                                                      date:tweetData[@"created_at"]];
//        tweet.colorString = tweetData[@"user"][@"profile_background_color"];
//        // NSLog(@"%@: %@", tweet.author, tweetData[@"user"][@"profile_background_color"]);
//        [self.downloadedTweets insertObject:tweet atIndex:0];
        

        NSError *error;

        if(![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to save.");
        }
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }
}

-(NSDictionary *)timelineFromCoreData {
    
    NSMutableDictionary *timeline = [[NSMutableDictionary alloc] init];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JLITweetAuthor"];
    
    NSError *error;
    NSArray *authors = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!authors || error) {
        NSLog(@"Error: %@", error.localizedDescription);
    } else {
        for (JLITweetAuthor* author in authors) {
            [timeline setValue:[author.tweets allObjects] forKey:author.name];
        }
    }
    return timeline;
}

-(NSString *)getLastTweetId {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JLITweet"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *tweets = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!tweets || error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return nil;
    } else {
        JLITweet *tweet = [tweets lastObject];
        return tweet.id;
    }
}

#pragma mark TwitterAPI connections
-(void)fetchTimeline {
    
    NSString *sinceId = [self getLastTweetId];
    NSLog(@"since id: %@", sinceId);
    // if (!sinceId) sinceId =
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil
                                          completion:^(BOOL granted, NSError *error) {
                                              if (granted) {
                                                  NSLog(@"Account access granted");
                                                  
                                                  NSArray *allAccounts = [accountStore accountsWithAccountType:accountType];
                                                  if (allAccounts.count > 0) {
                                                      
                                                      if (allAccounts.count > 1) {
                                                          // TODO låt användare välja account
                                                      }
                                                      NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                                                      NSDictionary *parameters = @{
                                                                                        @"count" : @"30",
                                                                                        @"include_entities" : @"1",
                                                                                        // @"since_id" : sinceId
                                                                                   };
                                                      if (sinceId) {
                                                          parameters = @{
                                                            @"count" : @"30",
                                                            @"include_entities" : @"1",
                                                            @"since_id" : sinceId
                                                          };
                                                      }
                                                      SLRequest *tweetsRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                                                    requestMethod:SLRequestMethodGET
                                                                                                              URL:url
                                                                                                       parameters:parameters];
                                                      ACAccount *twAccount = allAccounts[0];
                                                      [tweetsRequest setAccount:twAccount];
                                                      
                                                      [tweetsRequest performRequestWithHandler:^(NSData *responseData,
                                                                                                 NSHTTPURLResponse *urlResponse,
                                                                                                 NSError *error) {
                                                          if ([urlResponse statusCode] == 429) {
                                                              NSLog(@"Max requests per 15 minuter överskridet");
                                                              return;
                                                          }
                                                          if (error) {
                                                              NSLog(@"Error: %@", error.localizedDescription);
                                                              return;
                                                          }
                                                          
                                                          if (responseData) {
                                                              NSError *jsonError = nil;
                                                              NSArray *tweetsData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                                                options:NSJSONReadingMutableLeaves
                                                                                                                  error:&jsonError];
                                                              if (jsonError) {
                                                                  NSLog(@"Error parsing json");
                                                                  return;
                                                              }
                                                              
                                                              self.twitterData = tweetsData;
                                                              
                                                              NSLog(@"Timeline fetched %lu items", (unsigned long)self.twitterData.count);
                                                              
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [self writeCoreData];
                                                                  [self.delegate timelineFetched:[self timelineFromCoreData]];
                                                              });
                                                              
                                                          }
                                                      }];
                                                  }
                                              } else {
                                                  NSLog(@"Request to account not granted");
                                              }
                                              if (error) {
                                                  NSLog(@"Error: %@", error.localizedDescription);
                                              }
                                          }];
    
    
}



@end
