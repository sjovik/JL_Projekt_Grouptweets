//
//  TweetCell.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-08.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIView *authorColorView;

@end
