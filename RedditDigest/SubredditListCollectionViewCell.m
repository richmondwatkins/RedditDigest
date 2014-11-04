//
//  SubredditListCollectionViewCell.m
//  RedditDigest
//
//  Created by Richmond on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SubredditListCollectionViewCell.h"

@implementation SubredditListCollectionViewCell

- (void)drawRect:(CGRect)rect
{
    // inset by half line width to avoid cropping where line touches frame edges
    CGRect insetRect = CGRectInset(rect, 0.5, 0.5);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:rect.size.height/2.0];

    // white background
    [[UIColor whiteColor] setFill];
    [path fill];

    // red outline
    [[UIColor lightGrayColor] setStroke];
    [path stroke];
}

+(SubredditListCollectionViewCell *)createCellWithCollectionView:(UICollectionView *)collectionView andSubreddit:(RKSubreddit *)subreddit andIndexPath:(NSIndexPath *)indexPath{

    SubredditListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SubredditCell" forIndexPath:indexPath ];

    cell.subredditTitleLabel.text = subreddit.name;
    cell.subredditTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;

    cell.subredditTitleLabel.preferredMaxLayoutWidth = cell.frame.size.width; // assumes the parent view has its frame already set.

    [cell.subredditTitleLabel sizeToFit];
    [cell.subredditTitleLabel setNeedsDisplay];
//    [cell.subredditTitleCell sizeToFit];
    return cell;
}

@end
