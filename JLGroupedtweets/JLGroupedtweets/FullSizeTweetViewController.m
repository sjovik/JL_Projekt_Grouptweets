//
//  FullSizeTweetViewController.m
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-21.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "FullSizeTweetViewController.h"
#import "JLIHelperMethods.h"

static CGFloat const MARGIN = 24.0f;

@interface FullSizeTweetViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (strong, nonatomic) UIImageView *tweetImageView;
@property (nonatomic) BOOL imageLoaded;

@end

@implementation FullSizeTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tweetTextView.text = self.tweet.text;

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.tweet.imgUrl && !self.imageLoaded) {
        self.imageLoaded = YES;
        [self loadTweetImage];
    }
    
}

- (void)loadTweetImage {
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:self.tweet.imgUrl]];
        if (!imageData) {
            NSLog(@"Problem loading image URL");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Image loaded");
            [self scaleAndStyleImageWithData:imageData];
        });
    });
    
}

- (void)scaleAndStyleImageWithData:(NSData *)imageData {
    UIImage *image = [JLIHelperMethods imageWithImage:[UIImage imageWithData: imageData]
                                scaledToAspectFitSize:CGSizeMake(self.view.frame.size.width - (MARGIN*2),
                                                                 self.view.frame.size.height/3)];
    CGRect frame = CGRectMake((self.view.frame.size.width - image.size.width) / 2,
                              self.tweetTextView.frame.origin.x +
                                self.tweetTextView.frame.size.height +
                                (MARGIN*2),
                              image.size.width, image.size.height);
    
    self.tweetImageView = [[UIImageView alloc] initWithFrame:frame];
    self.tweetImageView.image = image;
    CALayer *layer = self.tweetImageView.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 5.0;
    [self.view addSubview:self.tweetImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
