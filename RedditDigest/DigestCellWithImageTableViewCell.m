//
//  DigestCellWithImage.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "DigestCellWithImageTableViewCell.h"
@implementation DigestCellWithImageTableViewCell


- (IBAction)upVoteButtonPressed:(UIButton *)sender {
    //[self.delegate upVoteButtonPressed:self];
}


- (IBAction)downVoteButtonPressed:(UIButton *)sender {
    //[self.delegate downVoteButtonPressed:self];
}

-(void)formatCellAndAllSubviews{
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;

    // Selected Cell color
    UIImageView *selectedBackgroundView = [[UIImageView alloc]initWithFrame:self.frame];
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.937 green:0.969 blue:1 alpha:1];
    self.selectedBackgroundView = selectedBackgroundView;
    self.thumbnailImage.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailImage.alpha = 0.75;
    self.thumbnailImage.layer.cornerRadius = 2.0;
    self.thumbnailImage.layer.masksToBounds = YES;

}

- (IBAction)hideButtonPressed:(id)sender {
    [self.delegate hideButtonPressedDelegate:self];
}

- (IBAction)reportPostButtonPressed:(id)sender {
    [self.delegate reportPost:self];
}


@end
