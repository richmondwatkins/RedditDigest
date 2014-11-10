//
//  SubredditListCollectionViewCell.m
//  RedditDigest
//
//  Created by Richmond on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#define REDDIT_DARK_BLUE [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

#import "SubredditListCollectionViewCell.h"

@implementation SubredditListCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    self.selectedBackgroundView = [UIView new];
    self.backgroundView = [UIView new];

   

    // Background and selected Background colors
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView.backgroundColor = REDDIT_DARK_BLUE;

    // Border of all the cells
    for (CALayer *layer in @[self.backgroundView.layer, self.selectedBackgroundView.layer]) {
        layer.cornerRadius = 8.0;
        layer.masksToBounds = YES;
        layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;
        layer.borderWidth = 1;
    }

    return self;
}

- (void)awakeFromNib {
    // Initlize label from nib
    self.subredditTitleLabel.highlightedTextColor = [UIColor whiteColor];
}

@end
