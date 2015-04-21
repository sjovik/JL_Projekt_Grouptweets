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
@property (strong, nonatomic) IBOutlet UIImageView *tweetImageView;

@end

@implementation FullSizeTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tweetTextView.text = self.tweet.text;
    if (self.tweet.imgUrl) {
        [self loadTweetImage];
    }
}

- (void)loadTweetImage {
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:self.tweet.imgUrl]];
        if (!imageData) {
            NSLog(@"No image data");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Image loaded");
            self.tweetImageView.image = [UIImage imageWithData: imageData];
        });
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
