//
//  SubredditListCollectionViewCell.m
//  RedditDigest
//
//  Created by Richmond on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SubredditListCollectionViewCell.h"

@implementation SubredditListCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    self.selectedBackgroundView = [UIView new];
    self.backgroundView = [UIView new];

    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView.backgroundColor = [UIColor blueColor];

    for (CALayer *layer in @[self.backgroundView.layer, self.selectedBackgroundView.layer]) {
        layer.cornerRadius = 8.0;
        layer.masksToBounds = YES;
        layer.borderColor = [UIColor grayColor].CGColor;
        layer.borderWidth = 1;
    }

    return self;
}

- (void)awakeFromNib {
    // Initlize label from nib
    self.subredditTitleLabel.highlightedTextColor = [UIColor whiteColor];
}

@end
