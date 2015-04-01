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

@implementation JLITweetManager

-(NSArray *)timelineTweets {
    if (!_timelineTweets) {
        _timelineTweets = [[NSMutableArray alloc] init];
    }
    return _timelineTweets;
}

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
                                                                                        @"count" : @"10",
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
                                                                                                                text:tweetData[@"text"]];
                                                                  [self.timelineTweets addObject:tweet];
                                                              }
                                                              
                                                              dispatch_async(dispatch_get_main_queue(), ^{
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
