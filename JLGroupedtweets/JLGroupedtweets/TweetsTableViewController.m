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
#import "TweetCell.h"
#import "GroupHeaderCell.h"


static NSInteger const NO_EXPANDED_SECTION = -1;

@interface TweetsTableViewController ()

@property (nonatomic) JLITweetManager *tweetManager;
@property (nonatomic) NSArray *tweetGroups;
@property (nonatomic) NSInteger expandedSection;

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
    
    self.expandedSection = NO_EXPANDED_SECTION;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
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
    
    float authorTweetCount = ((NSArray*)self.tweetManager.tweetsByAuthor[((JLITweet*)self.tweetGroups[section]).author]).count;
    
    return (section == self.expandedSection) ?
        // +1 because header tweet repeated in expanded form
    (authorTweetCount > 5) ? 6 : authorTweetCount + 1
    : 1;
        
}
//
//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewAutomaticDimension;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // If first row of section, expand section; else segue to full size tweet view.
    if (!indexPath.row) {
        
        NSInteger clickedSection = indexPath.section;
        BOOL isExpanded = (self.expandedSection != NO_EXPANDED_SECTION);
        NSInteger numberOfRowsToClose = 0;
        NSInteger sectionToClose = 0;
        NSInteger numberOfRowsToOpen = 0;
        
        if (isExpanded) {
            
            if (self.expandedSection == clickedSection) {
                numberOfRowsToClose = [self tableView:self.tableView numberOfRowsInSection:clickedSection];
                sectionToClose = clickedSection;
                self.expandedSection = NO_EXPANDED_SECTION;
            } else {
                numberOfRowsToClose = [self tableView:self.tableView numberOfRowsInSection:self.expandedSection];
                sectionToClose = self.expandedSection;
                self.expandedSection = clickedSection;
                numberOfRowsToOpen = [self tableView:self.tableView numberOfRowsInSection:clickedSection];
            }
        } else {
            self.expandedSection = clickedSection;
            numberOfRowsToOpen = [self tableView:self.tableView numberOfRowsInSection:clickedSection];
        }
  
        [self.tableView beginUpdates];
        if (numberOfRowsToClose > 0) {
            
            [tableView deleteRowsAtIndexPaths:[self toggleNumOfRows:numberOfRowsToClose inSection:sectionToClose]
                             withRowAnimation:UITableViewRowAnimationTop];
        }
        if (numberOfRowsToOpen > 0) {

            [tableView insertRowsAtIndexPaths:[self toggleNumOfRows:numberOfRowsToOpen inSection:clickedSection]
                             withRowAnimation:UITableViewRowAnimationTop];
        }
        [self.tableView endUpdates];
        
    } else if (indexPath.row == 5){
        // TODO - gert more tweets
        NSLog(@"%@", @"hämtar fler tweets...");
    } else {
        // TODO - länka till fullstorlek tweet.
    }
}

-(NSArray *)toggleNumOfRows:(NSInteger)num inSection:(NSInteger)section {
    NSMutableArray *rowsToToggle = [NSMutableArray array];
    
    for (int i=1; i<num; i++)
    {
        NSIndexPath *row = [NSIndexPath indexPathForRow:i
                                              inSection:section];
        [rowsToToggle addObject:row];
    }
    
    return rowsToToggle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%ld", (long)indexPath.row);
    JLITweet *tweet;
    NSArray *tweetsByAuthor = self.tweetManager.tweetsByAuthor[((JLITweet *)self.tweetGroups[indexPath.section]).author];
    
    if (!indexPath.row) { // first row - group header cell
        GroupHeaderCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"TweetsGroup"
                                          forIndexPath:indexPath];
        tweet = [tweetsByAuthor lastObject];
        
        if (tweet.colorString) {
            cell.backgroundColor = [UIColor colorwithHexString:tweet.colorString];
        }
        cell.groupNameLabel.text = tweet.author;
        return cell;
        
    } else if (indexPath.row == 5) { // last row - get more tweets.
        TweetCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"Tweet"
                                               forIndexPath:indexPath];
        cell.bodyLabel.text = @"Hämta fler tweets";
        
        return cell;
    
    } else {
        TweetCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"Tweet"
                                               forIndexPath:indexPath];
        tweet = tweetsByAuthor[(tweetsByAuthor.count) - indexPath.row]; // in reversed order
        // cell.titleLabel.text = tweet.author;
        cell.bodyLabel.text = tweet.text;
        
        if (tweet.colorString) {
            cell.authorColorView.backgroundColor = [UIColor colorwithHexString:tweet.colorString];
        }
        return cell;
    }
    
}

@end
