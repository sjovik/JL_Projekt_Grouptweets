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
@interface JLITweetManager()
@property (nonatomic) NSMutableArray *downloadedTweets;
@property (nonatomic) NSManagedObjectContext *context;
@end


@implementation JLITweetManager


#pragma mark Property getters
-(NSArray *)downloadedTweets {
    if (!_downloadedTweets) {
        _downloadedTweets = [[NSMutableArray alloc] init];
    }
    return _downloadedTweets;
}

-(NSMutableDictionary *)tweetsByAuthor {
    if (!_tweetsByAuthor) {
        _tweetsByAuthor = [[NSMutableDictionary alloc] init];
    }
    
    return _tweetsByAuthor;
}


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
            if (success) [self documentReady:document];
            if (!success) NSLog(@"Could not open file");
        }];
    } else {
        [document saveToURL:filePath
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) [self documentReady:document];
              if (!success) NSLog(@"Could not save file");
              
          }];
    }
}

-(void)documentReady:(UIManagedDocument*) document {
    if (document.documentState == UIDocumentStateNormal) {
        self.context = document.managedObjectContext;
    }
}

#pragma mark Sorting
-(void)sortTweetsByAuthor {
    for (JLITweet *tweet in self.downloadedTweets) {
        NSArray *authorTweets;
        if (self.tweetsByAuthor[tweet.author]) {
            authorTweets = [self.tweetsByAuthor[tweet.author] arrayByAddingObject:tweet];
        } else {
            authorTweets = @[tweet];
        }
        [self.tweetsByAuthor setObject:authorTweets forKey:tweet.author];
    }
}

#pragma mark TwitterAPI connections
-(void)fetchTimeline {
    
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
                                                                                        @"include_entities" : @"1"
                                                                                   };
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
                                                              
                                                              for (NSDictionary *tweetData in tweetsData) {
                                                                  
                                                                  JLITweet *tweet = [[JLITweet alloc] initWithAuthor:tweetData[@"user"][@"name"]
                                                                                                                text:tweetData[@"text"]
                                                                                                                date:tweetData[@"created_at"]];
                                                                  tweet.colorString = tweetData[@"user"][@"profile_background_color"];
                                                                  // NSLog(@"%@: %@", tweet.author, tweetData[@"user"][@"profile_background_color"]);
                                                                  [self.downloadedTweets insertObject:tweet atIndex:0];
                                                              }
                                                              
                                                              [self sortTweetsByAuthor];
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  NSLog(@"Timeline fetched");
                                                                  [self.delegate timelineFetched];
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
