//
//  DigestCellWithImage.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DigestCellWithImageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subredditAndAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *upVoteDownVoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;

@end
