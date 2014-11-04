//
//  SubredditListCollectionViewCell.m
//  RedditDigest
//
//  Created by Richmond on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SubredditListCollectionViewCell.h"

@implementation SubredditListCollectionViewCell


+(SubredditListCollectionViewCell *)createCellWithCollectionView:(UICollectionView *)collectionView andSubreddit:(RKSubreddit *)subreddit andIndexPath:(NSIndexPath *)indexPath{

    SubredditListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SubredditCell" forIndexPath:indexPath ];

    cell.subredditTitleCell.text = subreddit.name;
    cell.subredditTitleCell.lineBreakMode = NSLineBreakByWordWrapping;

    cell.subredditTitleCell.preferredMaxLayoutWidth = cell.frame.size.width; // assumes the parent view has its frame already set.

    [cell.subredditTitleCell sizeToFit];
    [cell.subredditTitleCell setNeedsDisplay];
//    [cell.subredditTitleCell sizeToFit];
    return cell;
}

@end
