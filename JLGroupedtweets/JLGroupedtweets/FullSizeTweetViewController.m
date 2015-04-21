//
//  FullSizeTweetViewController.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-21.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "FullSizeTweetViewController.h"

@interface FullSizeTweetViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@end

@implementation FullSizeTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tweetTextView.text = self.tweet.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
