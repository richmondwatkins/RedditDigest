//
//  CommentTableViewCell.m
//  Pods
//
//  Created by Richmond on 11/10/14.
//
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onShowMoreButtonTapped:(id)sender {
    [self.delegate onShowMoreButtonTapped:self];
}


@end
