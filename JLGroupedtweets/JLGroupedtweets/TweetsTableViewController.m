//
//  TweetsTableViewController.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-03-31.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "TweetsTableViewController.h"
#import "TweetCell.h"
#import "GroupHeaderCell.h"

#import "JLITweetAuthor.h"
#import "JLITweet.h"
#import "UIColor+Extentions.h"


static NSInteger const NO_EXPANDED_SECTION = -1;
static NSInteger const DEFAULT_ROWS_TO_SHOW = 6;

@interface TweetsTableViewController ()

@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL refreshingAllowed;

@property (nonatomic) JLITweetManager *tweetManager;

@property (nonatomic) NSDictionary *timeline;

@property (nonatomic) NSArray *tweetGroups;
@property (nonatomic) NSInteger openSection;
@property (nonatomic) int rowsToShowAtOpenSection;


@end

@implementation TweetsTableViewController


#pragma mark tweetManager callbacks
-(void)twitterAccountReady {
    [self.tweetManager openManagedDocument];
}

-(void)managedObjectContextReady {
    self.refreshingAllowed = YES;
    [self refreshControlActivated];
}

-(void)timelineFetched:(NSDictionary *)timeline {
    self.timeline = timeline;
    [self sortByTime];
    [self.tableView reloadData];
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

-(void)sortByTime {
    
    NSMutableArray *orderedTweetGroups = [[NSMutableArray alloc] init];
    for (NSString *key in self.timeline) {
        JLITweet *tweet = [self.timeline[key] firstObject];
        [orderedTweetGroups addObject:tweet];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    [orderedTweetGroups sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.tweetGroups = orderedTweetGroups;
}

#pragma mark onLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSearchControl];
    
    self.openSection = NO_EXPANDED_SECTION;
    self.rowsToShowAtOpenSection = DEFAULT_ROWS_TO_SHOW;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 75;
    
    self.tweetManager = [[JLITweetManager alloc] init];
    self.tweetManager.delegate = self;
    [self.tweetManager setTwitterAccount];

}

- (void)setupSearchControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.71f green:0.8f blue:0.8f alpha:1.0];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlActivated)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark User Interaction

-(void)refreshControlActivated {
    [self.tweetManager fetchTimeline];
    NSLog(@"refreshing");
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // If first row of section, expand section; else segue to full size tweet view.
    if (!indexPath.row) {
        
        NSInteger clickedSection = indexPath.section;
        BOOL isExpanded = (self.openSection != NO_EXPANDED_SECTION);
        NSInteger numberOfRowsToClose = 0;
        NSInteger sectionToClose = 0;
        NSInteger numberOfRowsToOpen = 0;
        
        if (isExpanded) {
            
            if (self.openSection == clickedSection) {
                numberOfRowsToClose = [self tableView:self.tableView numberOfRowsInSection:clickedSection];
                sectionToClose = clickedSection;
                self.openSection = NO_EXPANDED_SECTION;
                self.rowsToShowAtOpenSection = DEFAULT_ROWS_TO_SHOW;
            } else {
                numberOfRowsToClose = [self tableView:self.tableView numberOfRowsInSection:self.openSection];
                sectionToClose = self.openSection;
                self.openSection = clickedSection;
                self.rowsToShowAtOpenSection = DEFAULT_ROWS_TO_SHOW;
                numberOfRowsToOpen = [self tableView:self.tableView numberOfRowsInSection:clickedSection];
            }
        } else {
            [self resetUnreadBadge:indexPath];
            self.openSection = clickedSection;
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
        
    } else if (indexPath.row == self.rowsToShowAtOpenSection){ // expand more
        
        self.rowsToShowAtOpenSection += DEFAULT_ROWS_TO_SHOW;
        long numberOfRowsToOpen = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
        
        NSMutableArray *rowsToOpen = [NSMutableArray array];
        for (long i = indexPath.row; i < numberOfRowsToOpen; i++)
        {
            NSIndexPath *row = [NSIndexPath indexPathForRow:i
                                                  inSection:indexPath.section];
            [rowsToOpen addObject:row];
        }
        [self.tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:rowsToOpen
                         withRowAnimation:UITableViewRowAnimationTop];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        NSLog(@"%@", @"hämtar fler tweets...");
    } else {
        // TODO - länka till fullstorlek tweet.
    }
}

- (void)resetUnreadBadge:(NSIndexPath *)indexPath {
    
    GroupHeaderCell *cell = (GroupHeaderCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell.badgeLabel.text isEqualToString:@"0"]) {
        JLITweet *tweet = self.tweetGroups[indexPath.section];
        tweet.author.numOfNewTweets = @(0);
        cell.badgeLabel.text = @"0";
        cell.badgeLabel.hidden = YES;
        [self.tweetManager saveForTesting];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.tweetGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    float authorTweetCount = ((NSArray*)self.timeline[((JLITweet*)self.tweetGroups[section]).author.name]).count;

    return (section == self.openSection) ?
        // +1 because header tweet repeated in expanded form
        (authorTweetCount > self.rowsToShowAtOpenSection) ?
            self.rowsToShowAtOpenSection + 1
            : authorTweetCount + 1
        : 1;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
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
    
    JLITweet *tweet;
    NSArray *tweetsByAuthor = self.timeline[((JLITweet *)self.tweetGroups[indexPath.section]).author.name];
    
    if (!indexPath.row) { // first row - group header cell
        GroupHeaderCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"TweetsGroup"
                                               forIndexPath:indexPath];
        tweet = [tweetsByAuthor firstObject];
        
        cell.backgroundColor = [UIColor colorwithHexString:tweet.author.color];
        cell.groupNameLabel.textColor = [UIColor contrastingColor:cell.backgroundColor];
        cell.groupNameLabel.text = tweet.author.name;
        
        NSString *badgeNumber = [tweet.author.numOfNewTweets stringValue];
        if (![badgeNumber isEqual: @"0"]) {
            cell.badgeLabel.hidden = NO;
            cell.badgeLabel.text = badgeNumber;
            cell.badgeLabel.textColor = cell.groupNameLabel.textColor;
        } else cell.badgeLabel.hidden = YES;
        return cell;
        
    } else if (indexPath.row == self.rowsToShowAtOpenSection) { // last row - get more tweets.
        TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tweet"
                                               forIndexPath:indexPath];
        cell.tweetTextView.text = nil; // textView bug workaround
        cell.tweetTextView.text = @"Hämta fler tweets";
        cell.authorColorView.backgroundColor = [UIColor whiteColor];
        return cell;
    
    } else {
        TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tweet"
                                               forIndexPath:indexPath];
        tweet = tweetsByAuthor[indexPath.row -1];
        cell.tweetTextView.text = nil; // textView bug workaround
        cell.tweetTextView.text = tweet.text;
        cell.authorColorView.backgroundColor = [UIColor colorwithHexString:tweet.author.color];
        return cell;
    }
}

@end
