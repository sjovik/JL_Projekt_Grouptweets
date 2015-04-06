//
//  TweetsTableViewController.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-03-31.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "TweetsTableViewController.h"
#import "JLITweet.h"
#import "UIColorExtentions.h"


@interface TweetsTableViewController ()

@property (nonatomic) JLITweetManager *tweetManager;
@property (nonatomic) NSArray *tweetGroups;

@end

@implementation TweetsTableViewController


#pragma mark tweetManager callbacks

-(void)timelineFetched {
    [self sortByTime];
    [self.tableView reloadData];
}

-(void)sortByTime {
    
    NSMutableArray *orderedTweetGroups = [[NSMutableArray alloc] init];
    for (NSString *key in self.tweetManager.tweetsByAuthor) {
        JLITweet *tweet = [self.tweetManager.tweetsByAuthor[key] lastObject];

        [orderedTweetGroups addObject:tweet];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
    [orderedTweetGroups sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.tweetGroups = orderedTweetGroups;
}

#pragma mark onLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tweetManager = [[JLITweetManager alloc] init];
    self.tweetManager.delegate = self;
    [self.tweetManager fetchTimeline];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.tweetGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetsGroup" forIndexPath:indexPath];
    
    NSLog(@"%@", ((JLITweet*)self.tweetGroups[indexPath.section]).author);
    NSLog(@"%@", self.tweetManager.tweetsByAuthor[((JLITweet*)self.tweetGroups[indexPath.section]).author]);
    
    JLITweet *tweetGroup = [self.tweetManager.tweetsByAuthor[((JLITweet*)self.tweetGroups[indexPath.section]).author] lastObject];
    cell.textLabel.text = tweetGroup.author;
    cell.detailTextLabel.text = tweetGroup.text;
    if (tweetGroup.colorString) {
        cell.backgroundColor = [UIColor colorwithHexString:tweetGroup.colorString];
    }
    
    return cell;
}

@end
