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
    return cell;
}

@end
