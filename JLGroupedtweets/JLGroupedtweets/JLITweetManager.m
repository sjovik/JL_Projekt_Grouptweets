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
@property (nonatomic) NSURL *filePath;
@property (nonatomic) UIManagedDocument *document;
@end


@implementation JLITweetManager


#pragma mark CoreData

// Saves managed document - For debugging purposes, NSManagedDocument autosaves.
-(void)saveForTesting {
    [self.document saveToURL:self.filePath
       forSaveOperation:UIDocumentSaveForOverwriting
      completionHandler:^(BOOL success) {
          if (success) {
              NSLog(@"Saving UIManagedDocument  - save for testing");
          } else NSLog(@"Could not save file  - save for testing");
      }];
}

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
                NSLog(@"Opened file");
                [self documentReady:document];
            } else NSLog(@"Could not open file");
        }];
    } else {
        [document saveToURL:filePath
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  NSLog(@"Created file");
                  [self documentReady:document];
              } else NSLog(@"Could not save file");
          }];
    }
    
    // For save for testing.
    self.filePath = filePath;
    self.document = document;
}

-(void)documentReady:(UIManagedDocument*) document {
    if (document.documentState == UIDocumentStateNormal) {
        NSLog(@"Document ready");
        self.managedObjectContext = document.managedObjectContext;
        [self.delegate managedObjectContextReady];
    }
}

-(void)writeCoreData {
    
    for (NSDictionary *tweetData in self.twitterData) {
        
        JLITweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:@"JLITweet"
                                                        inManagedObjectContext:self.managedObjectContext];
        tweet.id = tweetData[@"id_str"];
        tweet.text = tweetData[@"text"];
        tweet.date = [JLIHelperMethods formatTwitterDateFromString:tweetData[@"created_at"]];
        tweet.author = [JLITweetAuthor authorFromTweet:tweetData[@"user"] inManObjContext:self.managedObjectContext];
        tweet.author.numOfNewTweets = [NSNumber numberWithInt:[tweet.author.numOfNewTweets intValue] + 1];

        [self saveForTesting];
    }
}

-(NSDictionary *)timelineFromCoreData {
    
    NSMutableDictionary *timeline = [[NSMutableDictionary alloc] init];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JLITweetAuthor"];
    
    NSError *error;
    NSArray *authors = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    
    if(!authors || error) {
        if (error) NSLog(@"Error: %@", error.localizedDescription);
    } else {
        for (JLITweetAuthor* author in authors) {
            [timeline setValue:[[author.tweets allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]] forKey:author.name];
        }
    }
    return timeline;
}

-(NSString *)getLastTweetId {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JLITweet"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    request.fetchLimit = 1;
    
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

-(void)deleteOldTweets {
    
}

#pragma mark TwitterAPI connections
-(void)fetchTimeline {
    
    // TODO - [self deleteOldTweets]
    NSString *sinceId = [self getLastTweetId];
    NSLog(@"since id: %@", sinceId);
    
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
                                                                                        @"count" : @"100",
                                                                                        @"include_entities" : @"0"
                                                                                   };
                                                      if (sinceId) {
                                                          parameters = @{
                                                            @"count" : @"100",
                                                            @"include_entities" : @"0",
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
                                                              NSLog(@"Max requests per 15 minuter exeeded");
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
