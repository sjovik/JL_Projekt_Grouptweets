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
@property (nonatomic) NSArray *expandedSectionTweets;
@property (nonatomic) long expandedSectionIndexRow;

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (self.expandedSectionTweets.count>0) {
        return self.expandedSectionTweets.count + self.tweetGroups.count;
    }
    return self.tweetGroups.count;
}

-(NSArray *)deleteIndexPathsInSelection:(long)selectionRow {
    NSMutableArray *indexPathsToRemove = [[NSMutableArray alloc] initWithCapacity:self.expandedSectionTweets.count];
    for (int i = 0; i < self.expandedSectionTweets.count; i++) {
        [indexPathsToRemove addObject:[NSIndexPath indexPathForRow:(selectionRow+i+1) inSection:0]];
    }
    return indexPathsToRemove;
}

-(NSArray *)addIndexPathsInSelection:(long)selectionRow {
    self.expandedSectionIndexRow = selectionRow;
    NSMutableArray *indexPathsToRemove = [[NSMutableArray alloc] initWithCapacity:self.expandedSectionTweets.count];
    for (int i = 0; i < self.expandedSectionTweets.count; i++) {
        [indexPathsToRemove addObject:[NSIndexPath indexPathForRow:(selectionRow+i+1) inSection:0]];
    }
    return indexPathsToRemove;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    
    if (self.expandedSectionTweets) {
        NSArray *deleteIndexPaths = [self deleteIndexPathsInSelection:self.expandedSectionIndexRow];
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    NSMutableArray *selectedGroupTweets = [[NSMutableArray alloc] init];
    NSString *tweetGroupSelected = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    for (JLITweet *tweet in self.tweetManager.tweetsByAuthor[tweetGroupSelected]) {
        [selectedGroupTweets addObject:tweet];
    }
    self.expandedSectionTweets = selectedGroupTweets;
    NSArray *insertIndexPaths = [self addIndexPathsInSelection:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetsGroup" forIndexPath:indexPath];
    
    JLITweet *tweetGroup;
    if (self.expandedSectionTweets.count>0) {
        NSMutableArray *array = [self.tweetGroups mutableCopy];
        [array replaceObjectsInRange:NSMakeRange(self.expandedSectionIndexRow, 0)
                withObjectsFromArray:self.expandedSectionTweets];
        tweetGroup = array[indexPath.row];
    }else{
        tweetGroup = self.tweetGroups[indexPath.row];
    }
    
    
    cell.textLabel.text = tweetGroup.author;
    if (tweetGroup.colorString) {
        cell.backgroundColor = [UIColor colorwithHexString:tweetGroup.colorString];
    }
    
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
