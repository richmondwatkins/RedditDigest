//
//  DigestCellWithImage.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "MCSwipeTableViewCell.h"
//@protocol DigestCellDelegate <NSObject>
//
//-(void)upVoteButtonPressed:(id)cell;
//-(void)downVoteButtonPressed:(id)cell;
//
//@end

@interface DigestCellWithImageTableViewCell : MCSwipeTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subredditLabel;
@property (weak, nonatomic) IBOutlet UILabel *upVoteDownVoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIView *upvoteView;
@property (strong, nonatomic) IBOutlet UIView *downvoteView;
@property (strong, nonatomic) IBOutlet UIView *authorAndSubredditContainerView;

//@property id <DigestCellDelegate> delegate;

-(void)formatCellAndAllSubviews;

@end
