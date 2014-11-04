//
//  SubredditListCollectionViewCell.h
//  RedditDigest
//
//  Created by Richmond on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RedditKit.h>
#import <RKSubreddit.h>
#import "CustomSubredditLabel.h"
@interface SubredditListCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *subredditTitleLabel;

+(SubredditListCollectionViewCell *)createCellWithCollectionView:(UICollectionView *)collectionView andSubreddit:(RKSubreddit *)subreddit andIndexPath:(NSIndexPath*)indexPath;

@end
