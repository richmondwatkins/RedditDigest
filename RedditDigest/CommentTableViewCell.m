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
}

-(void)prepareForReuse{
    self.commentTextView.editable = YES;
    self.commentTextView.editable = NO;
}
@end
