//
//  DigestCellWithImage.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@protocol DigestCellDelegate <NSObject>

-(void)upVoteButtonPressed:(id)cell;
-(void)downVoteButtonPressed:(id)cell;

@end

@interface DigestCellWithImageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subredditLabel;
@property (weak, nonatomic) IBOutlet UILabel *upVoteDownVoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property Post *post;
@property (strong, nonatomic) IBOutlet UIButton *upVoteButton;
@property (strong, nonatomic) IBOutlet UIButton *downVoteButton;

@property id <DigestCellDelegate> delegate;

@end
