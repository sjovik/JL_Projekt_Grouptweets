//
//  GroupHeaderCell.h
//  JLGroupedtweets
//
//  Created by Johannes on 2015-04-08.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

@end
